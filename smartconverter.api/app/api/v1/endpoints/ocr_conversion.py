import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.ocr_conversion_service import OCRConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/png-to-text", response_model=ConversionResponse)
async def convert_png_to_text(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert PNG image to text using OCR."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Extract text using OCR
        extracted_text = OCRConversionService.extract_text_from_image(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="PNG image converted to text successfully",
            extracted_text=extracted_text
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
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/jpg-to-text", response_model=ConversionResponse)
async def convert_jpg_to_text(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert JPG image to text using OCR."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Extract text using OCR
        extracted_text = OCRConversionService.extract_text_from_image(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="JPG image converted to text successfully",
            extracted_text=extracted_text
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
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/png-to-pdf", response_model=ConversionResponse)
async def convert_png_to_pdf(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert PNG image to PDF with OCR text layer."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PNG to PDF with OCR
        output_path = OCRConversionService.image_to_pdf_with_ocr(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="PNG image converted to PDF with OCR successfully",
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
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/jpg-to-pdf", response_model=ConversionResponse)
async def convert_jpg_to_pdf(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert JPG image to PDF with OCR text layer."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert JPG to PDF with OCR
        output_path = OCRConversionService.image_to_pdf_with_ocr(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="JPG image converted to PDF with OCR successfully",
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
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-text", response_model=ConversionResponse)
async def convert_pdf_to_text(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert PDF to text using OCR."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Extract text from PDF using OCR
        extracted_text = OCRConversionService.pdf_to_text_with_ocr(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="PDF converted to text using OCR successfully",
            extracted_text=extracted_text
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
            OCRConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-image-to-pdf-text", response_model=ConversionResponse)
async def convert_pdf_image_to_pdf_text(
    file: UploadFile = File(...),
    language: str = Form("eng"),
    ocr_engine: str = Form("tesseract")
):
    """Convert PDF with images to PDF with searchable text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF image to PDF text
        output_path = OCRConversionService.pdf_image_to_pdf_text(input_path, language, ocr_engine)
        
        return ConversionResponse(
            success=True,
            message="PDF image converted to PDF text successfully",
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
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported languages",
            details={"error": str(e)},
            status_code=500
        )


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
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported OCR engines",
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
