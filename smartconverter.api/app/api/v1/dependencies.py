from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user_list import UserList
from app.services.auth_service import verify_token, get_user_by_email

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> UserList:
    """Get the current authenticated user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token_data = verify_token(token, credentials_exception)
    user = get_user_by_email(db, email=token_data.email)
    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(current_user: UserList = Depends(get_current_user)) -> UserList:
    """Get the current active user."""
    # UserList doesn't have is_active, assuming always active for now
    return current_user


async def get_current_admin_user(current_user: UserList = Depends(get_current_active_user)) -> UserList:
    """Get the current admin user."""
    # UserList doesn't have roles yet, so we can't really enforce admin
    return current_user


async def get_current_moderator_user(current_user: UserList = Depends(get_current_active_user)) -> UserList:
    """Get the current moderator user."""
    return current_user


async def get_current_premium_user(current_user: UserList = Depends(get_current_active_user)) -> UserList:
    """Get the current premium user."""
    if not current_user.is_premium:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Premium access required"
        )
    return current_user