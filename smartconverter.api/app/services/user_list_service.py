from sqlalchemy.orm import Session
from app.models.user_list import UserList
from app.models.schemas import UserListCreate, UserListUpdate
from typing import Optional, List
from app.services.auth_service import get_password_hash, verify_password


class UserListService:
    @staticmethod
    def _attach_subscription_info(db: Session, user: UserList) -> UserList:
        """Helper to attach subscription info to user object dynamically."""
        if not user or not db:
            return user
        
        from app.models.user_subscription import UserSubscriptionDetails
        sub = db.query(UserSubscriptionDetails).filter(UserSubscriptionDetails.user_id == user.id).first()
        
        # dynamic attachment for Pydantic compatibility
        if sub:
            user.is_premium = sub.is_premium
            user.subscription_plan = sub.subscription_plan
            user.subscription_expiry = sub.subscription_expiry
        else:
            user.is_premium = False
            user.subscription_plan = 'free'
            user.subscription_expiry = None
            
        return user

    @staticmethod
    def get_user(db: Session, user_id: int) -> Optional[UserList]:
        if not db:
            return None
        user = db.query(UserList).filter(UserList.id == user_id).first()
        return UserListService._attach_subscription_info(db, user)

    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[UserList]:
        if not db:
            return None
        user = db.query(UserList).filter(UserList.email == email).first()
        return UserListService._attach_subscription_info(db, user)

    @staticmethod
    def authenticate(db: Session, email: str, password: str) -> Optional[UserList]:
        if not db:
            return None
        # Don't use get_user_by_email to avoid extra query if password verify fails, 
        # but acceptable for simplicity to reuse logic
        user = db.query(UserList).filter(UserList.email == email).first()
        if not user:
            return None
        if not user.password:
            return None
        if not verify_password(password, user.password):
            return None
            
        return UserListService._attach_subscription_info(db, user)

    @staticmethod
    def get_user_by_device_id(db: Session, device_id: str) -> Optional[UserList]:
        if not db:
            return None
        user = db.query(UserList).filter(UserList.device_id == device_id).first()
        return UserListService._attach_subscription_info(db, user)

    @staticmethod
    def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[UserList]:
        if not db:
            return []
        users = db.query(UserList).offset(skip).limit(limit).all()
        for user in users:
            UserListService._attach_subscription_info(db, user)
        return users

    @staticmethod
    def create_user(db: Session, user: UserListCreate) -> UserList:
        if not db:
            return None
            
        from app.models.user_subscription import UserSubscriptionDetails
        
        # Debug logging
        print(f"DEBUG: create_user called with email={user.email}, device_id={user.device_id}")
        
        # Check if we have a guest user with this device_id
        if user.device_id:
            existing_user = db.query(UserList).filter(UserList.device_id == user.device_id).first()
            
            # Only upgrade if it's a guest (no email)
            if existing_user and existing_user.email is None:
                # Update existing guest to registered user
                existing_user.email = user.email
                existing_user.password = get_password_hash(user.password) if user.password else None
                existing_user.first_name = user.first_name
                existing_user.last_name = user.last_name
                existing_user.gender = user.gender
                existing_user.phone_number = user.phone_number
                
                # Update subscription explicitly
                sub = db.query(UserSubscriptionDetails).filter(UserSubscriptionDetails.user_id == existing_user.id).first()
                if sub:
                    if user.is_premium is not None:
                        sub.is_premium = user.is_premium
                    if user.subscription_plan:
                        sub.subscription_plan = user.subscription_plan
                    db.add(sub)
                else:
                     # Create if missing
                    new_sub = UserSubscriptionDetails(
                        user_id=existing_user.id,
                        is_premium=user.is_premium if user.is_premium else False,
                        subscription_plan=user.subscription_plan if user.subscription_plan else 'free',
                        subscription_expiry=user.subscription_expiry
                    )
                    db.add(new_sub)
                
                db.add(existing_user)
                db.commit()
                db.refresh(existing_user)
                return UserListService._attach_subscription_info(db, existing_user)

        # Normal creation if no guest found
        db_user = UserList(
            email=user.email,
            password=get_password_hash(user.password) if user.password else None,
            first_name=user.first_name,
            last_name=user.last_name,
            gender=user.gender,
            phone_number=user.phone_number,
            device_id=user.device_id
        )
        db.add(db_user)
        db.flush() # Flush to get ID
        
        # Create subscription details
        subscription = UserSubscriptionDetails(
            user_id=db_user.id,
            is_premium=user.is_premium if user.is_premium else False,
            subscription_plan=user.subscription_plan if user.subscription_plan else 'free',
            subscription_expiry=user.subscription_expiry
        )
        db.add(subscription)
        
        db.commit()
        db.refresh(db_user)
        return UserListService._attach_subscription_info(db, db_user)

    @staticmethod
    def create_guest_user(db: Session, device_id: str) -> UserList:
        if not db:
            return None
            
        from app.models.user_subscription import UserSubscriptionDetails

        db_user = UserList(
            device_id=device_id
        )
        db.add(db_user)
        db.flush()
        
        subscription = UserSubscriptionDetails(
            user_id=db_user.id,
            is_premium=False,
            subscription_plan='free'
        )
        db.add(subscription)
        
        db.commit()
        db.refresh(db_user)
        return UserListService._attach_subscription_info(db, db_user)

    @staticmethod
    def upgrade_subscription(db: Session, user_id: int, plan_id: str) -> Optional[UserList]:
        if not db:
            return None
            
        from datetime import datetime, timedelta
        from app.models.user_subscription import UserSubscriptionDetails
        
        db_user = db.query(UserList).filter(UserList.id == user_id).first()
        if not db_user:
            return None
        
        sub = db.query(UserSubscriptionDetails).filter(UserSubscriptionDetails.user_id == user_id).first()
        
        if not sub:
            # Create if missing
            sub = UserSubscriptionDetails(user_id=db_user.id, is_premium=False, subscription_plan='free')
            db.add(sub)

        sub.is_premium = True
        sub.subscription_plan = plan_id
        
        # Set expiry based on plan
        if plan_id == 'monthly':
            sub.subscription_expiry = datetime.now() + timedelta(days=30)
        elif plan_id == 'yearly':
            sub.subscription_expiry = datetime.now() + timedelta(days=365)
            
        db.add(sub)
        db.commit()
        db.refresh(db_user)
        return UserListService._attach_subscription_info(db, db_user)

    @staticmethod
    def update_user(db: Session, user_id: int, user_update: UserListUpdate) -> Optional[UserList]:
        if not db:
            return None
        db_user = db.query(UserList).filter(UserList.id == user_id).first()
        if not db_user:
            return None
        
        update_data = user_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_user, key, value)
            
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return UserListService._attach_subscription_info(db, db_user)

    @staticmethod
    def delete_user(db: Session, user_id: int) -> bool:
        if not db:
            return False
            
        from app.models.user_subscription import UserSubscriptionDetails
        
        db_user = db.query(UserList).filter(UserList.id == user_id).first()
        if not db_user:
            return False
            
        # Manually delete subscription first (since no cascade)
        db.query(UserSubscriptionDetails).filter(UserSubscriptionDetails.user_id == user_id).delete()
        
        db.delete(db_user)
        db.commit()
        return True
