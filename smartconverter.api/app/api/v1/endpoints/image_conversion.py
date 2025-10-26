import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.image_conversion_service import ImageConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/convert-format", response_model=ConversionResponse)
async def convert_image_format(
    file: UploadFile = File(...),
    output_format: str = Form(...),
    quality: int = Form(95)
):
    """Convert image from one format to another."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert image format
        output_path = ImageConversionService.convert_image_format(
            input_path, output_format.upper(), quality
        )
        
        return ConversionResponse(
            success=True,
            message=f"Image converted to {output_format.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/image-to-json", response_model=ConversionResponse)
async def convert_image_to_json(
    file: UploadFile = File(...),
    include_metadata: bool = Form(True)
):
    """Convert image to JSON format with metadata and base64 encoding."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert image to JSON
        output_path = ImageConversionService.image_to_json(input_path, include_metadata)
        
        return ConversionResponse(
            success=True,
            message="Image converted to JSON successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/image-to-pdf", response_model=ConversionResponse)
async def convert_image_to_pdf(
    file: UploadFile = File(...),
    page_size: str = Form("A4")
):
    """Convert image to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert image to PDF
        output_path = ImageConversionService.image_to_pdf(input_path, page_size)
        
        return ConversionResponse(
            success=True,
            message="Image converted to PDF successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/website-to-image", response_model=ConversionResponse)
async def convert_website_to_image(
    url: str = Form(...),
    output_format: str = Form("PNG"),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert website to image."""
    output_path = None
    
    try:
        # Convert website to image
        output_path = ImageConversionService.website_to_image(
            url, output_format.upper(), width, height
        )
        
        return ConversionResponse(
            success=True,
            message=f"Website converted to {output_format.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


@router.post("/html-to-image", response_model=ConversionResponse)
async def convert_html_to_image(
    html_content: str = Form(...),
    output_format: str = Form("PNG"),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert HTML content to image."""
    output_path = None
    
    try:
        # Convert HTML to image
        output_path = ImageConversionService.html_to_image(
            html_content, output_format.upper(), width, height
        )
        
        return ConversionResponse(
            success=True,
            message=f"HTML converted to {output_format.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


@router.post("/pdf-to-image", response_model=ConversionResponse)
async def convert_pdf_to_image(
    file: UploadFile = File(...),
    output_format: str = Form("PNG"),
    dpi: int = Form(300),
    page_number: int = Form(1)
):
    """Convert PDF page to image."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to image
        output_path = ImageConversionService.pdf_to_image(
            input_path, output_format.upper(), dpi, page_number
        )
        
        return ConversionResponse(
            success=True,
            message=f"PDF page {page_number} converted to {output_format.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input and output formats."""
    try:
        formats = ImageConversionService.get_supported_formats()
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


@router.post("/pdf-to-tiff", response_model=ConversionResponse)
async def convert_pdf_to_tiff(
    file: UploadFile = File(...),
    dpi: int = Form(300),
    page_number: int = Form(1)
):
    """Convert PDF page to TIFF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to TIFF
        output_path = ImageConversionService.pdf_to_tiff(input_path, dpi, page_number)
        
        return ConversionResponse(
            success=True,
            message=f"PDF page {page_number} converted to TIFF successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-svg", response_model=ConversionResponse)
async def convert_pdf_to_svg(
    file: UploadFile = File(...),
    dpi: int = Form(300),
    page_number: int = Form(1)
):
    """Convert PDF page to SVG."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to SVG
        output_path = ImageConversionService.pdf_to_svg(input_path, dpi, page_number)
        
        return ConversionResponse(
            success=True,
            message=f"PDF page {page_number} converted to SVG successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/ai-to-svg", response_model=ConversionResponse)
async def convert_ai_to_svg(file: UploadFile = File(...)):
    """Convert AI (Adobe Illustrator) file to SVG."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AI to SVG
        output_path = ImageConversionService.ai_to_svg(input_path)
        
        return ConversionResponse(
            success=True,
            message="AI file converted to SVG successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


@router.post("/remove-exif", response_model=ConversionResponse)
async def remove_exif_data(file: UploadFile = File(...)):
    """Remove EXIF data from image."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Remove EXIF data
        output_path = ImageConversionService.remove_exif_data(input_path)
        
        return ConversionResponse(
            success=True,
            message="EXIF data removed successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            ImageConversionService.cleanup_temp_files(input_path)


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
