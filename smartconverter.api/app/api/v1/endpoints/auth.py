from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse, JSONResponse
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models.user_list import UserList
from app.models.schemas import (
    UserLogin, Token, UserListCreate, UserListResponse, ChangePassword, ForgotPassword
)
from app.services.auth_service import (
    authenticate_user, create_token_pair, 
    refresh_access_token, blacklist_token, get_user_by_email,
    verify_password, get_password_hash
)
from app.services.email_service import EmailService
import secrets
import string
from app.services.user_list_service import UserListService
from app.api.v1.dependencies import get_current_user, get_current_active_user
# from authlib.integrations.starlette_client import OAuth
# from starlette.config import Config
# from starlette.middleware.sessions import SessionMiddleware
import secrets
router = APIRouter()

# OAuth client setup
# OAuth and Social Signup are currently disabled as they rely on the old User model.
# Re-implement using UserList if needed.
# ... (Lines 26-129 commented out effectively)


# Core Authentication Endpoints
# @router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
# async def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
#     """Register a new user (Deprecated)."""
#     pass


@router.post("/register-userlist", response_model=UserListResponse, status_code=status.HTTP_201_CREATED)
async def register_user_list_endpoint(user_data: UserListCreate, db: Session = Depends(get_db)):
    """Register a new user in the UserList table (specific for mobile task)."""
    # Check if user already exists
    if UserListService.get_user_by_email(db, user_data.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered. Please Sign In with this email or use another email."
        )
    
    # Create user
    try:
        user = UserListService.create_user(db, user_data)
        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e)}"
        )


@router.post("/login-userlist", response_model=Token)
async def login_user_list_endpoint(login_data: UserLogin, db: Session = Depends(get_db)):
    """Login user from UserList table and return access token."""
    user = UserListService.authenticate(db, login_data.email, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create tokens (reusing existing system's token creation)
    # Since UserList model doesn't have a 'username', we use 'email' as the sub
    return create_token_pair(user)


# @router.post("/login", response_model=Token)
# async def login_user(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
#     # Use /login-userlist instead
#     pass


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


@router.get("/me", response_model=UserListResponse)
async def get_current_user_info(current_user: UserList = Depends(get_current_active_user)):
    """Get current user information."""
    return current_user


@router.post("/change-password", status_code=status.HTTP_200_OK)
async def change_password(
    password_data: ChangePassword,
    current_user: UserList = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Change user password."""
    # Verify old password
    if not current_user.password or not verify_password(password_data.old_password, current_user.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect old password"
        )
    
    # Update with new password
    current_user.password = get_password_hash(password_data.new_password)
    db.add(current_user)
    db.commit()
    
    return {"message": "Password updated successfully"}


@router.post("/forgot-password", status_code=status.HTTP_200_OK)
async def forgot_password(
    data: ForgotPassword,
    db: Session = Depends(get_db)
):
    """
    Reset user password and send it via email.
    """
    user = get_user_by_email(db, data.email)
    if not user:
        # Per user request: Explicitly inform if email does not exist
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No account found with this email address."
        )
    
    # Generate new random password (8 chars, alphanumeric)
    alphabet = string.ascii_letters + string.digits
    new_password = ''.join(secrets.choice(alphabet) for i in range(8))
    
    # Update DB
    user.password = get_password_hash(new_password)
    db.add(user)
    db.commit()
    
    # Send Email
    email_sent = await EmailService.send_password_reset_email(data.email, new_password)
    
    if not email_sent:
        # If email fails (e.g. bad config), we might want to log it. 
        # For now, we return success to the user but they won't get the email.
        # In a real app we might alert admins.
        print(f"FAILED TO SEND EMAIL. New Password for {data.email}: {new_password}")
        return {"message": "Password reset, but failed to send email. Check server logs."}
        
    return {"message": "Password reset email sent successfully."}

# Update user, Admin endpoints etc are disabled as they rely on old User model
# ...
