from sqlalchemy.orm import Session
from app.models.user_list import UserList
from app.models.schemas import UserListCreate, UserListUpdate
from typing import Optional, List
from app.services.auth_service import get_password_hash, verify_password


class UserListService:
    @staticmethod
    def get_user(db: Session, user_id: int) -> Optional[UserList]:
        return db.query(UserList).filter(UserList.id == user_id).first()

    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[UserList]:
        return db.query(UserList).filter(UserList.email == email).first()

    @staticmethod
    def authenticate(db: Session, email: str, password: str) -> Optional[UserList]:
        user = UserListService.get_user_by_email(db, email)
        if not user:
            return None
        if not user.password:
            return None
        if not verify_password(password, user.password):
            return None
        return user

    @staticmethod
    def get_user_by_device_id(db: Session, device_id: str) -> Optional[UserList]:
        return db.query(UserList).filter(UserList.device_id == device_id).first()

    @staticmethod
    def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[UserList]:
        return db.query(UserList).offset(skip).limit(limit).all()

    @staticmethod
    def create_user(db: Session, user: UserListCreate) -> UserList:
        # Debug logging
        print(f"DEBUG: create_user called with email={user.email}, device_id={user.device_id}")
        
        # Check if we have a guest user with this device_id
        if user.device_id:
            existing_guest = UserListService.get_user_by_device_id(db, user.device_id)
            print(f"DEBUG: Search for existing guest with device_id={user.device_id} returned: {existing_guest}")
            
            if existing_guest:
                # Update existing guest to registered user
                print(f"DEBUG: Merging with existing guest {existing_guest.id}")
                existing_guest.email = user.email
                existing_guest.password = get_password_hash(user.password) if user.password else None
                existing_guest.first_name = user.first_name
                existing_guest.last_name = user.last_name
                existing_guest.gender = user.gender
                existing_guest.phone_number = user.phone_number
                # Keep subscription status if they had one, or update if provided in user
                if user.is_premium:
                    existing_guest.is_premium = user.is_premium
                if user.subscription_plan:
                    existing_guest.subscription_plan = user.subscription_plan
                
                db.add(existing_guest)
                db.commit()
                db.refresh(existing_guest)
                return existing_guest

        # Normal creation if no guest found
        db_user = UserList(
            email=user.email,
            password=get_password_hash(user.password) if user.password else None,
            first_name=user.first_name,
            last_name=user.last_name,
            gender=user.gender,
            phone_number=user.phone_number,
            device_id=user.device_id,
            is_premium=user.is_premium if user.is_premium else False,
            subscription_plan=user.subscription_plan if user.subscription_plan else 'free'
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    def create_guest_user(db: Session, device_id: str) -> UserList:
        db_user = UserList(
            device_id=device_id,
            is_premium=False,
            subscription_plan='free'
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    def upgrade_subscription(db: Session, user_id: int, plan_id: str) -> Optional[UserList]:
        from datetime import datetime, timedelta
        db_user = UserListService.get_user(db, user_id)
        if not db_user:
            return None
        
        db_user.is_premium = True
        db_user.subscription_plan = plan_id
        
        # Set expiry based on plan
        if plan_id == 'monthly':
            db_user.subscription_expiry = datetime.now() + timedelta(days=30)
        elif plan_id == 'yearly':
            db_user.subscription_expiry = datetime.now() + timedelta(days=365)
            
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
