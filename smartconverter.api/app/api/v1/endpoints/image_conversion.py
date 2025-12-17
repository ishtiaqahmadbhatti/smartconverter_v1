"""
Image Conversion API Endpoints

This module provides API endpoints for various Image conversion operations.
"""

import os
import shutil
import logging
from typing import Optional, List
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse, JSONResponse
from app.models.schemas import ConversionResponse
from app.services.image_conversion_service import ImageConversionService
from app.services.file_service import FileService
from app.core.config import settings
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
    file: UploadFile,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    quality: int = 95
) -> ConversionResponse:
    """Helper to handle generic image conversion."""
    input_path = None
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
            
        # Log conversion
        ImageConversionService.log_conversion(
            tool_name,
            file.filename,
            f"Output: {output_filename}",
            True
        )
        
        return ConversionResponse(
            success=True,
            message=f"Image converted to {output_format.upper()} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        ImageConversionService.log_conversion(
            tool_name,
            file.filename if file else "Unknown",
            "",
            False,
            str(e)
        )
        raise create_error_response(
            error_type="InternalServerError",
            message=f"Conversion failed: {str(e)}",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


async def _handle_json_conversion(
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str],
    include_metadata: bool = True
) -> ConversionResponse:
    """Helper to handle image to json conversion."""
    input_path = None
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.image_to_json(input_path)
        
        output_filename = _determine_output_filename(user_filename, file, "image_to_json", ".json")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        ImageConversionService.log_conversion(tool_name, file.filename, output_filename, True)
        
        return ConversionResponse(
            success=True,
            message="Image converted to JSON successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, file.filename, "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


async def _handle_image_to_pdf(
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str],
    page_size: str = "A4"
) -> ConversionResponse:
    """Helper to handle image to pdf conversion."""
    input_path = None
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.image_to_pdf(input_path, page_size)
        
        output_filename = _determine_output_filename(user_filename, file, "image_to_pdf", ".pdf")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        ImageConversionService.log_conversion(tool_name, file.filename, output_filename, True)
        
        return ConversionResponse(
            success=True,
            message="Image converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, file.filename, "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


async def _handle_website_conversion(
    url: str,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    width: int,
    height: int
) -> ConversionResponse:
    """Helper to handle website conversion."""
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
            
        ImageConversionService.log_conversion(tool_name, url, output_filename, True)
        
        return ConversionResponse(
            success=True,
            message=f"Website converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, url, "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)


async def _handle_html_conversion(
    html_content: str,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    width: int,
    height: int
) -> ConversionResponse:
    """Helper to handle HTML conversion."""
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
            
        ImageConversionService.log_conversion(tool_name, "HTML Content", output_filename, True)
        
        return ConversionResponse(
            success=True,
            message=f"HTML converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, "HTML Content", "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)


async def _handle_pdf_conversion(
    file: UploadFile,
    output_format: str,
    tool_name: str,
    user_filename: Optional[str],
    dpi: int,
    page_number: int
) -> ConversionResponse:
    """Helper to handle PDF conversion."""
    input_path = None
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
            
        ImageConversionService.log_conversion(tool_name, file.filename, output_filename, True)
        
        return ConversionResponse(
            success=True,
            message=f"PDF page {page_number} converted to {output_format} successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, file.filename, "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


async def _handle_ai_conversion(
    file: UploadFile,
    tool_name: str,
    user_filename: Optional[str]
) -> ConversionResponse:
    """Helper for AI conversion."""
    input_path = None
    try:
        FileService.validate_file(file, "image")
        input_path = FileService.save_uploaded_file(file)
        
        service_output_path = ImageConversionService.ai_to_svg(input_path)
        
        output_filename = _determine_output_filename(user_filename, file, "converted", ".svg")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        ImageConversionService.log_conversion(tool_name, file.filename, output_filename, True)
        return ConversionResponse(
            success=True,
            message="AI converted to SVG successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion(tool_name, file.filename, "", False, str(e))
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
async def download_file(filename: str):
    """Download converted file."""
    file_path = os.path.join(settings.output_dir, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(path=file_path, filename=filename, media_type='application/octet-stream')

# ---------------------------------------------------------------------------
# Specific Format endpoints
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# 1. AI: Convert PNG to JSON
# ---------------------------------------------------------------------------
@router.post("/ai-png-to-json", response_model=ConversionResponse)
async def convert_ai_png_to_json(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """AI: Convert PNG to JSON."""
    return await _handle_json_conversion(file, "ai-png-to-json", filename)

# ---------------------------------------------------------------------------
# 2. AI: Convert JPG to JSON
# ---------------------------------------------------------------------------
@router.post("/ai-jpg-to-json", response_model=ConversionResponse)
async def convert_ai_jpg_to_json(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """AI: Convert JPG to JSON."""
    return await _handle_json_conversion(file, "ai-jpg-to-json", filename)

# ---------------------------------------------------------------------------
# 3. Convert JPG to PDF
# ---------------------------------------------------------------------------
@router.post("/jpg-to-pdf", response_model=ConversionResponse)
async def convert_jpg_to_pdf(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPG to PDF."""
    return await _handle_image_to_pdf(file, "jpg-to-pdf", filename)

# ---------------------------------------------------------------------------
# 4. Convert PNG to PDF
# ---------------------------------------------------------------------------
@router.post("/png-to-pdf", response_model=ConversionResponse)
async def convert_png_to_pdf(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to PDF."""
    return await _handle_image_to_pdf(file, "png-to-pdf", filename)

# ---------------------------------------------------------------------------
# 5. Convert Website to JPG
# ---------------------------------------------------------------------------
@router.post("/website-to-jpg", response_model=ConversionResponse)
async def convert_website_to_jpg(url: str = Form(...), filename: Optional[str] = Form(None)):
    """Convert Website to JPG."""
    return await _handle_website_conversion(url, "JPG", "website-to-jpg", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 6. Convert HTML to JPG
# ---------------------------------------------------------------------------
@router.post("/html-to-jpg", response_model=ConversionResponse)
async def convert_html_to_jpg(html_content: str = Form(...), filename: Optional[str] = Form(None)):
    """Convert HTML to JPG."""
    return await _handle_html_conversion(html_content, "JPG", "html-to-jpg", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 7. Convert Website to PNG
# ---------------------------------------------------------------------------
@router.post("/website-to-png", response_model=ConversionResponse)
async def convert_website_to_png(url: str = Form(...), filename: Optional[str] = Form(None)):
    """Convert Website to PNG."""
    return await _handle_website_conversion(url, "PNG", "website-to-png", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 8. Convert HTML to PNG
# ---------------------------------------------------------------------------
@router.post("/html-to-png", response_model=ConversionResponse)
async def convert_html_to_png(html_content: str = Form(...), filename: Optional[str] = Form(None)):
    """Convert HTML to PNG."""
    return await _handle_html_conversion(html_content, "PNG", "html-to-png", filename, 1920, 1080)

# ---------------------------------------------------------------------------
# 9. Convert PDF to JPG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-jpg", response_model=ConversionResponse)
async def convert_pdf_to_jpg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PDF to JPG."""
    return await _handle_pdf_conversion(file, "JPG", "pdf-to-jpg", filename, 300, 1)

# ---------------------------------------------------------------------------
# 10. Convert PDF to PNG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-png", response_model=ConversionResponse)
async def convert_pdf_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PDF to PNG."""
    return await _handle_pdf_conversion(file, "PNG", "pdf-to-png", filename, 300, 1)

# ---------------------------------------------------------------------------
# 11. Convert PDF to TIFF
# ---------------------------------------------------------------------------
@router.post("/pdf-to-tiff", response_model=ConversionResponse)
async def convert_pdf_to_tiff_alias_v2(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PDF to TIFF."""
    return await _handle_pdf_conversion(file, "TIFF", "pdf-to-tiff", filename, 300, 1)

# ---------------------------------------------------------------------------
# 12. Convert PDF to SVG
# ---------------------------------------------------------------------------
@router.post("/pdf-to-svg", response_model=ConversionResponse)
async def convert_pdf_to_svg_alias_v2(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PDF to SVG."""
    return await _handle_pdf_conversion(file, "SVG", "pdf-to-svg", filename, 300, 1)

# ---------------------------------------------------------------------------
# 13. Convert AI to SVG
# ---------------------------------------------------------------------------
@router.post("/ai-to-svg", response_model=ConversionResponse)
async def convert_ai_to_svg_alias_v2(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert AI to SVG."""
    return await _handle_ai_conversion(file, "ai-to-svg", filename)

# ---------------------------------------------------------------------------
# 14. Convert PNG to SVG
# ---------------------------------------------------------------------------
@router.post("/png-to-svg", response_model=ConversionResponse)
async def convert_png_to_svg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to SVG."""
    return await _handle_image_conversion(file, "SVG", "png-to-svg", filename)

# ---------------------------------------------------------------------------
# 15. Convert PNG to AVIF
# ---------------------------------------------------------------------------
@router.post("/png-to-avif", response_model=ConversionResponse)
async def convert_png_to_avif(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to AVIF."""
    return await _handle_image_conversion(file, "AVIF", "png-to-avif", filename)

# ---------------------------------------------------------------------------
# 16. Convert JPG to AVIF
# ---------------------------------------------------------------------------
@router.post("/jpg-to-avif", response_model=ConversionResponse)
async def convert_jpg_to_avif(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPG to AVIF."""
    return await _handle_image_conversion(file, "AVIF", "jpg-to-avif", filename)

# ---------------------------------------------------------------------------
# 17. Convert WebP to AVIF
# ---------------------------------------------------------------------------
@router.post("/webp-to-avif", response_model=ConversionResponse)
async def convert_webp_to_avif(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to AVIF."""
    return await _handle_image_conversion(file, "AVIF", "webp-to-avif", filename)

# ---------------------------------------------------------------------------
# 18. Convert AVIF to PNG
# ---------------------------------------------------------------------------
@router.post("/avif-to-png", response_model=ConversionResponse)
async def convert_avif_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert AVIF to PNG."""
    return await _handle_image_conversion(file, "PNG", "avif-to-png", filename)

# ---------------------------------------------------------------------------
# 19. Convert AVIF to JPEG
# ---------------------------------------------------------------------------
@router.post("/avif-to-jpeg", response_model=ConversionResponse)
async def convert_avif_to_jpeg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert AVIF to JPEG."""
    return await _handle_image_conversion(file, "JPEG", "avif-to-jpeg", filename)

# ---------------------------------------------------------------------------
# 20. Convert AVIF to WebP
# ---------------------------------------------------------------------------
@router.post("/avif-to-webp", response_model=ConversionResponse)
async def convert_avif_to_webp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert AVIF to WebP."""
    return await _handle_image_conversion(file, "WEBP", "avif-to-webp", filename)

# ---------------------------------------------------------------------------
# 21. Convert PNG to WebP
# ---------------------------------------------------------------------------
@router.post("/png-to-webp", response_model=ConversionResponse)
async def convert_png_to_webp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to WebP."""
    return await _handle_image_conversion(file, "WEBP", "png-to-webp", filename)

# ---------------------------------------------------------------------------
# 22. Convert JPG to WebP
# ---------------------------------------------------------------------------
@router.post("/jpg-to-webp", response_model=ConversionResponse)
async def convert_jpg_to_webp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPG to WebP."""
    return await _handle_image_conversion(file, "WEBP", "jpg-to-webp", filename)

# ---------------------------------------------------------------------------
# 23. Convert TIFF to WebP
# ---------------------------------------------------------------------------
@router.post("/tiff-to-webp", response_model=ConversionResponse)
async def convert_tiff_to_webp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert TIFF to WebP."""
    return await _handle_image_conversion(file, "WEBP", "tiff-to-webp", filename)

# ---------------------------------------------------------------------------
# 24. Convert GIF to WebP
# ---------------------------------------------------------------------------
@router.post("/gif-to-webp", response_model=ConversionResponse)
async def convert_gif_to_webp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert GIF to WebP."""
    return await _handle_image_conversion(file, "WEBP", "gif-to-webp", filename)

# ---------------------------------------------------------------------------
# 25. Convert WebP to PNG
# ---------------------------------------------------------------------------
@router.post("/webp-to-png", response_model=ConversionResponse)
async def convert_webp_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to PNG."""
    return await _handle_image_conversion(file, "PNG", "webp-to-png", filename)

# ---------------------------------------------------------------------------
# 26. Convert WebP to JPEG
# ---------------------------------------------------------------------------
@router.post("/webp-to-jpeg", response_model=ConversionResponse)
async def convert_webp_to_jpeg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to JPEG."""
    return await _handle_image_conversion(file, "JPEG", "webp-to-jpeg", filename)

# ---------------------------------------------------------------------------
# 27. Convert WebP to TIFF
# ---------------------------------------------------------------------------
@router.post("/webp-to-tiff", response_model=ConversionResponse)
async def convert_webp_to_tiff(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to TIFF."""
    return await _handle_image_conversion(file, "TIFF", "webp-to-tiff", filename)

# ---------------------------------------------------------------------------
# 28. Convert WebP to BMP
# ---------------------------------------------------------------------------
@router.post("/webp-to-bmp", response_model=ConversionResponse)
async def convert_webp_to_bmp(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to BMP."""
    return await _handle_image_conversion(file, "BMP", "webp-to-bmp", filename)

# ---------------------------------------------------------------------------
# 29. Convert WebP to YUV
# ---------------------------------------------------------------------------
@router.post("/webp-to-yuv", response_model=ConversionResponse)
async def convert_webp_to_yuv(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to YUV."""
    return await _handle_image_conversion(file, "YUV", "webp-to-yuv", filename)

# ---------------------------------------------------------------------------
# 30. Convert WebP to PAM
# ---------------------------------------------------------------------------
@router.post("/webp-to-pam", response_model=ConversionResponse)
async def convert_webp_to_pam(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to PAM."""
    return await _handle_image_conversion(file, "PAM", "webp-to-pam", filename)

# ---------------------------------------------------------------------------
# 31. Convert WebP to PGM
# ---------------------------------------------------------------------------
@router.post("/webp-to-pgm", response_model=ConversionResponse)
async def convert_webp_to_pgm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to PGM."""
    return await _handle_image_conversion(file, "PGM", "webp-to-pgm", filename)

# ---------------------------------------------------------------------------
# 32. Convert WebP to PPM
# ---------------------------------------------------------------------------
@router.post("/webp-to-ppm", response_model=ConversionResponse)
async def convert_webp_to_ppm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert WebP to PPM."""
    return await _handle_image_conversion(file, "PPM", "webp-to-ppm", filename)

# ---------------------------------------------------------------------------
# 33. Convert PNG to JPG
# ---------------------------------------------------------------------------
@router.post("/png-to-jpg", response_model=ConversionResponse)
async def convert_png_to_jpg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to JPG."""
    return await _handle_image_conversion(file, "JPG", "png-to-jpg", filename)

# ---------------------------------------------------------------------------
# 34. Convert PNG to PGM
# ---------------------------------------------------------------------------
@router.post("/png-to-pgm", response_model=ConversionResponse)
async def convert_png_to_pgm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to PGM."""
    return await _handle_image_conversion(file, "PGM", "png-to-pgm", filename)

# ---------------------------------------------------------------------------
# 35. Convert PNG to PPM
# ---------------------------------------------------------------------------
@router.post("/png-to-ppm", response_model=ConversionResponse)
async def convert_png_to_ppm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert PNG to PPM."""
    return await _handle_image_conversion(file, "PPM", "png-to-ppm", filename)

# ---------------------------------------------------------------------------
# 36. Convert JPG to PNG
# ---------------------------------------------------------------------------
@router.post("/jpg-to-png", response_model=ConversionResponse)
async def convert_jpg_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPG to PNG."""
    return await _handle_image_conversion(file, "PNG", "jpg-to-png", filename)

# ---------------------------------------------------------------------------
# 37. Convert JPEG to PGM
# ---------------------------------------------------------------------------
@router.post("/jpeg-to-pgm", response_model=ConversionResponse)
async def convert_jpeg_to_pgm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPEG to PGM."""
    return await _handle_image_conversion(file, "PGM", "jpeg-to-pgm", filename)

# ---------------------------------------------------------------------------
# 38. Convert JPEG to PPM
# ---------------------------------------------------------------------------
@router.post("/jpeg-to-ppm", response_model=ConversionResponse)
async def convert_jpeg_to_ppm(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert JPEG to PPM."""
    return await _handle_image_conversion(file, "PPM", "jpeg-to-ppm", filename)

# ---------------------------------------------------------------------------
# 39. Convert HEIC to PNG
# ---------------------------------------------------------------------------
@router.post("/heic-to-png", response_model=ConversionResponse)
async def convert_heic_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert HEIC to PNG."""
    return await _handle_image_conversion(file, "PNG", "heic-to-png", filename)

# ---------------------------------------------------------------------------
# 40. Convert HEIC to JPG
# ---------------------------------------------------------------------------
@router.post("/heic-to-jpg", response_model=ConversionResponse)
async def convert_heic_to_jpg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert HEIC to JPG."""
    return await _handle_image_conversion(file, "JPG", "heic-to-jpg", filename)

# ---------------------------------------------------------------------------
# 41. Convert SVG to PNG
# ---------------------------------------------------------------------------
@router.post("/svg-to-png", response_model=ConversionResponse)
async def convert_svg_to_png(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert SVG to PNG."""
    return await _handle_image_conversion(file, "PNG", "svg-to-png", filename)

# ---------------------------------------------------------------------------
# 42. Convert SVG to JPG
# ---------------------------------------------------------------------------
@router.post("/svg-to-jpg", response_model=ConversionResponse)
async def convert_svg_to_jpg(file: UploadFile = File(...), filename: Optional[str] = Form(None)):
    """Convert SVG to JPG."""
    return await _handle_image_conversion(file, "JPG", "svg-to-jpg", filename)

# ---------------------------------------------------------------------------
# 43. Remove EXIF Data
# ---------------------------------------------------------------------------
@router.post("/remove-exif", response_model=ConversionResponse)
async def remove_exif_data(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Remove EXIF data."""
    input_path = None
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
            
        ImageConversionService.log_conversion("remove-exif", file.filename, output_filename, True)
        return ConversionResponse(
            success=True,
            message="EXIF data removed successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ImageConversionService.log_conversion("remove-exif", file.filename, "", False, str(e))
        raise create_error_response("InternalServerError", str(e), status_code=500)
    finally:
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)
