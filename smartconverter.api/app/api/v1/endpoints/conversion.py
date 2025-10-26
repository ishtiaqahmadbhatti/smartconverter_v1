import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from fastapi.responses import FileResponse
from app.models.schemas import ConversionResponse, ConversionType
from app.services.file_service import FileService
from app.services.conversion_service import ConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)

router = APIRouter()


@router.post("/pdf-to-word", response_model=ConversionResponse)
async def convert_pdf_to_word(file: UploadFile = File(...)):
    """Convert PDF file to Word document."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Word
        output_path = ConversionService.pdf_to_word(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF converted to Word successfully",
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
            ConversionService.cleanup_temp_files(input_path)


@router.post("/word-to-pdf", response_model=ConversionResponse)
async def convert_word_to_pdf(file: UploadFile = File(...)):
    """Convert Word document to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Word to PDF
        output_path = ConversionService.word_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="Word document converted to PDF successfully",
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
            ConversionService.cleanup_temp_files(input_path)


@router.post("/image-to-text", response_model=ConversionResponse)
async def convert_image_to_text(file: UploadFile = File(...)):
    """Extract text from image using OCR."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Extract text from image
        extracted_text = ConversionService.image_to_text(input_path)
        
        return ConversionResponse(
            success=True,
            message="Text extracted from image successfully",
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
            ConversionService.cleanup_temp_files(input_path)


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


# NOTE: The previous video-to-audio endpoint has been removed per request.