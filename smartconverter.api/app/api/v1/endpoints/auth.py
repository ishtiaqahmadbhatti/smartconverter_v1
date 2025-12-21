from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse, JSONResponse
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models.user import User, UserRole
from app.models.schemas import (
    UserCreate, UserLogin, UserResponse, Token, UserUpdate,
    UserListCreate, UserListResponse
)
from app.services.auth_service import (
    authenticate_user, create_user, create_token_pair, 
    refresh_access_token, blacklist_token, get_user_by_email,
    get_user_by_username, update_user_role, get_all_users, get_users_by_role
)
from app.services.user_list_service import get_user_list_by_email, create_user_list, authenticate_user_list
from app.api.v1.dependencies import get_current_user, get_current_active_user, get_current_admin_user
from authlib.integrations.starlette_client import OAuth
from starlette.config import Config
from starlette.middleware.sessions import SessionMiddleware
import secrets
router = APIRouter()

# OAuth client setup
config = Config(environ={
    "GOOGLE_CLIENT_ID": settings.google_client_id or "",
    "GOOGLE_CLIENT_SECRET": settings.google_client_secret or "",
    "FACEBOOK_CLIENT_ID": settings.facebook_client_id or "",
    "FACEBOOK_CLIENT_SECRET": settings.facebook_client_secret or "",
})
oauth = OAuth(config)

oauth.register(
    name="google",
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"},
)

oauth.register(
    name="facebook",
    client_id=settings.facebook_client_id,
    client_secret=settings.facebook_client_secret,
    access_token_url="https://graph.facebook.com/v12.0/oauth/access_token",
    authorize_url="https://www.facebook.com/v12.0/dialog/oauth",
    api_base_url="https://graph.facebook.com/v12.0/",
    client_kwargs={"scope": "public_profile,email"},
)


def _upsert_user(db: Session, email: str, name: str | None) -> User:
    user = db.query(User).filter(User.email == email).first()
    if user:
        return user
    username = email.split("@")[0]
    user = User(
        email=email,
        username=username,
        full_name=name or "",
        hashed_password="social",
        is_verified=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.get("/signupwithgoogle")
async def signup_with_google(request: Request):
    state = secrets.token_urlsafe(16)
    request.session["oauth_state"] = state
    redirect_uri = request.url_for("google_callback")
    return await oauth.google.authorize_redirect(request, redirect_uri, state=state)


@router.get("/google/callback", name="google_callback")
async def google_callback(request: Request, db: Session = Depends(get_db)):
    token = await oauth.google.authorize_access_token(request)
    # Get userinfo (OIDC)
    userinfo = token.get("userinfo") or await oauth.google.parse_id_token(request, token)
    email = userinfo.get("email") if userinfo else None
    name = userinfo.get("name") if userinfo else None
    if not email:
        raise HTTPException(status_code=400, detail="Email permission required")
    user = _upsert_user(db, email, name)
    return JSONResponse({"success": True, "provider": "google", "email": user.email, "name": user.full_name})


@router.get("/signupwithfacebook")
async def signup_with_facebook(request: Request):
    state = secrets.token_urlsafe(16)
    request.session["oauth_state"] = state
    redirect_uri = request.url_for("facebook_callback")
    return await oauth.facebook.authorize_redirect(request, redirect_uri, state=state)


@router.get("/facebook/callback", name="facebook_callback")
async def facebook_callback(request: Request, db: Session = Depends(get_db)):
    token = await oauth.facebook.authorize_access_token(request)
    resp = await oauth.facebook.get("me?fields=id,name,email", token=token)
    data = resp.json()
    email = data.get("email")
    name = data.get("name")
    if not email:
        raise HTTPException(status_code=400, detail="Email permission required")
    user = _upsert_user(db, email, name)
    return JSONResponse({"success": True, "provider": "facebook", "email": user.email, "name": user.full_name})


@router.get("/google/url")
async def get_google_auth_url(request: Request):
    state = secrets.token_urlsafe(16)
    request.session["oauth_state"] = state
    redirect_uri = request.url_for("google_callback")
    client = oauth.create_client("google")
    # create_authorization_url returns (url, state)
    url, _ = client.create_authorization_url(redirect_uri, state=state, scope="openid email profile")
    return {"auth_url": url}


@router.get("/facebook/url")
async def get_facebook_auth_url(request: Request):
    state = secrets.token_urlsafe(16)
    request.session["oauth_state"] = state
    redirect_uri = request.url_for("facebook_callback")
    client = oauth.create_client("facebook")
    url, _ = client.create_authorization_url(redirect_uri, state=state, scope="public_profile,email")
    return {"auth_url": url}


# Core Authentication Endpoints
@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register a new user."""
    # Check if user already exists
    if get_user_by_email(db, user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    try:
        user = create_user(db, user_data.dict())
        return UserResponse.from_orm(user)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e)}"
        )


@router.post("/register-userlist", response_model=UserListResponse, status_code=status.HTTP_201_CREATED)
async def register_user_list_endpoint(user_data: UserListCreate, db: Session = Depends(get_db)):
    """Register a new user in the UserList table (specific for mobile task)."""
    # Check if user already exists
    if get_user_list_by_email(db, user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered in UserList"
        )
    
    # Create user
    try:
        user = create_user_list(db, user_data.dict())
        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e)}"
        )


@router.post("/login-userlist", response_model=Token)
async def login_user_list_endpoint(login_data: UserLogin, db: Session = Depends(get_db)):
    """Login user from UserList table and return access token."""
    user = authenticate_user_list(db, login_data.email, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create tokens (reusing existing system's token creation)
    # Since UserList model doesn't have a 'username', we use 'email' as the sub
    return create_token_pair(user)


@router.post("/login", response_model=Token)
async def login_user(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Login user and return access token."""
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    # Create token pair
    token_data = create_token_pair(user)
    return Token(**token_data)


@router.post("/refresh", response_model=Token)
async def refresh_token(refresh_token: str, db: Session = Depends(get_db)):
    """Refresh access token using refresh token."""
    token_data = refresh_access_token(refresh_token, db)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    return Token(**token_data)


@router.post("/logout")
async def logout_user(token: str = Depends(OAuth2PasswordBearer(tokenUrl="auth/login"))):
    """Logout user by blacklisting token."""
    success = blacklist_token(token)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Logout failed"
        )
    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_active_user)):
    """Get current user information."""
    return UserResponse.from_orm(current_user)


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update current user information."""
    if user_update.full_name is not None:
        current_user.full_name = user_update.full_name
    if user_update.username is not None:
        # Check if username is already taken
        existing_user = get_user_by_username(db, user_update.username)
        if existing_user and existing_user.id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )
        current_user.username = user_update.username
    
    db.commit()
    db.refresh(current_user)
    return UserResponse.from_orm(current_user)


# Admin-only endpoints
@router.get("/admin/users", response_model=list[UserResponse])
async def get_all_users_admin(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Get all users (admin only)."""
    users = get_all_users(db, skip=skip, limit=limit)
    return [UserResponse.from_orm(user) for user in users]


@router.put("/admin/users/{user_id}/role")
async def update_user_role_admin(
    user_id: int,
    new_role: UserRole,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Update user role (admin only)."""
    user = update_user_role(db, user_id, new_role)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return {"message": f"User role updated to {new_role.value}"}


@router.get("/admin/users/role/{role}", response_model=list[UserResponse])
async def get_users_by_role_admin(
    role: UserRole,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Get users by role (admin only)."""
    users = get_users_by_role(db, role)
    return [UserResponse.from_orm(user) for user in users]
