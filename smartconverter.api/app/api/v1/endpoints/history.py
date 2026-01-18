from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from app.core.database import get_db
from app.models.schemas import HistoryListResponse, HistoryItem, UserStatsResponse
from app.services.conversion_log_service import ConversionLogService
from app.api.v1.dependencies import get_user_id

router = APIRouter()

@router.get("/", response_model=HistoryListResponse)
async def get_history(
    request: Request,
    skip: int = 0,
    limit: int = 50,
    from_date: Optional[datetime] = None,
    to_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Fetch conversion history for the current user with optional date filtering."""
    user_id = await get_user_id(request, db)
    if not user_id:
        return HistoryListResponse(success=True, data=[], count=0)
    
    logs = ConversionLogService.get_user_history(
        db, user_id, skip, limit, from_date, to_date
    )
    
    history_items = []
    for log in logs:
        # Create dictionary from SQLAlchemy model
        log_data = {
            "id": log.id,
            "created_at": log.created_at,
            "conversion_type": log.conversion_type,
            "input_filename": log.input_filename,
            "input_file_size": log.input_file_size,
            "input_file_type": log.input_file_type,
            "output_filename": log.output_filename,
            "output_file_size": log.output_file_size,
            "output_file_type": log.output_file_type,
            "status": log.status,
            "error_message": log.error_message,
        }
        
        # Determine download_url logic
        if log.output_filename:
             if log.output_file_type in ['jpg', 'png', 'tiff', 'svg'] and log.conversion_type.startswith('pdf-to-'):
                  if log.output_filename and not "." in log.output_filename:
                      log_data["download_url"] = f"/download/{log.output_filename}/"
                  else:
                      log_data["download_url"] = f"/download/{log.output_filename}"
             else:
                  log_data["download_url"] = f"/download/{log.output_filename}"
        
        history_items.append(HistoryItem(**log_data))
        
    total_count = ConversionLogService.get_user_history_count(
        db, user_id, from_date, to_date
    )
    
    return HistoryListResponse(
        success=True,
        data=history_items,
        count=total_count
    )

@router.get("/stats", response_model=UserStatsResponse)
async def get_user_stats(
    request: Request,
    db: Session = Depends(get_db)
):
    """Fetch usage statistics for the current user."""
    user_id = await get_user_id(request, db)
    if not user_id:
        return UserStatsResponse(
            success=True,
            files_converted=0,
            data_processed_bytes=0,
            days_active=0
        )
    
    stats = ConversionLogService.get_user_stats(db, user_id)
    return UserStatsResponse(success=True, **stats)
