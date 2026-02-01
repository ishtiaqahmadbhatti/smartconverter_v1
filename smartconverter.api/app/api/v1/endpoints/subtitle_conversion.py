import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request
from fastapi.responses import FileResponse
from typing import Optional
from sqlalchemy.orm import Session
from app.models.schemas import ConversionResponse
from app.services.subtitle_conversion_service import SubtitleConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/translate-srt", response_model=ConversionResponse)
async def translate_srt(
    request: Request,
    file: UploadFile = File(...),
    target_language: str = Form("en"),
    source_language: str = Form("auto"),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Translate SRT subtitle file using AI translation."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="translate-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Translate SRT file
        output_path = SubtitleConversionService.translate_srt(input_path, target_language, source_language, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message=f"SRT file translated to {target_language} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-csv", response_model=ConversionResponse)
async def convert_srt_to_csv(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to CSV format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="srt-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert SRT to CSV
        output_path = SubtitleConversionService.srt_to_csv(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT file converted to CSV successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-excel", response_model=ConversionResponse)
async def convert_srt_to_excel(
    request: Request,
    file: UploadFile = File(...),
    format_type: str = Form("xlsx"),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to Excel format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="srt-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert SRT to Excel
        output_path = SubtitleConversionService.srt_to_excel(input_path, format_type, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type=format_type
        )
        
        return ConversionResponse(
            success=True,
            message=f"SRT file converted to {format_type.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-text", response_model=ConversionResponse)
async def convert_srt_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to plain text."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="srt-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert SRT to text
        output_path = SubtitleConversionService.srt_to_text(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT file converted to text successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-vtt", response_model=ConversionResponse)
async def convert_srt_to_vtt(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to VTT format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="srt-to-vtt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert SRT to VTT
        output_path = SubtitleConversionService.srt_to_vtt(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="vtt"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT file converted to VTT successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/vtt-to-text", response_model=ConversionResponse)
async def convert_vtt_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert VTT subtitle file to plain text."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="vtt-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="vtt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert VTT to text
        output_path = SubtitleConversionService.vtt_to_text(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="VTT file converted to text successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/vtt-to-srt", response_model=ConversionResponse)
async def convert_vtt_to_srt(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert VTT subtitle file to SRT format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="vtt-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="vtt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert VTT to SRT
        output_path = SubtitleConversionService.vtt_to_srt(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="VTT file converted to SRT successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/csv-to-srt", response_model=ConversionResponse)
async def convert_csv_to_srt(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert CSV subtitle file to SRT format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="csv-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="csv",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert CSV to SRT
        output_path = SubtitleConversionService.csv_to_srt(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="CSV file converted to SRT successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.post("/excel-to-srt", response_model=ConversionResponse)
async def convert_excel_to_srt(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel subtitle file to SRT format."""
    input_path = None
    output_path = None
    
    # Get file size
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="excel-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="excel",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to SRT
        output_path = SubtitleConversionService.excel_to_srt(input_path, output_filename=output_filename)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(output_path),
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to SRT successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            SubtitleConversionService.cleanup_temp_files(input_path)


@router.get("/supported-languages")
async def get_supported_languages():
    """Get list of supported translation languages."""
    try:
        languages = SubtitleConversionService.get_supported_languages()
        return {
            "success": True,
            "languages": languages,
            "message": "Supported languages retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported languages",
            details={"error": str(e)},
            status_code=500
        )


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input and output formats."""
    try:
        formats = SubtitleConversionService.get_supported_formats()
        return {
            "success": True,
            "formats": formats,
            "message": "Supported formats retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported formats",
            details={"error": str(e)},
            status_code=500
        )


@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    from app.core.config import settings
    import os
    
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
