from sqlalchemy.orm import Session
from app.models.user_list import UserList
from typing import Optional


def get_user_list_by_email(db: Session, email: str) -> Optional[UserList]:
    """Get a user from UserList by email."""
    return db.query(UserList).filter(UserList.email == email).first()


def create_user_list(db: Session, user_data: dict) -> UserList:
    """Create a new user in UserList."""
    db_user = UserList(
        email=user_data["email"],
        first_name=user_data["first_name"],
        last_name=user_data["last_name"],
        gender=user_data["gender"],
        phone_number=user_data["phone_number"],
        password=user_data["password"]
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
