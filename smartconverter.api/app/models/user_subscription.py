from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base

class UserSubscriptionDetails(Base):
    """Model for storing user subscription details."""
    __tablename__ = "user_subscription_details"
    
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    modified_at = Column(DateTime(timezone=True), nullable=True, onupdate=func.now())
    
    user_id = Column(Integer, unique=True, nullable=False)
    
    is_premium = Column(Boolean, default=False)
    subscription_plan = Column(String(50), default='free')  # free, monthly, yearly
    subscription_expiry = Column(DateTime(timezone=True), nullable=True)
    
    # Relationship removed as per user request
    
    def __repr__(self):
        return f"<UserSubscriptionDetails(user_id={self.user_id}, plan='{self.subscription_plan}')>"
