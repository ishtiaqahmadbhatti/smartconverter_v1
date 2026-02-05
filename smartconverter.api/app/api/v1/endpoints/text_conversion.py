import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request, BackgroundTasks
from fastapi.responses import FileResponse
from typing import Optional
from sqlalchemy.orm import Session
from app.models.schemas import ConversionResponse
from app.services.text_conversion_service import TextConversionService
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


@router.post("/word-to-text", response_model=ConversionResponse)
async def convert_word_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Word document to text."""
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
        conversion_type="word-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="word",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="document")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Word to text
        output_path = TextConversionService.word_to_text(input_path, output_filename=output_filename)
        
        result_filename = os.path.basename(output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="Word document converted to text successfully",
            output_filename=result_filename,
            download_url=f"/download/{result_filename}"
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/powerpoint-to-text", response_model=ConversionResponse)
async def convert_powerpoint_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint presentation to text."""
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
        conversion_type="powerpoint-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pptx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PowerPoint to text
        output_path = TextConversionService.powerpoint_to_text(input_path, output_filename=output_filename)
        
        result_filename = os.path.basename(output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to text successfully",
            output_filename=result_filename,
            download_url=f"/download/{result_filename}"
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-text", response_model=ConversionResponse)
async def convert_pdf_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF document to text."""
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
        conversion_type="pdf-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to text
        output_path = TextConversionService.pdf_to_text(input_path, output_filename=output_filename)
        
        result_filename = os.path.basename(output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF document converted to text successfully",
            output_filename=result_filename,
            download_url=f"/download/{result_filename}"
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-text", response_model=ConversionResponse)
async def convert_srt_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to text."""
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
        output_path = TextConversionService.srt_to_text(input_path, output_filename=output_filename)
        
        result_filename = os.path.basename(output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT subtitle file converted to text successfully",
            output_filename=result_filename,
            download_url=f"/download/{result_filename}"
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/vtt-to-text", response_model=ConversionResponse)
async def convert_vtt_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert VTT subtitle file to text."""
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
        output_path = TextConversionService.vtt_to_text(input_path, output_filename=output_filename)
        
        result_filename = os.path.basename(output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="txt"
        )
        
        return ConversionResponse(
            success=True,
            message="VTT subtitle file converted to text successfully",
            output_filename=result_filename,
            download_url=f"/download/{result_filename}"
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
            TextConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input formats."""
    try:
        formats = TextConversionService.get_supported_formats()
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
async def download_file(filename: str, background_tasks: BackgroundTasks):
    """Download converted file and clean up."""
    file_path = os.path.join(settings.output_dir, filename)
    return FileService.create_cleanup_response(file_path, filename, background_tasks)
