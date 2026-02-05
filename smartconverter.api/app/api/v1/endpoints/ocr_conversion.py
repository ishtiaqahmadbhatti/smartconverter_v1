
import os
import shutil
import logging
from typing import Optional
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy.orm import Session
from app.models.schemas import ConversionResponse
from app.services.ocr_conversion_service import OCRConversionService
from app.services.conversion_log_service import ConversionLogService
from app.services.file_service import FileService
from app.core.config import settings
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)

router = APIRouter()
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------

def _determine_output_filename(
    user_filename: Optional[str],
    input_file: Optional[UploadFile],
    default_base: str,
    extension: str
) -> str:
    """
    Determine the output filename based on user input, uploaded file, or default.
    Ensures correct extension.
    """
    # Ensure extension starts with dot
    if not extension.startswith('.'):
        extension = f'.{extension}'

    if user_filename and user_filename.strip() and user_filename.lower() != "string":
        # Use user provided filename
        filename = user_filename.strip()
        if not filename.lower().endswith(extension.lower()):
            filename += extension
        return filename
    else:
        # Fallback to input file name or default
        base_name = default_base
        if input_file and input_file.filename:
            # Strip input extension
            base_name = os.path.splitext(input_file.filename)[0]
        
        return f"{base_name}{extension}"

# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/png-to-text", response_model=ConversionResponse)
async def convert_png_to_text(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG image to text using OCR."""
    input_path = None
    try:
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
            conversion_type="png-to-text",
            input_filename=file.filename,
            input_file_size=input_size,
            input_file_type="png",
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            api_endpoint=request.url.path
        )

        FileService.validate_file(file, "png")
        input_path = FileService.save_uploaded_file(file)
        
        extracted_text = OCRConversionService.extract_text_from_image(input_path, language, ocr_engine)
        
        # Save to file
        output_filename = _determine_output_filename(filename, file, "png_to_text", ".txt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(extracted_text)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="txt"
        )
            
        return ConversionResponse(
            success=True,
            message="PNG converted to text successfully",
            extracted_text=extracted_text,
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting PNG to text: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/jpg-to-text", response_model=ConversionResponse)
async def convert_jpg_to_text(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG image to text using OCR."""
    input_path = None
    try:
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
            conversion_type="jpg-to-text",
            input_filename=file.filename,
            input_file_size=input_size,
            input_file_type="jpg",
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            api_endpoint=request.url.path
        )

        FileService.validate_file(file, "jpg")
        input_path = FileService.save_uploaded_file(file)
        
        extracted_text = OCRConversionService.extract_text_from_image(input_path, language, ocr_engine)
        
        # Save to file
        output_filename = _determine_output_filename(filename, file, "jpg_to_text", ".txt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(extracted_text)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="txt"
        )
            
        return ConversionResponse(
            success=True,
            message="JPG converted to text successfully",
            extracted_text=extracted_text,
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting JPG to text: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/png-to-pdf", response_model=ConversionResponse)
async def convert_png_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG image to PDF with OCR text layer."""
    input_path = None
    service_output_path = None
    
    try:
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
            conversion_type="png-to-pdf",
            input_filename=file.filename,
            input_file_size=input_size,
            input_file_type="png",
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            api_endpoint=request.url.path
        )

        FileService.validate_file(file, "png")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = OCRConversionService.image_to_pdf_with_ocr(input_path, language, ocr_engine)
        
        output_filename = _determine_output_filename(filename, file, "png_to_pdf", ".pdf")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="pdf"
        )

        return ConversionResponse(
            success=True,
            message="PNG converted to PDF with OCR successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting PNG to PDF: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/jpg-to-pdf", response_model=ConversionResponse)
async def convert_jpg_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG image to PDF with OCR text layer."""
    input_path = None
    service_output_path = None
    
    try:
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
            conversion_type="jpg-to-pdf",
            input_filename=file.filename,
            input_file_size=input_size,
            input_file_type="jpg",
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            api_endpoint=request.url.path
        )

        FileService.validate_file(file, "jpg")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = OCRConversionService.image_to_pdf_with_ocr(input_path, language, ocr_engine)
        
        output_filename = _determine_output_filename(filename, file, "jpg_to_pdf", ".pdf")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="pdf"
        )
            
        return ConversionResponse(
            success=True,
            message="JPG converted to PDF with OCR successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting JPG to PDF: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-text", response_model=ConversionResponse)
async def convert_pdf_to_text(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to text using OCR."""
    input_path = None
    try:
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

        FileService.validate_file(file, "pdf")
        input_path = FileService.save_uploaded_file(file)
        
        extracted_text = OCRConversionService.pdf_to_text_with_ocr(input_path, language, ocr_engine)
        
        output_filename = _determine_output_filename(filename, file, "pdf_to_text", ".txt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(extracted_text)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="txt"
        )
            
        return ConversionResponse(
            success=True,
            message="PDF converted to text successfully",
            extracted_text=extracted_text,
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting PDF to text: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-image-to-pdf-text", response_model=ConversionResponse)
async def convert_pdf_image_to_pdf_text(
    request: Request,
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF with images to PDF with searchable text."""
    input_path = None
    service_output_path = None
    
    try:
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
            conversion_type="pdf-image-to-pdf-text",
            input_filename=file.filename,
            input_file_size=input_size,
            input_file_type="pdf",
            ip_address=request.client.host,
            user_agent=request.headers.get("user-agent"),
            api_endpoint=request.url.path
        )

        FileService.validate_file(file, "pdf")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = OCRConversionService.pdf_image_to_pdf_text(input_path, language, ocr_engine)
        
        output_filename = _determine_output_filename(filename, file, "searchable", ".pdf")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="pdf"
        )
            
        return ConversionResponse(
            success=True,
            message="PDF image converted to searchable PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ocrconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(type(e).__name__, str(e), 400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        logger.error(f"Error converting PDF image to text PDF: {str(e)}")
        raise create_error_response("InternalServerError", "An unexpected error occurred", 500, {"error": str(e)})
    finally:
        if input_path:
            OCRConversionService.cleanup_temp_files(input_path)


@router.get("/supported-languages")
async def get_supported_languages():
    """Get list of supported OCR languages."""
    try:
        languages = OCRConversionService.get_supported_languages()
        return {
            "success": True,
            "languages": languages,
            "message": "Supported languages retrieved successfully"
        }
    except Exception as e:
        raise create_error_response("InternalServerError", "Failed to retrieve supported languages", 500, {"error": str(e)})


@router.get("/supported-ocr-engines")
async def get_supported_ocr_engines():
    """Get list of supported OCR engines."""
    try:
        engines = OCRConversionService.get_supported_ocr_engines()
        return {
            "success": True,
            "engines": engines,
            "message": "Supported OCR engines retrieved successfully"
        }
    except Exception as e:
        raise create_error_response("InternalServerError", "Failed to retrieve supported OCR engines", 500, {"error": str(e)})


@router.get("/download/{filename}")
async def download_file(filename: str, background_tasks: BackgroundTasks):
    """Download converted file and clean up."""
    file_path = os.path.join(settings.output_dir, filename)
    return FileService.create_cleanup_response(file_path, filename, background_tasks)
