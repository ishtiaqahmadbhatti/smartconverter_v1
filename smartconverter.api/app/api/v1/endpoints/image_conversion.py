"""
Image Conversion API Endpoints

This module provides API endpoints for various Image conversion operations.
"""

import os
import shutil
import logging
from typing import Optional, List
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy.orm import Session
from app.models.schemas import ConversionResponse
from app.services.image_conversion_service import ImageConversionService
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

def _build_download_url(filename: str) -> str:
    """Build consistent download url for generated files."""
    return f"/api/v1/imageconversiontools/download/{filename}"

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

async def _handle_image_conversion(
    request: Request,
    db: Session,
    file: UploadFile,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    quality: int = 95
) -> ConversionResponse:
    """Helper to handle generic image conversion."""
    input_path = None
    
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
        conversion_type=tool_name,
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="image",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    success = False
    try:
        # Validate file
        FileService.validate_file(file, "image")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert image format via Service (returns path to temp output)
        service_output_path = ImageConversionService.convert_image_format(
            input_path, output_format.upper(), quality
        )
        
        # Determine final filename and path
        output_filename = _determine_output_filename(
            user_filename, file, f"converted_{output_format.lower()}", f".{output_format.lower()}"
        )
        output_path = os.path.join(settings.output_dir, output_filename)
        
        # Move/Copy service output to final destination
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type=output_format.lower()
        )
        
        success = True
        return ConversionResponse(
            success=True,
            message=f"Image converted to {output_format.upper()} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message=f"Conversion failed: {str(e)}",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files: always clean input, clean output ONLY on failure
        FileService.cleanup_files(input_path, None if success else (output_path if 'output_path' in locals() else None))


async def _handle_json_conversion(
    request: Request,
    db: Session,
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str],
    include_metadata: bool = True
) -> ConversionResponse:
    """Helper to handle image to json conversion."""
    input_path = None
    
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
        conversion_type=tool_name,
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="image",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    success = False
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.image_to_json(input_path)
        
        output_filename = _determine_output_filename(user_filename, file, "image_to_json", ".json")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="json"
        )
        
        success = True
        return ConversionResponse(
            success=True,
            message="Image converted to JSON successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        FileService.cleanup_files(input_path, None if success else (output_path if 'output_path' in locals() else None))


async def _handle_image_to_pdf(
    request: Request,
    db: Session,
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str],
    page_size: str = "A4"
) -> ConversionResponse:
    """Helper to handle image to pdf conversion."""
    input_path = None
    
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
        conversion_type=tool_name,
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="image",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    success = False
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.image_to_pdf(input_path, page_size)
        
        output_filename = _determine_output_filename(user_filename, file, "image_to_pdf", ".pdf")
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
        
        success = True
        return ConversionResponse(
            success=True,
            message="Image converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        FileService.cleanup_files(input_path, None if success else (output_path if 'output_path' in locals() else None))


async def _handle_website_conversion(
    request: Request,
    db: Session,
    url: str,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    width: int,
    height: int
) -> ConversionResponse:
    """Helper to handle website conversion."""
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type=tool_name,
        input_filename=url,
        input_file_size=0, # URL doesn't have an easily determined size beforehand
        input_file_type="url",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        service_output_path = ImageConversionService.website_to_image(
            url, output_format.upper(), width, height
        )
        
        default_base = f"website_{url.replace('://', '_').replace('/', '_')}"
        output_filename = _determine_output_filename(
            user_filename, None, default_base[:50], f".{output_format.lower()}"
        )
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type=output_format.lower()
        )
        
        return ConversionResponse(
            success=True,
            message=f"Website converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)


async def _handle_html_conversion(
    request: Request,
    db: Session,
    html_content: str,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    width: int,
    height: int
) -> ConversionResponse:
    """Helper to handle HTML conversion."""
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type=tool_name,
        input_filename="HTML Content",
        input_file_size=len(html_content),
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        service_output_path = ImageConversionService.html_to_image(
            html_content, output_format.upper(), width, height
        )
        
        output_filename = _determine_output_filename(
            user_filename, None, "html_content", f".{output_format.lower()}"
        )
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type=output_format.lower()
        )
            
        return ConversionResponse(
            success=True,
            message=f"HTML converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)


async def _handle_pdf_conversion(
    request: Request,
    db: Session,
    file: UploadFile,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    dpi: int,
    page_number: int
) -> ConversionResponse:
    """Helper to handle PDF conversion."""
    input_path = None
    
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
        conversion_type=tool_name,
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "pdf")
        input_path = FileService.save_uploaded_file(file)
        
        if output_format == "SVG":
            service_output_path = ImageConversionService.pdf_to_svg(input_path, dpi, page_number)
        else:
            service_output_path = ImageConversionService.pdf_to_image(
                input_path, output_format.upper(), dpi, page_number
            )
        
        output_filename = _determine_output_filename(
            user_filename, file, f"page_{page_number}", f".{output_format.lower()}"
        )
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type=output_format.lower()
        )
        
        return ConversionResponse(
            success=True,
            message=f"PDF page {page_number} converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


async def _handle_ai_conversion(
    request: Request,
    db: Session,
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str]
) -> ConversionResponse:
    """Helper for AI conversion."""
    input_path = None
    
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
        conversion_type=tool_name,
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="ai",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "ai")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.ai_to_svg(input_path)
        
        output_filename = _determine_output_filename(user_filename, file, "converted", ".svg")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="svg"
        )
        return ConversionResponse(
            success=True,
            message="AI converted to SVG successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


# ---------------------------------------------------------------------------
# Core Endpoints
# ---------------------------------------------------------------------------

@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported inputs/outputs."""
    return {
        "success": True, 
        "formats": ImageConversionService.get_supported_formats(),
        "message": "Supported formats retrieved successfully"
    }

@router.get("/download/{filename}")
async def download_file(filename: str, background_tasks: BackgroundTasks):
    """Download converted file and clean up."""
    file_path = os.path.join(settings.output_dir, filename)
    return FileService.create_cleanup_response(file_path, filename, background_tasks)

# ---------------------------------------------------------------------------
# Specific Format endpoints
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# 1. AI: Convert PNG to JSON
# ---------------------------------------------------------------------------
@router.post("/ai-png-to-json", response_model=ConversionResponse)
async def convert_ai_png_to_json(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert PNG to JSON."""
    return await _handle_json_conversion(request, db, file, "ai-png-to-json", filename)

# ---------------------------------------------------------------------------
# 2. AI: Convert JPG to JSON
# ---------------------------------------------------------------------------
@router.post("/ai-jpg-to-json", response_model=ConversionResponse)
async def convert_ai_jpg_to_json(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert JPG to JSON."""
    return await _handle_json_conversion(request, db, file, "ai-jpg-to-json", filename)

# ---------------------------------------------------------------------------
# 3. Convert JPG to PDF
# ---------------------------------------------------------------------------
@router.post("/jpg-to-pdf", response_model=ConversionResponse)
async def convert_jpg_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG to PDF."""
    return await _handle_image_to_pdf(request, db, file, "jpg-to-pdf", filename)

# ---------------------------------------------------------------------------
# 4. Convert PNG to PDF
# ---------------------------------------------------------------------------
@router.post("/png-to-pdf", response_model=ConversionResponse)
async def convert_png_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to PDF."""
    return await _handle_image_to_pdf(request, db, file, "png-to-pdf", filename)

# ---------------------------------------------------------------------------
# 5. Convert Website to JPG
# ---------------------------------------------------------------------------
@router.post("/website-to-jpg", response_model=ConversionResponse)
async def convert_website_to_jpg(
    request: Request,
    url: str = Form(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Website to JPG."""
    return await _handle_website_conversion(request, db, url, "JPG", "website-to-jpg", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 6. Convert HTML to JPG
# ---------------------------------------------------------------------------
@router.post("/html-to-jpg", response_model=ConversionResponse)
async def convert_html_to_jpg(
    request: Request,
    html_content: str = Form(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HTML to JPG."""
    return await _handle_html_conversion(request, db, html_content, "JPG", "html-to-jpg", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 7. Convert Website to PNG
# ---------------------------------------------------------------------------
@router.post("/website-to-png", response_model=ConversionResponse)
async def convert_website_to_png(
    request: Request,
    url: str = Form(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Website to PNG."""
    return await _handle_website_conversion(request, db, url, "PNG", "website-to-png", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 8. Convert HTML to PNG
# ---------------------------------------------------------------------------
@router.post("/html-to-png", response_model=ConversionResponse)
async def convert_html_to_png(
    request: Request,
    html_content: str = Form(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HTML to PNG."""
    return await _handle_html_conversion(request, db, html_content, "PNG", "html-to-png", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 9. Convert PDF to JPG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-jpg", response_model=ConversionResponse)
async def convert_pdf_to_jpg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to JPG."""
    return await _handle_pdf_conversion(request, db, file, "JPG", "pdf-to-jpg", filename, 300, 1)

# ---------------------------------------------------------------------------
# 10. Convert PDF to PNG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-png", response_model=ConversionResponse)
async def convert_pdf_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to PNG."""
    return await _handle_pdf_conversion(request, db, file, "PNG", "pdf-to-png", filename, 300, 1)

# ---------------------------------------------------------------------------
# 11. Convert PDF to TIFF
# ---------------------------------------------------------------------------
@router.post("/pdf-to-tiff", response_model=ConversionResponse)
async def convert_pdf_to_tiff_alias_v2(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to TIFF."""
    return await _handle_pdf_conversion(request, db, file, "TIFF", "pdf-to-tiff", filename, 300, 1)

# ---------------------------------------------------------------------------
# 12. Convert PDF to SVG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-svg", response_model=ConversionResponse)
async def convert_pdf_to_svg_alias_v2(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to SVG."""
    return await _handle_pdf_conversion(request, db, file, "SVG", "pdf-to-svg", filename, 300, 1)

# ---------------------------------------------------------------------------
# 13. Convert AI to SVG
# ---------------------------------------------------------------------------
@router.post("/ai-to-svg", response_model=ConversionResponse)
async def convert_ai_to_svg_alias_v2(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AI to SVG."""
    return await _handle_ai_conversion(request, db, file, "ai-to-svg", filename)

# ---------------------------------------------------------------------------
# 14. Convert PNG to SVG
# ---------------------------------------------------------------------------
@router.post("/png-to-svg", response_model=ConversionResponse)
async def convert_png_to_svg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to SVG."""
    return await _handle_image_conversion(request, db, file, "SVG", "png-to-svg", filename)

# ---------------------------------------------------------------------------
# 15. Convert PNG to AVIF
# ---------------------------------------------------------------------------
@router.post("/png-to-avif", response_model=ConversionResponse)
async def convert_png_to_avif(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to AVIF."""
    return await _handle_image_conversion(request, db, file, "AVIF", "png-to-avif", filename)

# ---------------------------------------------------------------------------
# 16. Convert JPG to AVIF
# ---------------------------------------------------------------------------
@router.post("/jpg-to-avif", response_model=ConversionResponse)
async def convert_jpg_to_avif(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG to AVIF."""
    return await _handle_image_conversion(request, db, file, "AVIF", "jpg-to-avif", filename)

# ---------------------------------------------------------------------------
# 17. Convert WebP to AVIF
# ---------------------------------------------------------------------------
@router.post("/webp-to-avif", response_model=ConversionResponse)
async def convert_webp_to_avif(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to AVIF."""
    return await _handle_image_conversion(request, db, file, "AVIF", "webp-to-avif", filename)

# ---------------------------------------------------------------------------
# 18. Convert AVIF to PNG
# ---------------------------------------------------------------------------
@router.post("/avif-to-png", response_model=ConversionResponse)
async def convert_avif_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AVIF to PNG."""
    return await _handle_image_conversion(request, db, file, "PNG", "avif-to-png", filename)

# ---------------------------------------------------------------------------
# 19. Convert AVIF to JPEG
# ---------------------------------------------------------------------------
@router.post("/avif-to-jpeg", response_model=ConversionResponse)
async def convert_avif_to_jpeg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AVIF to JPEG."""
    return await _handle_image_conversion(request, db, file, "JPEG", "avif-to-jpeg", filename)

# ---------------------------------------------------------------------------
# 20. Convert AVIF to WebP
# ---------------------------------------------------------------------------
@router.post("/avif-to-webp", response_model=ConversionResponse)
async def convert_avif_to_webp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AVIF to WebP."""
    return await _handle_image_conversion(request, db, file, "WEBP", "avif-to-webp", filename)

# ---------------------------------------------------------------------------
# 21. Convert PNG to WebP
# ---------------------------------------------------------------------------
@router.post("/png-to-webp", response_model=ConversionResponse)
async def convert_png_to_webp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to WebP."""
    return await _handle_image_conversion(request, db, file, "WEBP", "png-to-webp", filename)

# ---------------------------------------------------------------------------
# 22. Convert JPG to WebP
# ---------------------------------------------------------------------------
@router.post("/jpg-to-webp", response_model=ConversionResponse)
async def convert_jpg_to_webp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG to WebP."""
    return await _handle_image_conversion(request, db, file, "WEBP", "jpg-to-webp", filename)

# ---------------------------------------------------------------------------
# 23. Convert TIFF to WebP
# ---------------------------------------------------------------------------
@router.post("/tiff-to-webp", response_model=ConversionResponse)
async def convert_tiff_to_webp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert TIFF to WebP."""
    return await _handle_image_conversion(request, db, file, "WEBP", "tiff-to-webp", filename)

# ---------------------------------------------------------------------------
# 24. Convert GIF to WebP
# ---------------------------------------------------------------------------
@router.post("/gif-to-webp", response_model=ConversionResponse)
async def convert_gif_to_webp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert GIF to WebP."""
    return await _handle_image_conversion(request, db, file, "WEBP", "gif-to-webp", filename)

# ---------------------------------------------------------------------------
# 25. Convert WebP to PNG
# ---------------------------------------------------------------------------
@router.post("/webp-to-png", response_model=ConversionResponse)
async def convert_webp_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to PNG."""
    return await _handle_image_conversion(request, db, file, "PNG", "webp-to-png", filename)

# ---------------------------------------------------------------------------
# 26. Convert WebP to JPEG
# ---------------------------------------------------------------------------
@router.post("/webp-to-jpeg", response_model=ConversionResponse)
async def convert_webp_to_jpeg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to JPEG."""
    return await _handle_image_conversion(request, db, file, "JPEG", "webp-to-jpeg", filename)

# ---------------------------------------------------------------------------
# 27. Convert WebP to TIFF
# ---------------------------------------------------------------------------
@router.post("/webp-to-tiff", response_model=ConversionResponse)
async def convert_webp_to_tiff(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to TIFF."""
    return await _handle_image_conversion(request, db, file, "TIFF", "webp-to-tiff", filename)

# ---------------------------------------------------------------------------
# 28. Convert WebP to BMP
# ---------------------------------------------------------------------------
@router.post("/webp-to-bmp", response_model=ConversionResponse)
async def convert_webp_to_bmp(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to BMP."""
    return await _handle_image_conversion(request, db, file, "BMP", "webp-to-bmp", filename)

# ---------------------------------------------------------------------------
# 29. Convert WebP to YUV
# ---------------------------------------------------------------------------
@router.post("/webp-to-yuv", response_model=ConversionResponse)
async def convert_webp_to_yuv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to YUV."""
    return await _handle_image_conversion(request, db, file, "YUV", "webp-to-yuv", filename)

# ---------------------------------------------------------------------------
# 30. Convert WebP to PAM
# ---------------------------------------------------------------------------
@router.post("/webp-to-pam", response_model=ConversionResponse)
async def convert_webp_to_pam(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to PAM."""
    return await _handle_image_conversion(request, db, file, "PAM", "webp-to-pam", filename)

# ---------------------------------------------------------------------------
# 31. Convert WebP to PGM
# ---------------------------------------------------------------------------
@router.post("/webp-to-pgm", response_model=ConversionResponse)
async def convert_webp_to_pgm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to PGM."""
    return await _handle_image_conversion(request, db, file, "PGM", "webp-to-pgm", filename)

# ---------------------------------------------------------------------------
# 32. Convert WebP to PPM
# ---------------------------------------------------------------------------
@router.post("/webp-to-ppm", response_model=ConversionResponse)
async def convert_webp_to_ppm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert WebP to PPM."""
    return await _handle_image_conversion(request, db, file, "PPM", "webp-to-ppm", filename)

# ---------------------------------------------------------------------------
# 33. Convert PNG to JPG
# ---------------------------------------------------------------------------
@router.post("/png-to-jpg", response_model=ConversionResponse)
async def convert_png_to_jpg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to JPG."""
    return await _handle_image_conversion(request, db, file, "JPG", "png-to-jpg", filename)

# ---------------------------------------------------------------------------
# 34. Convert PNG to PGM
# ---------------------------------------------------------------------------
@router.post("/png-to-pgm", response_model=ConversionResponse)
async def convert_png_to_pgm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to PGM."""
    return await _handle_image_conversion(request, db, file, "PGM", "png-to-pgm", filename)

# ---------------------------------------------------------------------------
# 35. Convert PNG to PPM
# ---------------------------------------------------------------------------
@router.post("/png-to-ppm", response_model=ConversionResponse)
async def convert_png_to_ppm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG to PPM."""
    return await _handle_image_conversion(request, db, file, "PPM", "png-to-ppm", filename)

# ---------------------------------------------------------------------------
# 36. Convert JPG to PNG
# ---------------------------------------------------------------------------
@router.post("/jpg-to-png", response_model=ConversionResponse)
async def convert_jpg_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG to PNG."""
    return await _handle_image_conversion(request, db, file, "PNG", "jpg-to-png", filename)

# ---------------------------------------------------------------------------
# 37. Convert JPEG to PGM
# ---------------------------------------------------------------------------
@router.post("/jpeg-to-pgm", response_model=ConversionResponse)
async def convert_jpeg_to_pgm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPEG to PGM."""
    return await _handle_image_conversion(request, db, file, "PGM", "jpeg-to-pgm", filename)

# ---------------------------------------------------------------------------
# 38. Convert JPEG to PPM
# ---------------------------------------------------------------------------
@router.post("/jpeg-to-ppm", response_model=ConversionResponse)
async def convert_jpeg_to_ppm(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPEG to PPM."""
    return await _handle_image_conversion(request, db, file, "PPM", "jpeg-to-ppm", filename)

# ---------------------------------------------------------------------------
# 39. Convert HEIC to PNG
# ---------------------------------------------------------------------------
@router.post("/heic-to-png", response_model=ConversionResponse)
async def convert_heic_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HEIC to PNG."""
    return await _handle_image_conversion(request, db, file, "PNG", "heic-to-png", filename)

# ---------------------------------------------------------------------------
# 40. Convert HEIC to JPG
# ---------------------------------------------------------------------------
@router.post("/heic-to-jpg", response_model=ConversionResponse)
async def convert_heic_to_jpg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HEIC to JPG."""
    return await _handle_image_conversion(request, db, file, "JPG", "heic-to-jpg", filename)

# ---------------------------------------------------------------------------
# 41. Convert SVG to PNG
# ---------------------------------------------------------------------------
@router.post("/svg-to-png", response_model=ConversionResponse)
async def convert_svg_to_png(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SVG to PNG."""
    return await _handle_image_conversion(request, db, file, "PNG", "svg-to-png", filename)

# ---------------------------------------------------------------------------
# 42. Convert SVG to JPG
# ---------------------------------------------------------------------------
@router.post("/svg-to-jpg", response_model=ConversionResponse)
async def convert_svg_to_jpg(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SVG to JPG."""
    return await _handle_image_conversion(request, db, file, "JPG", "svg-to-jpg", filename)

# ---------------------------------------------------------------------------
# 43. Remove EXIF Data
# ---------------------------------------------------------------------------
@router.post("/remove-exif", response_model=ConversionResponse)
async def remove_exif_data(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Remove EXIF data."""
    input_path = None
    
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
        conversion_type="remove-exif",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="image",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.remove_exif_data(input_path)
        
        # Keep original extension
        ext = os.path.splitext(input_path)[1]
        output_filename = _determine_output_filename(filename, file, "no_exif", ext)
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type=ext.lstrip('.') if ext else "image"
        )
        
        return ConversionResponse(
            success=True,
            message="EXIF data removed successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)
