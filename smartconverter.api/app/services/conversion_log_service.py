from sqlalchemy.orm import Session
from app.models.user_conversion import UserConversionDetails
from typing import Optional, Any
import os

class ConversionLogService:
    @staticmethod
    def log_conversion(
        db: Session,
        user_id: Optional[int],
        conversion_type: str,
        input_filename: str,
        input_file_size: Optional[int] = None,
        input_file_type: Optional[str] = None,
        output_filename: Optional[str] = None,
        output_file_size: Optional[int] = None,
        output_file_type: Optional[str] = None,
        status: str = "success",
        error_message: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        method: str = "POST",
        api_endpoint: Optional[str] = None
    ) -> UserConversionDetails:
        """
        Record a conversion event in the database.
        """
        db_log = UserConversionDetails(
            user_id=user_id,
            conversion_type=conversion_type,
            input_filename=input_filename,
            input_file_size=input_file_size,
            input_file_type=input_file_type,
            output_filename=output_filename,
            output_file_size=output_file_size,
            output_file_type=output_file_type,
            status=status,
            error_message=error_message,
            ip_address=ip_address,
            user_agent=user_agent,
            method=method,
            api_endpoint=api_endpoint
        )
        db.add(db_log)
        db.commit()
        db.refresh(db_log)
        return db_log

    @staticmethod
    def update_log_status(
        db: Session,
        log_id: int,
        status: str,
        output_filename: Optional[str] = None,
        output_file_size: Optional[int] = None,
        error_message: Optional[str] = None
    ) -> Optional[UserConversionDetails]:
        """
        Update an existing log entry with final status and results.
        """
        db_log = db.query(UserConversionDetails).filter(UserConversionDetails.id == log_id).first()
        if not db_log:
            return None
        
        db_log.status = status
        if output_filename:
            db_log.output_filename = output_filename
            # Get size if not provided
            if not output_file_size and os.path.exists(output_filename):
                db_log.output_file_size = os.path.getsize(output_filename)
            else:
                db_log.output_file_size = output_file_size
        
        if error_message:
            db_log.error_message = error_message
            
        db.commit()
        db.refresh(db_log)
        return db_log
