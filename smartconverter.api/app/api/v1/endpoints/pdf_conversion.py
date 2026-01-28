import os
import re
from typing import List, Optional
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends, Request
from fastapi.responses import FileResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.file_service import FileService
from app.services.pdf_conversion_service import PDFConversionService
from app.services.conversion_log_service import ConversionLogService
from app.api.v1.dependencies import get_current_user, get_user_id
from app.services.user_list_service import UserListService
from app.core.config import settings
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)

from PyPDF2 import PdfReader

router = APIRouter()


class PDFConversionResponse(BaseModel):
    """Response model for PDF conversion operations."""
    success: bool
    message: str
    output_filename: Optional[str] = None
    download_url: Optional[str] = None
    file_size_before: Optional[int] = None
    file_size_after: Optional[int] = None
    pages_processed: Optional[int] = None
    extracted_data: Optional[dict] = None


# AI: Convert PDF to JSON
@router.post("/pdf-to-json", response_model=PDFConversionResponse)
async def convert_pdf_to_json(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert PDF to JSON with structured data extraction."""
    input_path = None
    output_path = None
    
    # Init logs detail
    # Get size reliably
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id from token or device_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-json",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    
    try:
        # Validate file - only PDF files allowed
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_json"
        desired_name = (output_filename or original_name).strip() or "pdf_json"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".json",
        )
        
        # Convert PDF to JSON
        result_path = PDFConversionService.pdf_to_json(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="json"
        )

        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to JSON successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to Markdown
@router.post("/pdf-to-markdown", response_model=PDFConversionResponse)
async def convert_pdf_to_markdown(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert PDF to Markdown format."""
    input_path = None
    output_path = None
    
    # Init logs detail
    # Get size reliably
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id from token or device_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-markdown",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    
    try:
        # Validate file - only PDF files allowed
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_markdown"
        desired_name = (output_filename or original_name).strip() or "pdf_markdown"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".md",
        )
        
        # Convert PDF to Markdown
        result_path = PDFConversionService.pdf_to_markdown(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="md"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Markdown successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to CSV
@router.post("/pdf-to-csv-ai", response_model=PDFConversionResponse)
async def convert_pdf_to_csv(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert PDF to CSV format (extract tabular data)."""
    input_path = None
    output_path = None
    
    # Init logs detail
    # Get size reliably
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id from token or device_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_csv"
        desired_name = (output_filename or original_name).strip() or "pdf_csv"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".csv",
        )

        # Convert PDF to CSV
        result_path = PDFConversionService.pdf_to_csv(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="csv"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to Excel
@router.post("/pdf-to-excel-ai", response_model=PDFConversionResponse)
async def convert_pdf_to_excel(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """AI: Convert PDF to Excel format."""
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
        conversion_type="pdf-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_excel"
        desired_name = (output_filename or original_name).strip() or "pdf_excel"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".xlsx",
        )
        
        # Convert PDF to Excel
        result_path = PDFConversionService.pdf_to_excel(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="xlsx"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert HTML to PDF
@router.post("/html-to-pdf", response_model=PDFConversionResponse)
async def convert_html_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HTML to PDF."""
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
        conversion_type="html-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "document")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "html_document"
        desired_name = (output_filename or original_name).strip() or "html_document"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        # Convert HTML to PDF
        result_path = PDFConversionService.html_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="HTML converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Word to PDF
@router.post("/word-to-pdf", response_model=PDFConversionResponse)
async def convert_word_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Word document to PDF."""
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
        conversion_type="word-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="docx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "office")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Word to PDF
        # Determine desired output filename
        original_name = file.filename or "word_document"
        desired_name = (output_filename or original_name).strip() or "word_document"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.word_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Word document converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PowerPoint to PDF
@router.post("/powerpoint-to-pdf", response_model=PDFConversionResponse)
async def convert_powerpoint_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint to PDF."""
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
        conversion_type="powerpoint-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pptx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "office")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PowerPoint to PDF
        # Determine desired output filename
        original_name = file.filename or "powerpoint_document"
        desired_name = (output_filename or original_name).strip() or "powerpoint_document"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.powerpoint_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PowerPoint converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert OXPS to PDF
@router.post("/oxps-to-pdf", response_model=PDFConversionResponse)
async def convert_oxps_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert OXPS to PDF."""
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
        conversion_type="oxps-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="oxps",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "oxps")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Generate output path
        if output_filename:
            output_path, final_filename = FileService.generate_output_path_with_filename(output_filename, ".pdf")
        else:
            output_path = FileService.get_output_path(input_path, "_converted.pdf")
            final_filename = os.path.basename(output_path)
            
        # Convert OXPS to PDF
        result_path = PDFConversionService.oxps_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="OXPS converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert JPG to PDF
@router.post("/jpg-to-pdf", response_model=PDFConversionResponse)
async def convert_jpg_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JPG image to PDF."""
    input_path = None
    output_path = None
    final_filename = None
    
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
    
    try:
        # Validate file - only accept JPG/JPEG files
        FileService.validate_file(file, "jpg")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if output_filename:
            desired_name = output_filename
        else:
            # Use input file name (without extension) as base
            base_name = os.path.splitext(file.filename or "converted_image")[0]
            desired_name = base_name
        
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        
        # Convert JPG to PDF
        result_path = PDFConversionService.image_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="JPG image converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PNG to PDF
@router.post("/png-to-pdf", response_model=PDFConversionResponse)
async def convert_png_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PNG image to PDF."""
    input_path = None
    output_path = None
    final_filename = None
    
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
    
    try:
        # Validate file - only accept PNG files
        FileService.validate_file(file, "png")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if output_filename:
            desired_name = output_filename
        else:
            # Use input file name (without extension) as base
            base_name = os.path.splitext(file.filename or "converted_image")[0]
            desired_name = base_name
        
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        
        # Convert PNG to PDF
        result_path = PDFConversionService.image_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PNG image converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Markdown to PDF
@router.post("/markdown-to-pdf", response_model=PDFConversionResponse)
async def convert_markdown_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Markdown to PDF."""
    input_path = None
    output_path = None
    final_filename = None
    
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
        conversion_type="markdown-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="md",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file - only Markdown files allowed
        FileService.validate_file(file, "markdown")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if output_filename:
            desired_name = output_filename
        else:
            # Use input file name (without extension) as base
            base_name = os.path.splitext(file.filename or "converted_document")[0]
            desired_name = base_name
        
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        
        # Convert Markdown to PDF
        result_path = PDFConversionService.markdown_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Markdown converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Excel to PDF
@router.post("/excel-to-pdf", response_model=PDFConversionResponse)
async def convert_excel_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to PDF."""
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
        conversion_type="excel-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "office")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to PDF
        # Determine desired output filename
        original_name = file.filename or "excel_document"
        desired_name = (output_filename or original_name).strip() or "excel_document"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.excel_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Excel converted to PDF successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Excel to XPS
@router.post("/excel-to-xps", response_model=PDFConversionResponse)
async def convert_excel_to_xps(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to XPS."""
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
        conversion_type="excel-to-xps",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "office")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to XPS
        # Determine desired output filename
        original_name = file.filename or "excel_document"
        desired_name = (output_filename or original_name).strip() or "excel_document"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".xps",
        )
        result_path = PDFConversionService.excel_to_xps(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="xps"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Excel converted to XPS successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert OpenOffice Calc ODS to PDF
@router.post("/ods-to-pdf", response_model=PDFConversionResponse)
async def convert_ods_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Convert OpenOffice Calc ODS to PDF."""
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
        conversion_type="ods-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="ods",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert ODS to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.ods_to_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(result_path),
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="ODS converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to CSV
@router.post("/pdf-to-csv", response_model=PDFConversionResponse)
async def convert_pdf_to_csv_extract(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to CSV (extract tabular data)."""
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
        conversion_type="pdf-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_csv"
        desired_name = (output_filename or original_name).strip() or "pdf_csv"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".csv",
        )

        # Convert PDF to CSV
        result_path = PDFConversionService.pdf_to_csv_extract(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="csv"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Excel
@router.post("/pdf-to-excel", response_model=PDFConversionResponse)
async def convert_pdf_to_excel_extract(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to Excel (extract tabular data)."""
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
        conversion_type="pdf-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_excel"
        desired_name = (output_filename or original_name).strip() or "pdf_excel"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".xlsx",
        )
        
        # Convert PDF to Excel
        result_path = PDFConversionService.pdf_to_excel_extract(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="xlsx"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Word
@router.post("/pdf-to-word", response_model=PDFConversionResponse)
async def convert_pdf_to_word_extract(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to Word document."""
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
        conversion_type="pdf-to-word",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine desired output filename
        original_name = file.filename or "pdf_word"
        desired_name = (output_filename or original_name).strip() or "pdf_word"
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".docx",
        )
        
        # Convert PDF to Word
        result_path = PDFConversionService.pdf_to_word_extract(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=os.path.basename(result_path),
            output_file_type="docx"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Word successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to JPG
@router.post("/pdf-to-jpg", response_model=PDFConversionResponse)
async def convert_pdf_to_jpg(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """
    Convert PDF pages to JPG images.

    - Only PDF files are accepted.
    - Images are saved in a dedicated folder named from the input file (or custom base name).
    - Each image is named: `<base_name>_page_1.jpg`, `<base_name>_page_2.jpg`, ...
    """
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
        conversion_type="pdf-to-jpg",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file - only PDF allowed
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file (UUID-based internal name)
        input_path = FileService.save_uploaded_file(file)

        # Derive a safe base name from either custom name or original filename
        original_name = file.filename or "pdf_images"
        base_name, _ = os.path.splitext(original_name)
        # If user provided a custom name, use that as base; otherwise use input file name
        desired_base = (output_filename or base_name).strip()

        # Sanitize base name similar to FileService.generate_output_path_with_filename
        sanitized_base = re.sub(r"[^A-Za-z0-9._-]+", "_", desired_base).strip("._")
        if not sanitized_base:
            sanitized_base = "pdf_images"

        # Create a dedicated output folder under outputs/
        output_root = settings.output_dir
        os.makedirs(output_root, exist_ok=True)

        folder_name = sanitized_base
        folder_path = os.path.join(output_root, folder_name)
        counter = 1
        # Ensure we don't clash with an existing folder
        while os.path.exists(folder_path):
            folder_name = f"{sanitized_base}_{counter}"
            folder_path = os.path.join(output_root, folder_name)
            counter += 1

        os.makedirs(folder_path, exist_ok=True)
        
        # Convert PDF to JPG into that folder
        result_files = PDFConversionService.pdf_to_image(input_path, folder_path, "jpg")

        # Rename files to <folder_name>_page_1.jpg, <folder_name>_page_2.jpg, ...
        renamed_files = []
        for idx, src_path in enumerate(result_files, start=1):
            new_name = f"{folder_name}_page_{idx}.jpg"
            new_path = os.path.join(folder_path, new_name)
            try:
                os.replace(src_path, new_path)
            except Exception:
                # If rename fails for any reason, keep original name
                new_path = src_path
            renamed_files.append(new_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=folder_name,
            output_file_type="jpg"
        )
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(renamed_files)} JPG images",
            # Return the folder name as the logical "output identifier"
            output_filename=folder_name,
            # This points to the folder served by StaticFiles; individual files are inside it
            download_url=f"/download/{folder_name}/",
            pages_processed=len(renamed_files),
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to PNG
@router.post("/pdf-to-png", response_model=PDFConversionResponse)
async def convert_pdf_to_png(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF pages to PNG images.

    - Only PDF files are accepted.
    - Images are saved in a dedicated folder named from the input file (or custom base name).
    - Each image is named: `<base_name>_page_1.png`, `<base_name>_page_2.png`, ...
    """
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
        conversion_type="pdf-to-png",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Validate file - only PDF allowed
        FileService.validate_file(file, "pdf")

        # Save uploaded file (UUID-based internal name)
        input_path = FileService.save_uploaded_file(file)

        # Derive a safe base name from either custom name or original filename
        original_name = file.filename or "pdf_images"
        base_name, _ = os.path.splitext(original_name)
        # If user provided a custom name, use that as base; otherwise use input file name
        desired_base = (output_filename or base_name).strip()

        # Sanitize base name similar to FileService.generate_output_path_with_filename
        sanitized_base = re.sub(r"[^A-Za-z0-9._-]+", "_", desired_base).strip("._")
        if not sanitized_base:
            sanitized_base = "pdf_images"

        # Create a dedicated output folder under outputs/
        output_root = settings.output_dir
        os.makedirs(output_root, exist_ok=True)

        folder_name = sanitized_base
        folder_path = os.path.join(output_root, folder_name)
        counter = 1
        # Ensure we don't clash with an existing folder
        while os.path.exists(folder_path):
            folder_name = f"{sanitized_base}_{counter}"
            folder_path = os.path.join(output_root, folder_name)
            counter += 1

        os.makedirs(folder_path, exist_ok=True)

        # Convert PDF to PNG into that folder
        result_files = PDFConversionService.pdf_to_image(input_path, folder_path, "png")

        # Rename files to <folder_name>_page_1.png, <folder_name>_page_2.png, ...
        renamed_files = []
        for idx, src_path in enumerate(result_files, start=1):
            new_name = f"{folder_name}_page_{idx}.png"
            new_path = os.path.join(folder_path, new_name)
            try:
                os.replace(src_path, new_path)
            except Exception:
                # If rename fails for any reason, keep original name
                new_path = src_path
            renamed_files.append(new_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=folder_name,
            output_file_type="png"
        )

        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(renamed_files)} PNG images",
            # Return the folder name as the logical "output identifier"
            output_filename=folder_name,
            # This points to the folder served by StaticFiles; individual files are inside it
            download_url=f"/download/{folder_name}/",
            pages_processed=len(renamed_files),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        # Cleanup temporary files
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to TIFF
@router.post("/pdf-to-tiff", response_model=PDFConversionResponse)
async def convert_pdf_to_tiff(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF pages to TIFF images."""
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
        conversion_type="pdf-to-tiff",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Validate file - only PDF allowed
        FileService.validate_file(file, "pdf")

        # Save uploaded file (UUID-based internal name)
        input_path = FileService.save_uploaded_file(file)

        # Derive a safe base name from either custom name or original filename
        original_name = file.filename or "pdf_images"
        base_name, _ = os.path.splitext(original_name)
        desired_base = (output_filename or base_name).strip()

        sanitized_base = re.sub(r"[^A-Za-z0-9._-]+", "_", desired_base).strip("._")
        if not sanitized_base:
            sanitized_base = "pdf_images"

        # Create a dedicated output folder under outputs/
        output_root = settings.output_dir
        os.makedirs(output_root, exist_ok=True)

        folder_name = sanitized_base
        folder_path = os.path.join(output_root, folder_name)
        counter = 1
        while os.path.exists(folder_path):
            folder_name = f"{sanitized_base}_{counter}"
            folder_path = os.path.join(output_root, folder_name)
            counter += 1

        os.makedirs(folder_path, exist_ok=True)

        # Convert PDF to TIFF into that folder
        result_files = PDFConversionService.pdf_to_image(
            input_path, folder_path, "tiff"
        )

        # Rename files to <folder_name>_page_1.tiff, etc.
        renamed_files = []
        for idx, src_path in enumerate(result_files, start=1):
            new_name = f"{folder_name}_page_{idx}.tiff"
            new_path = os.path.join(folder_path, new_name)
            try:
                os.replace(src_path, new_path)
            except Exception:
                new_path = src_path
            renamed_files.append(new_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=folder_name,
            output_file_type="tiff"
        )

        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(renamed_files)} TIFF images",
            output_filename=folder_name,
            download_url=f"/download/{folder_name}/",
            pages_processed=len(renamed_files),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to SVG
@router.post("/pdf-to-svg", response_model=PDFConversionResponse)
async def convert_pdf_to_svg(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF pages to SVG files."""
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
        conversion_type="pdf-to-svg",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Validate file - only PDF allowed
        FileService.validate_file(file, "pdf")

        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)

        # Base name handling
        original_name = file.filename or "pdf_images"
        base_name, _ = os.path.splitext(original_name)
        desired_base = (output_filename or base_name).strip()

        sanitized_base = re.sub(r"[^A-Za-z0-9._-]+", "_", desired_base).strip("._")
        if not sanitized_base:
            sanitized_base = "pdf_images"

        output_root = settings.output_dir
        os.makedirs(output_root, exist_ok=True)

        folder_name = sanitized_base
        folder_path = os.path.join(output_root, folder_name)
        counter = 1
        while os.path.exists(folder_path):
            folder_name = f"{sanitized_base}_{counter}"
            folder_path = os.path.join(output_root, folder_name)
            counter += 1

        os.makedirs(folder_path, exist_ok=True)

        # Convert PDF to SVG into that folder
        result_files = PDFConversionService.pdf_to_svg(input_path, folder_path)

        renamed_files = []
        for idx, src_path in enumerate(result_files, start=1):
            new_name = f"{folder_name}_page_{idx}.svg"
            new_path = os.path.join(folder_path, new_name)
            try:
                os.replace(src_path, new_path)
            except Exception:
                new_path = src_path
            renamed_files.append(new_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=folder_name,
            output_file_type="svg"
        )

        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(renamed_files)} SVG files",
            output_filename=folder_name,
            download_url=f"/download/{folder_name}/",
            pages_processed=len(renamed_files),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to HTML
@router.post("/pdf-to-html", response_model=PDFConversionResponse)
async def convert_pdf_to_html(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to HTML."""
    input_path = None
    output_path = None
    final_filename = None
    
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
        conversion_type="pdf-to-html",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file - only PDF files allowed
        FileService.validate_file(file, "pdf")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if output_filename:
            desired_name = output_filename
        else:
            # Use input file name (without extension) as base
            base_name = os.path.splitext(file.filename or "converted_document")[0]
            desired_name = base_name
        
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".html",
        )
        
        # Convert PDF to HTML
        result_path = PDFConversionService.pdf_to_html(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="html"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to HTML successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Text
@router.post("/pdf-to-text", response_model=PDFConversionResponse)
async def convert_pdf_to_text(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to plain text."""
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
        conversion_type="pdf-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Validate file - only PDF allowed
        FileService.validate_file(file, "pdf")

        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)

        # Determine desired base name
        original_name = file.filename or "pdf_text"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or base_name).strip() or "pdf_text"

        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".txt",
        )

        # Convert PDF to Text
        result_path = PDFConversionService.pdf_to_text(input_path, output_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename or os.path.basename(result_path),
            output_file_type="txt"
        )

        return PDFConversionResponse(
            success=True,
            message="PDF converted to text successfully",
            output_filename=final_filename or os.path.basename(result_path),
            download_url=f"/download/{final_filename or os.path.basename(result_path)}",
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Get supported formats
@router.get("/supported-formats")
async def get_supported_formats():
    """Get supported input and output formats."""
    try:
        formats = PDFConversionService.get_supported_formats()
        return {
            "success": True,
            "formats": formats,
            "message": "Supported formats retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# PDF Merge
@router.post("/merge", response_model=PDFConversionResponse)
async def merge_pdfs(
    request: Request,
    files: List[UploadFile] = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Merge multiple PDF files into one."""
    input_paths = []
    output_path = None
    final_filename = None
    original_names: List[str] = []
    
    # Get total size of all files
    total_size = 0
    for f in files:
        f.file.seek(0, 2)
        total_size += f.file.tell()
        f.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-merge",
        input_filename=f"{len(files)} files",
        input_file_size=total_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        if not files or len(files) < 2:
            raise HTTPException(
                status_code=400,
                detail={
                    "error_type": "ValidationError",
                    "message": "Please select at least 2 PDF files before merging.",
                    "details": {}
                }
            )

        # Save uploaded files
        for file in files:
            FileService.validate_file(file, "pdf")
            base_name, _ = os.path.splitext(file.filename or "")
            original_names.append(base_name)
            input_path = FileService.save_uploaded_file(file)
            input_paths.append(input_path)
        
        # Determine output filename
        if output_filename:
            desired_name = output_filename
        else:
            name_parts = [name for name in original_names if name]
            if not name_parts:
                name_parts = [f"file_{idx + 1}" for idx in range(len(input_paths))]
            desired_name = "_".join(name_parts)

        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        
        # Merge PDFs
        result_path = PDFConversionService.merge_pdfs(input_paths, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename or os.path.basename(result_path),
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDFs merged successfully",
            output_filename=final_filename or os.path.basename(result_path),
            download_url=f"/download/{final_filename or os.path.basename(result_path)}"
        )
        
    except HTTPException as e:
        raise e
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFMergeError",
            message=str(e),
            status_code=400
        )
    finally:
        # Cleanup input files
        for path in input_paths:
            if path:
                PDFConversionService.cleanup_temp_files(path)


# PDF Split
@router.post("/split", response_model=PDFConversionResponse)
async def split_pdf(
    request: Request,
    file: UploadFile = File(...),
    split_type: str = Form("every_page"),
    page_ranges: Optional[str] = Form(None),
    output_prefix: Optional[str] = Form(None),
    zip: bool = Form(False),
    db: Session = Depends(get_db)
):
    """Split PDF into multiple files."""
    input_path = None
    final_filename = None
    
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
        conversion_type="pdf-split",
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
        
        ranges = None
        if page_ranges:
            ranges = [r.strip() for r in page_ranges.split(',')]

        st = (split_type or "").strip().lower()
        # Default split behavior: if ranges provided and no explicit type, use page_ranges; else every_page
        if st == "" and ranges:
            st = "page_ranges"
        elif st == "":
            st = "every_page"

        result = PDFConversionService.split_pdf(
            input_path=input_path,
            split_type=st,
            ranges=ranges,
            output_prefix=output_prefix,
            zip_output=zip,
        )

        folder_name = result.get("folder_name")
        files_payload = [
            {
                "filename": item["filename"],
                "download_url": f"/download/{folder_name}/{item['filename']}" if folder_name else f"/download/{item['filename']}",
                "pages": item.get("pages", [])
            }
            for item in result.get("files", [])
        ]

        # Calculate output file size
        output_size = 0
        if result.get("zip_filename"):
            # If zip file was created, get its size
            zip_path = os.path.join(settings.output_dir, result["zip_filename"])
            if os.path.exists(zip_path):
                output_size = os.path.getsize(zip_path)
        elif folder_name:
            # If folder output, calculate total size of all files in folder
            folder_path = os.path.join(settings.output_dir, folder_name)
            if os.path.exists(folder_path) and os.path.isdir(folder_path):
                for item in result.get("files", []):
                    file_path = os.path.join(folder_path, item["filename"])
                    if os.path.exists(file_path):
                        output_size += os.path.getsize(file_path)

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result.get("zip_filename") or folder_name,
            output_file_size=output_size,
            output_file_type="pdf"
        )

        resp = PDFConversionResponse(
            success=True,
            message=f"PDF split into {result.get('count', 0)} files",
            output_filename=result.get("zip_filename"),
            download_url=(f"/download/{result['zip_filename']}" if result.get("zip_filename") else None),
            extracted_data={"files": files_payload}
        )
        return resp
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFSplitError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# PDF Compress
@router.post("/compress", response_model=PDFConversionResponse)
async def compress_pdf(
    request: Request,
    file: UploadFile = File(...),
    compression_level: str = Form("medium"),
    output_filename: Optional[str] = Form(None),
    target_reduction_pct: Optional[int] = Form(None),
    max_image_dpi: Optional[int] = Form(None),
    db: Session = Depends(get_db)
):
    """Compress PDF file."""
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
        conversion_type="pdf-compress",
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
        
        # Get original file size
        original_size = os.path.getsize(input_path)
        
        original_name = file.filename or "compressed"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_compressed").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.compress_pdf(
            input_path,
            output_path,
            compression_level,
            target_reduction_pct,
            max_image_dpi,
        )
        
        # Get compressed file size
        compressed_size = os.path.getsize(result_path)
        
        achieved_reduction = None
        if original_size and original_size > 0:
            achieved_reduction = round(((original_size - compressed_size) * 100.0) / original_size, 2)

        return PDFConversionResponse(
            success=True,
            message="PDF compressed successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}",
            file_size_before=original_size,
            file_size_after=compressed_size,
            extracted_data={
                "compression": {
                    "level": compression_level,
                    "target_reduction_pct": target_reduction_pct,
                    "achieved_reduction_pct": achieved_reduction,
                }
            }
        )
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF compressed successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}",
            file_size_before=original_size,
            file_size_after=compressed_size,
            extracted_data={
                "compression": {
                    "level": compression_level,
                    "target_reduction_pct": target_reduction_pct,
                    "achieved_reduction_pct": achieved_reduction,
                }
            }
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFCompressError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Remove Pages
@router.post("/remove-pages", response_model=PDFConversionResponse)
async def remove_pages(
    request: Request,
    file: UploadFile = File(...),
    pages_to_remove: str = Form(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Remove specific pages from PDF."""
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
        conversion_type="pdf-remove-pages",
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
        
        # Parse pages to remove (supports comma-separated numbers and ranges like 10-20)
        tokens = [t.strip() for t in re.split(r'[\,\s]+', pages_to_remove) if t.strip()]
        pages: List[int] = []
        for token in tokens:
            if '-' in token:
                s, e = token.split('-', 1)
                start = int(s)
                end = int(e)
                if start > end:
                    start, end = end, start
                pages.extend(list(range(start, end + 1)))
            else:
                pages.append(int(token))
        seen = set()
        pages = [x for x in pages if not (x in seen or seen.add(x))]
        
        reader = PdfReader(input_path)
        total_pages = len(reader.pages)
        invalid_pages = [p for p in pages if p < 1 or p > total_pages]
        if invalid_pages:
            raise create_error_response(
                error_type="PDFRemovePagesError",
                message=f"Invalid page numbers: {sorted(invalid_pages)}. Valid page range is 1-{total_pages}",
                details={"invalid_pages": sorted(invalid_pages), "total_pages": total_pages, "requested_pages": pages},
                status_code=400,
            )
        # Determine desired output filename
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_pages_removed").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        # Remove pages
        result_path = PDFConversionService.remove_pages(input_path, output_path, pages)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message=f"Pages {pages} removed successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except HTTPException as he:
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFRemovePagesError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Extract Pages
@router.post("/extract-pages", response_model=PDFConversionResponse)
async def extract_pages(
    request: Request,
    file: UploadFile = File(...),
    pages_to_extract: str = Form(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Extract specific pages from PDF."""
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
        conversion_type="pdf-extract-pages",
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
        
        # Parse pages to extract (supports comma-separated numbers and ranges like 10-20)
        tokens = [t.strip() for t in re.split(r'[\,\s]+', pages_to_extract) if t.strip()]
        pages: List[int] = []
        for token in tokens:
            if '-' in token:
                s, e = token.split('-', 1)
                start = int(s)
                end = int(e)
                if start > end:
                    start, end = end, start
                pages.extend(list(range(start, end + 1)))
            else:
                pages.append(int(token))
        seen = set()
        pages = [x for x in pages if not (x in seen or seen.add(x))]
        
        reader = PdfReader(input_path)
        total_pages = len(reader.pages)
        invalid_pages = [p for p in pages if p < 1 or p > total_pages]
        if invalid_pages:
            raise create_error_response(
                error_type="PDFExtractPagesError",
                message=f"Invalid page numbers: {sorted(invalid_pages)}. Valid page range is 1-{total_pages}",
                details={"invalid_pages": sorted(invalid_pages), "total_pages": total_pages, "requested_pages": pages},
                status_code=400,
            )
        # Determine desired output filename
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_extracted").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        # Extract pages
        result_path = PDFConversionService.extract_pages(input_path, output_path, pages)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message=f"Pages {pages} extracted successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except HTTPException as he:
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFExtractPagesError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Rotate PDF
@router.post("/rotate", response_model=PDFConversionResponse)
async def rotate_pdf(
    request: Request,
    file: UploadFile = File(...),
    rotation: int = Form(90),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Rotate PDF pages."""
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
        conversion_type="pdf-rotate",
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
        
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_rotated_{rotation}").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        result_path = PDFConversionService.rotate_pdf(input_path, output_path, rotation)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF rotated {rotation} degrees successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFRotateError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Add Watermark
@router.post("/add-watermark", response_model=PDFConversionResponse)
async def add_watermark(
    request: Request,
    file: UploadFile = File(...),
    watermark_text: str = Form(...),
    position: str = Form("center"),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Add watermark to PDF."""
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
        conversion_type="pdf-watermark",
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

        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        default_base = f"{base_name}_watermarked" if base_name else "watermarked"
        desired_name = (output_filename or default_base).strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        result_path = PDFConversionService.add_watermark(input_path, output_path, watermark_text, position)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Watermark added successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))        
        raise create_error_response(
            error_type="PDFWatermarkError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Add Page Numbers
@router.post("/add-page-numbers", response_model=PDFConversionResponse)
async def add_page_numbers(
    request: Request,
    file: UploadFile = File(...),
    position: str = Form("bottom-center"),
    start_page: int = Form(1),
    format: str = Form("{page}"),
    font_size: float = Form(12.0),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Add page numbers to PDF."""
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
        conversion_type="pdf-page-numbers",
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
        
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_numbered").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        result_path = PDFConversionService.add_page_numbers(
            input_path,
            output_path,
            position,
            start_page,
            format,
            font_size,
        )
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="Page numbers added successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFPageNumbersError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Crop PDF
@router.post("/crop", response_model=PDFConversionResponse)
async def crop_pdf(
    request: Request,
    file: UploadFile = File(...),
    x: int = Form(0),
    y: int = Form(0),
    width: int = Form(100),
    height: int = Form(100),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Crop PDF pages."""
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
        conversion_type="pdf-crop",
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
        
        crop_box = {"x": x, "y": y, "width": width, "height": height}
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_cropped").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )

        result_path = PDFConversionService.crop_pdf(input_path, output_path, crop_box)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF cropped successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFCropError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Protect PDF
@router.post("/protect", response_model=PDFConversionResponse)
async def protect_pdf(
    request: Request,
    file: UploadFile = File(...),
    password: str = Form(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Protect PDF with password."""
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
        conversion_type="pdf-protect",
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
        
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_protected").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.protect_pdf(input_path, output_path, password)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF protected successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFProtectError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Unlock PDF
@router.post("/unlock", response_model=PDFConversionResponse)
async def unlock_pdf(
    request: Request,
    file: UploadFile = File(...),
    password: str = Form(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Remove password protection from PDF."""
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
        conversion_type="pdf-unlock",
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
        
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_unlocked").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.unlock_pdf(input_path, output_path, password)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF unlocked successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFUnlockError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Repair PDF
@router.post("/repair", response_model=PDFConversionResponse)
async def repair_pdf(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Repair corrupted PDF."""
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
        conversion_type="pdf-repair",
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
        
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_repaired").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".pdf",
        )
        result_path = PDFConversionService.repair_pdf(input_path, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="pdf"
        )
        
        return PDFConversionResponse(
            success=True,
            message="PDF repaired successfully",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}"
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFRepairError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Compare PDFs
@router.post("/compare", response_model=PDFConversionResponse)
async def compare_pdfs(
    request: Request,
    file1: UploadFile = File(...),
    file2: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Compare two PDFs."""
    input_path1 = None
    input_path2 = None
    output_path = None
    
    # Get total file size
    file1.file.seek(0, 2)
    size1 = file1.file.tell()
    file1.file.seek(0)
    file2.file.seek(0, 2)
    size2 = file2.file.tell()
    file2.file.seek(0)
    total_size = size1 + size2
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="pdf-compare",
        input_filename=f"{file1.filename} vs {file2.filename}",
        input_file_size=total_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Save uploaded files
        FileService.validate_file(file1, "pdf")
        FileService.validate_file(file2, "pdf")
        input_path1 = FileService.save_uploaded_file(file1)
        input_path2 = FileService.save_uploaded_file(file2)
        
        original1 = file1.filename or "pdf1"
        original2 = file2.filename or "pdf2"
        base1, _ = os.path.splitext(original1)
        base2, _ = os.path.splitext(original2)
        desired_name = (output_filename or f"{base1}_vs_{base2}_comparison").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".txt",
        )
        comparison_result = PDFConversionService.compare_pdfs(input_path1, input_path2, output_path)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="txt"
        )
        
        return PDFConversionResponse(
            success=True,
            message=f"PDFs compared successfully. Found {comparison_result['differences_count']} differences",
            output_filename=final_filename,
            download_url=f"/download/{final_filename}",
            extracted_data=comparison_result
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFCompareError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path1:
            PDFConversionService.cleanup_temp_files(input_path1)
        if input_path2:
            PDFConversionService.cleanup_temp_files(input_path2)


# Get PDF Metadata
@router.post("/metadata")
async def get_pdf_metadata(
    request: Request,
    file: UploadFile = File(...),
    output_filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Get PDF metadata."""
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
        conversion_type="pdf-metadata",
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
        
        metadata = PDFConversionService.get_pdf_metadata(input_path)
        original_name = file.filename or "pdf"
        base_name, _ = os.path.splitext(original_name)
        desired_name = (output_filename or f"{base_name}_metadata").strip()
        output_path, final_filename = FileService.generate_output_path_with_filename(
            desired_name,
            default_extension=".json",
        )
        try:
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, "w", encoding="utf-8") as f:
                import json as _json
                _json.dump(metadata, f, indent=2, ensure_ascii=False)
        except Exception:
            pass
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=final_filename,
            output_file_type="json"
        )
        
        return {
            "success": True,
            "message": "PDF metadata extracted successfully",
            "metadata": metadata,
            "output_filename": final_filename,
            "download_url": f"/download/{final_filename}",
        }
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="PDFMetadataError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFConversionService.cleanup_temp_files(input_path)


# Download converted file
@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download a converted file."""
    try:
        file_path = os.path.join("outputs", filename)
        if os.path.exists(file_path):
            return FileResponse(
                path=file_path,
                filename=filename,
                media_type='application/octet-stream'
            )
        else:
            raise HTTPException(status_code=404, detail="File not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
