import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.ebook_conversion_service import EBookConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/markdown-to-epub", response_model=ConversionResponse)
async def convert_markdown_to_epub(
    file: UploadFile = File(...),
    title: str = Form("Converted Book"),
    author: str = Form("Unknown")
):
    """Convert Markdown file to ePUB format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Markdown to ePUB
        output_path = EBookConversionService.markdown_to_epub(input_path, title, author)
        
        return ConversionResponse(
            success=True,
            message="Markdown file converted to ePUB successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-mobi", response_model=ConversionResponse)
async def convert_epub_to_mobi(file: UploadFile = File(...)):
    """Convert ePUB file to MOBI format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert ePUB to MOBI
        output_path = EBookConversionService.epub_to_mobi(input_path)
        
        return ConversionResponse(
            success=True,
            message="ePUB file converted to MOBI successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-azw", response_model=ConversionResponse)
async def convert_epub_to_azw(file: UploadFile = File(...)):
    """Convert ePUB file to AZW format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert ePUB to AZW
        output_path = EBookConversionService.epub_to_azw(input_path)
        
        return ConversionResponse(
            success=True,
            message="ePUB file converted to AZW successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-epub", response_model=ConversionResponse)
async def convert_mobi_to_epub(file: UploadFile = File(...)):
    """Convert MOBI file to ePUB format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MOBI to ePUB
        output_path = EBookConversionService.mobi_to_epub(input_path)
        
        return ConversionResponse(
            success=True,
            message="MOBI file converted to ePUB successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-azw", response_model=ConversionResponse)
async def convert_mobi_to_azw(file: UploadFile = File(...)):
    """Convert MOBI file to AZW format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MOBI to AZW
        output_path = EBookConversionService.mobi_to_azw(input_path)
        
        return ConversionResponse(
            success=True,
            message="MOBI file converted to AZW successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-epub", response_model=ConversionResponse)
async def convert_azw_to_epub(file: UploadFile = File(...)):
    """Convert AZW file to ePUB format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AZW to ePUB
        output_path = EBookConversionService.azw_to_epub(input_path)
        
        return ConversionResponse(
            success=True,
            message="AZW file converted to ePUB successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-mobi", response_model=ConversionResponse)
async def convert_azw_to_mobi(file: UploadFile = File(...)):
    """Convert AZW file to MOBI format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AZW to MOBI
        output_path = EBookConversionService.azw_to_mobi(input_path)
        
        return ConversionResponse(
            success=True,
            message="AZW file converted to MOBI successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-pdf", response_model=ConversionResponse)
async def convert_epub_to_pdf(file: UploadFile = File(...)):
    """Convert ePUB file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert ePUB to PDF
        output_path = EBookConversionService.epub_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="ePUB file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-pdf", response_model=ConversionResponse)
async def convert_mobi_to_pdf(file: UploadFile = File(...)):
    """Convert MOBI file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MOBI to PDF
        output_path = EBookConversionService.mobi_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="MOBI file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-pdf", response_model=ConversionResponse)
async def convert_azw_to_pdf(file: UploadFile = File(...)):
    """Convert AZW file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AZW to PDF
        output_path = EBookConversionService.azw_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="AZW file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw3-to-pdf", response_model=ConversionResponse)
async def convert_azw3_to_pdf(file: UploadFile = File(...)):
    """Convert AZW3 file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AZW3 to PDF
        output_path = EBookConversionService.azw3_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="AZW3 file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/fb2-to-pdf", response_model=ConversionResponse)
async def convert_fb2_to_pdf(file: UploadFile = File(...)):
    """Convert FB2 file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert FB2 to PDF
        output_path = EBookConversionService.fb2_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="FB2 file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/fbz-to-pdf", response_model=ConversionResponse)
async def convert_fbz_to_pdf(file: UploadFile = File(...)):
    """Convert FBZ file to PDF format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert FBZ to PDF
        output_path = EBookConversionService.fbz_to_pdf(input_path)
        
        return ConversionResponse(
            success=True,
            message="FBZ file converted to PDF successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-epub", response_model=ConversionResponse)
async def convert_pdf_to_epub(file: UploadFile = File(...)):
    """Convert PDF file to ePUB format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to ePUB
        output_path = EBookConversionService.pdf_to_epub(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to ePUB successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-mobi", response_model=ConversionResponse)
async def convert_pdf_to_mobi(file: UploadFile = File(...)):
    """Convert PDF file to MOBI format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to MOBI
        output_path = EBookConversionService.pdf_to_mobi(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to MOBI successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-azw", response_model=ConversionResponse)
async def convert_pdf_to_azw(file: UploadFile = File(...)):
    """Convert PDF file to AZW format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to AZW
        output_path = EBookConversionService.pdf_to_azw(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to AZW successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-azw3", response_model=ConversionResponse)
async def convert_pdf_to_azw3(file: UploadFile = File(...)):
    """Convert PDF file to AZW3 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to AZW3
        output_path = EBookConversionService.pdf_to_azw3(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to AZW3 successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-fb2", response_model=ConversionResponse)
async def convert_pdf_to_fb2(file: UploadFile = File(...)):
    """Convert PDF file to FB2 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to FB2
        output_path = EBookConversionService.pdf_to_fb2(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to FB2 successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-fbz", response_model=ConversionResponse)
async def convert_pdf_to_fbz(file: UploadFile = File(...)):
    """Convert PDF file to FBZ format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to FBZ
        output_path = EBookConversionService.pdf_to_fbz(input_path)
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to FBZ successfully",
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input and output formats."""
    try:
        formats = EBookConversionService.get_supported_formats()
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
