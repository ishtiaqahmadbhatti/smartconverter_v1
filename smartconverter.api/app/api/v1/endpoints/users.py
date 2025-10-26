from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.models.user import User, UserRole
from app.models.schemas import UserResponse, UserUpdate
from app.services.auth_service import (
    get_user_by_email, get_user_by_username, update_user_role,
    get_all_users, get_users_by_role
)
from app.api.v1.dependencies import get_current_active_user, get_current_admin_user

router = APIRouter()


@router.get("/profile", response_model=UserResponse)
async def get_user_profile(current_user: User = Depends(get_current_active_user)):
    """Get current user's profile."""
    return UserResponse.from_orm(current_user)


@router.put("/profile", response_model=UserResponse)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update current user's profile."""
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


@router.get("/stats")
async def get_user_stats(current_user: User = Depends(get_current_active_user)):
    """Get user statistics."""
    # This would typically query conversion logs and other user data
    return {
        "user_id": current_user.id,
        "username": current_user.username,
        "role": current_user.role.value,
        "is_premium": current_user.is_premium(),
        "conversions_today": 0,  # Would be calculated from logs
        "total_conversions": 0,  # Would be calculated from logs
        "storage_used": 0,  # Would be calculated from file sizes
        "max_storage": 100 * 1024 * 1024 if current_user.is_premium() else 10 * 1024 * 1024
    }


# Admin endpoints
@router.get("/admin/all", response_model=List[UserResponse])
async def get_all_users_admin(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Get all users (admin only)."""
    users = get_all_users(db, skip=skip, limit=limit)
    return [UserResponse.from_orm(user) for user in users]


@router.get("/admin/role/{role}", response_model=List[UserResponse])
async def get_users_by_role_admin(
    role: UserRole,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Get users by role (admin only)."""
    users = get_users_by_role(db, role)
    return [UserResponse.from_orm(user) for user in users]


@router.put("/admin/{user_id}/role")
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


@router.put("/admin/{user_id}/activate")
async def activate_user_admin(
    user_id: int,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Activate/deactivate user (admin only)."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    user.is_active = not user.is_active
    db.commit()
    
    status_text = "activated" if user.is_active else "deactivated"
    return {"message": f"User {status_text} successfully"}


@router.put("/admin/{user_id}/verify")
async def verify_user_admin(
    user_id: int,
    current_user: User = Depends(get_current_admin_user),
    db: Session = Depends(get_db)
):
    """Verify user email (admin only)."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    user.is_verified = True
    db.commit()
    
    return {"message": "User verified successfully"}


@router.get("/admin/stats")
async def get_admin_stats(current_user: User = Depends(get_current_admin_user)):
    """Get admin statistics."""
    # This would typically query system-wide statistics
    return {
        "total_users": 0,  # Would be calculated
        "active_users": 0,  # Would be calculated
        "premium_users": 0,  # Would be calculated
        "conversions_today": 0,  # Would be calculated
        "total_conversions": 0,  # Would be calculated
        "storage_used": 0,  # Would be calculated
        "system_health": "healthy"
    }