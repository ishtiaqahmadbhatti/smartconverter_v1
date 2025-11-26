import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.text_conversion_service import TextConversionService
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
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None)
):
    """Convert Word document to text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="document")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Word to text
        output_path = TextConversionService.word_to_text(input_path, output_filename=output_filename)
        
        return ConversionResponse(
            success=True,
            message="Word document converted to text successfully",
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/powerpoint-to-text", response_model=ConversionResponse)
async def convert_powerpoint_to_text(
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None)
):
    """Convert PowerPoint presentation to text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PowerPoint to text
        output_path = TextConversionService.powerpoint_to_text(input_path, output_filename=output_filename)
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to text successfully",
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-text", response_model=ConversionResponse)
async def convert_pdf_to_text(
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None)
):
    """Convert PDF document to text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to text
        output_path = TextConversionService.pdf_to_text(input_path, output_filename=output_filename)
        
        return ConversionResponse(
            success=True,
            message="PDF document converted to text successfully",
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/srt-to-text", response_model=ConversionResponse)
async def convert_srt_to_text(
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None)
):
    """Convert SRT subtitle file to text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert SRT to text
        output_path = TextConversionService.srt_to_text(input_path, output_filename=output_filename)
        
        return ConversionResponse(
            success=True,
            message="SRT subtitle file converted to text successfully",
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
            TextConversionService.cleanup_temp_files(input_path)


@router.post("/vtt-to-text", response_model=ConversionResponse)
async def convert_vtt_to_text(
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None)
):
    """Convert VTT subtitle file to text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, file_type="subtitle")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert VTT to text
        output_path = TextConversionService.vtt_to_text(input_path, output_filename=output_filename)
        
        return ConversionResponse(
            success=True,
            message="VTT subtitle file converted to text successfully",
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
