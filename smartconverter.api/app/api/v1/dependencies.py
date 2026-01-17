from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import Optional
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


async def get_user_id(request: Request, db: Session) -> Optional[int]:
    """Helper to get user_id from token or device_id header."""
    from app.services.user_list_service import UserListService
    
    # Debug: Print all headers to see what's coming in
    headers = dict(request.headers)
    with open("debug_logs.txt", "a") as f:
        f.write(f"\n--- Request at {request.url.path} ---\n")
        f.write(f"Headers: {headers}\n")
    
    print(f"DEBUG: Request Headers: {headers}")
    
    # 1. Try Token
    try:
        # Case-insensitive header check
        auth_header = request.headers.get("authorization")
        if auth_header and auth_header.lower().startswith("bearer "):
            token = auth_header.split(" ")[1]
            from app.services.auth_service import verify_token
            try:
                token_data = verify_token(token, None)
                if token_data and token_data.email:
                    user = UserListService.get_user_by_email(db, token_data.email)
                    if user:
                        print(f"DEBUG: Found user by token: {user.id}")
                        return user.id
            except Exception as e:
                print(f"DEBUG: Token verification failed: {e}")
    except Exception as e:
        print(f"DEBUG: Error processing auth header: {e}")

    # 2. Try Device ID (check multiple possible header names)
    # Try to get device ID from custom header
    device_id = request.headers.get("x-device-id") or request.headers.get("X-Device-Id") or request.headers.get("device-id")
    with open("debug_logs.txt", "a") as f:
        f.write(f"Extracted device_id: {device_id}\n")
    print(f"DEBUG: Extracted device_id: {device_id}")
    
    if device_id:
        try:
            user = UserListService.get_user_by_device_id(db, device_id)
            if user:
                with open("debug_logs.txt", "a") as f:
                    f.write(f"Found user by device_id: {user.id}\n")
                print(f"DEBUG: Found user by device_id: {user.id}")
                return user.id
            else:
                print(f"DEBUG: No user found in DB for device_id: '{device_id}'")
        except Exception as e:
            print(f"DEBUG: Error in get_user_by_device_id service: {e}")
            
    print("DEBUG: No user_id could be identified for this request")
    return None