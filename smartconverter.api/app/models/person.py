from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base


class Person(Base):
    """Person model for storing personal information."""
    __tablename__ = "persons"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    age = Column(String(10), nullable=False)  # Storing as string as requested
    gender = Column(String(50), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<Person(id={self.id}, name='{self.name}', age='{self.age}', gender='{self.gender}')>"
