from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import RedirectResponse, JSONResponse
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models.user_list import UserList
from app.models.schemas import (
    UserLogin, Token, UserListCreate, UserListResponse, ChangePassword, ForgotPassword, VerifyOTP, ResetPasswordConfirm
)
from app.services.auth_service import (
    authenticate_user, create_token_pair, 
    refresh_access_token, blacklist_token, get_user_by_email,
    verify_password, get_password_hash
)
from app.services.email_service import EmailService
import secrets
import string
import random
import datetime
from app.models.otp import PasswordResetOTP
from jose import jwt
from datetime import timedelta
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
    Generate 6-digit OTP and send via email.
    """
    user = get_user_by_email(db, data.email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No account found with this email address."
        )
    
    # Generate 6-digit OTP
    otp_code = str(random.randint(100000, 999999))
    expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=3)
    
    # Get user full name (handle None values gracefully)
    first_name = user.first_name if user.first_name else ""
    last_name = user.last_name if user.last_name else ""
    full_name = f"{first_name} {last_name}".strip()
    
    # Save to DB
    otp_record = PasswordResetOTP(
        email=data.email,
        otp_code=otp_code,
        full_name=full_name,
        device_id=data.device_id,
        expires_at=expires_at,
        is_used=False
    )
    db.add(otp_record)
    db.commit()
    
    # Send Email
    # Note: We need to update EmailService to handle OTP templates, 
    # but for now we'll use the existing method or update it shortly.
    # Assuming EmailService has send_otp_email method, or we adapt existing.
    # Let's assume we'll use send_otp_email (I will update EmailService next).
    email_sent = await EmailService.send_otp_email(data.email, otp_code)
    
    if not email_sent:
        print(f"FAILED TO SEND OTP. OTP for {data.email}: {otp_code}")
        # In production, we might want to return an error, but for debugging/dev
        # we allow it so developers can see the OTP in console.
        return {"message": "OTP generated. Check console if email fails."}
        
    return {"message": "Verification code sent to your email."}


@router.post("/verify-otp", status_code=status.HTTP_200_OK)
async def verify_otp(
    data: VerifyOTP,
    db: Session = Depends(get_db)
):
    """Verify OTP and return a reset token."""
    # Find active, unused OTP
    otp_record = db.query(PasswordResetOTP).filter(
        PasswordResetOTP.email == data.email,
        PasswordResetOTP.otp_code == data.otp_code,
        PasswordResetOTP.is_used == False,
        PasswordResetOTP.expires_at > datetime.datetime.utcnow()
    ).order_by(PasswordResetOTP.created_at.desc()).first()
    
    if not otp_record:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification code"
        )
        
    # Mark as used (optional here, or wait until password reset. 
    # Better to mark verifying as success, but strictly speaking 'used' comes when resetting.
    # However, to prevent re-generation of tokens, we can mark it used.
    # Or just return a token. Let's return a token.
    
    # Create specific reset token
    reset_token_expires = timedelta(minutes=10)
    reset_token = jwt.encode(
        {"sub": data.email, "scope": "reset_password", "exp": datetime.datetime.utcnow() + reset_token_expires},
        settings.secret_key,
        algorithm=settings.algorithm
    )
    
    return {"message": "OTP Verified", "reset_token": reset_token}


@router.post("/reset-password-confirm", status_code=status.HTTP_200_OK)
async def reset_password_confirm(
    data: ResetPasswordConfirm,
    db: Session = Depends(get_db)
):
    """Reset password using the reset token."""
    try:
        payload = jwt.decode(data.reset_token, settings.secret_key, algorithms=[settings.algorithm])
        email = payload.get("sub")
        scope = payload.get("scope")
        if not email or scope != "reset_password":
            raise HTTPException(status_code=400, detail="Invalid token")
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=400, detail="Invalid token")
        
    user = get_user_by_email(db, email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Update Password
    user.password = get_password_hash(data.new_password)
    db.add(user)
    
    # Mark OTPs as used (clean up all active OTPs for this user to be safe)
    # This acts as invalidating previous codes.
    db.query(PasswordResetOTP).filter(
        PasswordResetOTP.email == email,
        PasswordResetOTP.is_used == False
    ).update({"is_used": True})
    
    db.commit()
    
    return {"message": "Password has been reset successfully."}

    return {"message": "Password has been reset successfully."}


from fastapi import UploadFile, File
import shutil
import os
import uuid

@router.post("/upload-profile-image", response_model=UserListResponse)
async def upload_profile_image(
    file: UploadFile = File(...),
    current_user: UserList = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Upload profile image and update user record."""
    UPLOAD_DIR = "uploads/profile_images"
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    
    # Generate unique filename
    file_extension = os.path.splitext(file.filename)[1]
    filename = f"{current_user.id}_{uuid.uuid4().hex}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, filename)
    
    # Save file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # Store relative path (client will prepend base URL)
    relative_path = f"uploads/profile_images/{filename}"
    
    current_user.profile_image_url = relative_path
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    
    return current_user

