from sqlalchemy.orm import Session
from app.models.user_conversion import UserConversionDetails
from typing import Optional, Any, List
from datetime import datetime
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
        output_file_type: Optional[str] = None,
        error_message: Optional[str] = None
    ) -> Optional[UserConversionDetails]:
        """
        Update an existing log entry with final status and results.
        """
        from app.core.config import settings
        db_log = db.query(UserConversionDetails).filter(UserConversionDetails.id == log_id).first()
        if not db_log:
            return None
        
        db_log.status = status
        if output_filename:
            db_log.output_filename = output_filename
            
            # If output_file_type not provided, try to get from filename
            if not output_file_type and "." in output_filename:
                db_log.output_file_type = output_filename.split(".")[-1].lower()
            else:
                db_log.output_file_type = output_file_type

            # Get size if not provided
            if not output_file_size:
                # Check both current directory and settings.output_dir
                possible_paths = [
                    output_filename,
                    os.path.join(settings.output_dir, output_filename)
                ]
                for path in possible_paths:
                    if os.path.exists(path):
                        db_log.output_file_size = os.path.getsize(path)
                        break
            else:
                db_log.output_file_size = output_file_size
        
        if error_message:
            db_log.error_message = error_message
            
        db.commit()
        db.refresh(db_log)
        return db_log
    @staticmethod
    def get_user_history(
        db: Session, 
        user_id: int, 
        skip: int = 0, 
        limit: int = 50,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None
    ) -> List[UserConversionDetails]:
        """
        Get conversion history for a specific user ID or guest (device user).
        Optional filtering by date range.
        """
        query = db.query(UserConversionDetails).filter(
            UserConversionDetails.user_id == user_id
        )
        
        if from_date:
            query = query.filter(UserConversionDetails.created_at >= from_date)
        if to_date:
            query = query.filter(UserConversionDetails.created_at <= to_date)
            
        return query.order_by(UserConversionDetails.created_at.desc()).offset(skip).limit(limit).all()

    @staticmethod
    def get_user_history_count(
        db: Session, 
        user_id: int,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None
    ) -> int:
        """
        Get the total count of conversion history records for a user.
        """
        query = db.query(UserConversionDetails).filter(
            UserConversionDetails.user_id == user_id
        )
        
        if from_date:
            query = query.filter(UserConversionDetails.created_at >= from_date)
        if to_date:
            query = query.filter(UserConversionDetails.created_at <= to_date)
            
        return query.count()

    @staticmethod
    def delete_log(db: Session, log_id: int, user_id: int) -> bool:
        """
        Delete a specific log entry if it belongs to the user.
        """
        db_log = db.query(UserConversionDetails).filter(
            UserConversionDetails.id == log_id,
            UserConversionDetails.user_id == user_id
        ).first()
        
        if not db_log:
            return False
            
        db.delete(db_log)
        db.commit()
        return True

    @staticmethod
    def clear_user_history(db: Session, user_id: int) -> int:
        """
        Clear all conversion history for a user.
        """
        count = db.query(UserConversionDetails).filter(
            UserConversionDetails.user_id == user_id
        ).delete()
        db.commit()
        return count
