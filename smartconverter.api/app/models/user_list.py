from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base


class UserList(Base):
    """User model for registration as per mobile app requirements."""
    __tablename__ = "user_list"
    
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    gender = Column(String(50), nullable=True)
    phone_number = Column(String(20), nullable=True)
    email = Column(String(255), unique=True, index=True, nullable=True)
    profile_image_url = Column(String(500), nullable=True)
    password = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    modified_at = Column(DateTime(timezone=True), nullable=True, onupdate=func.now())
    
    # Subscription & Guest Fields
    device_id = Column(String(255), index=True, nullable=True)
    is_premium = Column(Boolean, default=False)
    subscription_plan = Column(String(50), default='free')  # free, monthly, yearly
    subscription_expiry = Column(DateTime(timezone=True), nullable=True)
    
    def __repr__(self):
        return f"<UserList(id={self.id}, email='{self.email}', name='{self.first_name} {self.last_name}')>"
