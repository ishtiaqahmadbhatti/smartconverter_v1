from sqlalchemy.orm import Session
from app.models.user_list import UserList
from app.models.schemas import UserListCreate, UserListUpdate
from typing import Optional, List
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserListService:
    @staticmethod
    def get_user(db: Session, user_id: int) -> Optional[UserList]:
        return db.query(UserList).filter(UserList.id == user_id).first()

    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[UserList]:
        return db.query(UserList).filter(UserList.email == email).first()

    @staticmethod
    def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[UserList]:
        return db.query(UserList).offset(skip).limit(limit).all()

    @staticmethod
    def create_user(db: Session, user: UserListCreate) -> UserList:
        db_user = UserList(
            email=user.email,
            password=user.password,
            first_name=user.first_name,
            last_name=user.last_name,
            gender=user.gender,
            phone_number=user.phone_number
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    def update_user(db: Session, user_id: int, user_update: UserListUpdate) -> Optional[UserList]:
        db_user = UserListService.get_user(db, user_id)
        if not db_user:
            return None
        
        update_data = user_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_user, key, value)
            
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    def delete_user(db: Session, user_id: int) -> bool:
        db_user = UserListService.get_user(db, user_id)
        if not db_user:
            return False
            
        db.delete(db_user)
        db.commit()
        return True
