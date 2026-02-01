import os
import shutil
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request
from fastapi.responses import FileResponse
from typing import Optional
from sqlalchemy.orm import Session
from app.models.schemas import ConversionResponse
from app.services.ebook_conversion_service import EBookConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.core.config import settings
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()

def _determine_output_filename(original_filename: str, provided_filename: Optional[str], target_extension: str) -> str:
    """
    Determine the final output filename.
    If provided_filename is set, use it (appending extension if needed).
    Otherwise, use the original_filename with the new extension.
    """
    # Normalize extension (remove leading dot if present)
    target_extension = target_extension.lstrip('.')
    
    if provided_filename and provided_filename.strip():
        filename = provided_filename.strip()
        # Ensure correct extension
        if not filename.lower().endswith(f".{target_extension}"):
            filename += f".{target_extension}"
        return filename
    
    # Fallback to original filename
    base_name = os.path.splitext(original_filename)[0]
    return f"{base_name}.{target_extension}"

@router.post("/markdown-to-epub", response_model=ConversionResponse)
async def convert_markdown_to_epub(
    request: Request,
    file: UploadFile = File(...),
    title: str = Form("Converted Book"),
    author: str = Form("Unknown"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Markdown file to ePUB format."""
    input_path = None
    output_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="markdown-to-epub",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="md",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "markdown")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, "epub")
        
        # Convert Markdown to ePUB
        temp_output_path = EBookConversionService.markdown_to_epub(input_path, title, author)
        
        # Move to final location with correct filename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="epub"
        )
        
        return ConversionResponse(
            success=True,
            message="Markdown file converted to ePUB successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
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
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-mobi", response_model=ConversionResponse)
async def convert_epub_to_mobi(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ePUB file to MOBI format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="epub-to-mobi",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="epub",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "epub")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "mobi")
        
        temp_output_path = EBookConversionService.epub_to_mobi(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="mobi"
        )
        
        return ConversionResponse(
            success=True,
            message="ePUB file converted to MOBI successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-azw", response_model=ConversionResponse)
async def convert_epub_to_azw(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ePUB file to AZW format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="epub-to-azw",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="epub",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "epub")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "azw")
        
        temp_output_path = EBookConversionService.epub_to_azw(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="azw"
        )
        
        return ConversionResponse(
            success=True,
            message="ePUB file converted to AZW successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-epub", response_model=ConversionResponse)
async def convert_mobi_to_epub(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert MOBI file to ePUB format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="mobi-to-epub",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="mobi",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "mobi")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "epub")
        
        temp_output_path = EBookConversionService.mobi_to_epub(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="epub"
        )
        
        return ConversionResponse(
            success=True,
            message="MOBI file converted to ePUB successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-azw", response_model=ConversionResponse)
async def convert_mobi_to_azw(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert MOBI file to AZW format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="mobi-to-azw",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="mobi",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "mobi")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "azw")
        
        temp_output_path = EBookConversionService.mobi_to_azw(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="azw"
        )
        
        return ConversionResponse(
            success=True,
            message="MOBI file converted to AZW successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-epub", response_model=ConversionResponse)
async def convert_azw_to_epub(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AZW file to ePUB format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="azw-to-epub",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="azw",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "azw")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "epub")
        
        temp_output_path = EBookConversionService.azw_to_epub(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="epub"
        )
        
        return ConversionResponse(
            success=True,
            message="AZW file converted to ePUB successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-mobi", response_model=ConversionResponse)
async def convert_azw_to_mobi(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AZW file to MOBI format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="azw-to-mobi",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="azw",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "azw")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "mobi")
        
        temp_output_path = EBookConversionService.azw_to_mobi(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="mobi"
        )
        
        return ConversionResponse(
            success=True,
            message="AZW file converted to MOBI successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/epub-to-pdf", response_model=ConversionResponse)
async def convert_epub_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ePUB file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="epub-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="epub",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "epub")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.epub_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="ePUB file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/mobi-to-pdf", response_model=ConversionResponse)
async def convert_mobi_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert MOBI file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="mobi-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="mobi",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "mobi")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.mobi_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="MOBI file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw-to-pdf", response_model=ConversionResponse)
async def convert_azw_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AZW file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="azw-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="azw",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "azw")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.azw_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="AZW file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/azw3-to-pdf", response_model=ConversionResponse)
async def convert_azw3_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert AZW3 file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="azw3-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="azw3",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "azw3")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.azw3_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="AZW3 file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/fb2-to-pdf", response_model=ConversionResponse)
async def convert_fb2_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert FB2 file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="fb2-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="fb2",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "fb2")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.fb2_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="FB2 file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/fbz-to-pdf", response_model=ConversionResponse)
async def convert_fbz_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert FBZ file to PDF format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="fbz-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="fbz",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        FileService.validate_file(file, "fbz")
        input_path = FileService.save_uploaded_file(file)
        output_filename = _determine_output_filename(file.filename, filename, "pdf")
        
        temp_output_path = EBookConversionService.fbz_to_pdf(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
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
            message="FBZ file converted to PDF successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-epub", response_model=ConversionResponse)
async def convert_pdf_to_epub(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to ePUB format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-epub",
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
        output_filename = _determine_output_filename(file.filename, filename, "epub")
        
        temp_output_path = EBookConversionService.pdf_to_epub(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="epub"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to ePUB successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-mobi", response_model=ConversionResponse)
async def convert_pdf_to_mobi(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to MOBI format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-mobi",
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
        output_filename = _determine_output_filename(file.filename, filename, "mobi")
        
        temp_output_path = EBookConversionService.pdf_to_mobi(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="mobi"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to MOBI successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-azw", response_model=ConversionResponse)
async def convert_pdf_to_azw(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to AZW format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-azw",
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
        output_filename = _determine_output_filename(file.filename, filename, "azw")
        
        temp_output_path = EBookConversionService.pdf_to_azw(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="azw"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to AZW successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-azw3", response_model=ConversionResponse)
async def convert_pdf_to_azw3(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to AZW3 format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-azw3",
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
        output_filename = _determine_output_filename(file.filename, filename, "azw3")
        
        temp_output_path = EBookConversionService.pdf_to_azw3(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="azw3"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to AZW3 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-fb2", response_model=ConversionResponse)
async def convert_pdf_to_fb2(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to FB2 format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-fb2",
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
        output_filename = _determine_output_filename(file.filename, filename, "fb2")
        
        temp_output_path = EBookConversionService.pdf_to_fb2(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="fb2"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to FB2 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.post("/pdf-to-fbz", response_model=ConversionResponse)
async def convert_pdf_to_fbz(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF file to FBZ format."""
    input_path = None
    
    # Get file info
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-fbz",
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
        output_filename = _determine_output_filename(file.filename, filename, "fbz")
        
        temp_output_path = EBookConversionService.pdf_to_fbz(input_path)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
            if os.path.exists(final_output_path):
                os.remove(final_output_path)
            shutil.move(temp_output_path, final_output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="fbz"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF file converted to FBZ successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/ebookconversiontools/download/{output_filename}"
        )
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type=type(e).__name__, message=str(e), status_code=400)
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(error_type="InternalServerError", message="An unexpected error occurred", details={"error": str(e)}, status_code=500)
    finally:
        if input_path:
            EBookConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get supported eBook conversion formats."""
    return EBookConversionService.get_supported_formats()


@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted eBook file."""
    file_path = os.path.join(settings.output_dir, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
