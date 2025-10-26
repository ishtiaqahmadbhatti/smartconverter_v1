from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base


class ConversionLog(Base):
    """Conversion log model to track file conversions."""
    __tablename__ = "conversion_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    operation_type = Column(String(100), nullable=False)  # pdf-to-word, image-to-text, etc.
    input_filename = Column(String(255), nullable=False)
    output_filename = Column(String(255), nullable=True)
    file_size_before = Column(Integer, nullable=True)
    file_size_after = Column(Integer, nullable=True)
    status = Column(String(50), default="completed")  # completed, failed, processing
    error_message = Column(Text, nullable=True)
    processing_time = Column(Integer, nullable=True)  # in milliseconds
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationship
    user = relationship("User", back_populates="conversion_logs")
    
    def __repr__(self):
        return f"<ConversionLog(id={self.id}, operation='{self.operation_type}', status='{self.status}')>"
