from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.schemas import UserListResponse, GuestRegistration
from app.models.user_list import UserList
from app.services.user_list_service import UserListService

router = APIRouter()

@router.post("/register", response_model=UserListResponse, status_code=status.HTTP_201_CREATED)
def register_guest(guest_data: GuestRegistration, db: Session = Depends(get_db)):
    """
    Register a guest user identifying by device_id.
    If a user with this device_id already exists, return that user.
    """
    existing_user = UserListService.get_user_by_device_id(db, guest_data.device_id)
    if existing_user:
        return existing_user
    
    return UserListService.create_guest_user(db, guest_data.device_id)
