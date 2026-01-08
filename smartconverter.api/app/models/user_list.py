from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base


class UserList(Base):
    """User model for registration as per mobile app requirements."""
    __tablename__ = "user_list"
    
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    gender = Column(String(50), nullable=False)
    phone_number = Column(String(20), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    modified_at = Column(DateTime(timezone=True), nullable=True, onupdate=func.now())
    
    def __repr__(self):
        return f"<UserList(id={self.id}, email='{self.email}', name='{self.first_name} {self.last_name}')>"
