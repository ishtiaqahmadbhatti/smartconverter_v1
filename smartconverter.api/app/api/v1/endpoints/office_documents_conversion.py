"""
Office Documents Conversion API Endpoints

This module provides API endpoints for various office document conversion operations.
"""

import json
import logging
from typing import Optional, List, Dict, Any
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Body, Request, Depends
from fastapi.responses import JSONResponse, FileResponse
from sqlalchemy.orm import Session
import shutil
import os
import uuid

from app.services.office_documents_conversion_service import OfficeDocumentsConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.core.config import settings
from app.core.exceptions import (
    create_error_response,
    FileProcessingError,
)
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------

def _build_download_url(filename: str) -> str:
    """Build consistent download url for generated files."""
    return f"/api/v1/officedocumentsconversiontools/download/{filename}"

def _cleanup_files(*paths: Optional[str]) -> None:
    """Cleanup temporary files if they exist."""
    from app.services.file_service import FileService
    for path in paths:
        if path:
            FileService.cleanup_file(path)

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
        if not filename.lower().endswith(extension):
            filename += extension
        return filename
    else:
        # Fallback to input file name or default
        base_name = default_base
        if input_file and input_file.filename:
            # Strip input extension
            base_name = os.path.splitext(input_file.filename)[0]
        
        return f"{base_name}{extension}"

async def _read_file_content(file: UploadFile) -> bytes:
    """Read file content as bytes."""
    try:
        return await file.read()
    except Exception as e:
        raise FileProcessingError(f"Error reading file content: {str(e)}")

async def _read_file_content_str(file: UploadFile) -> str:
    """Read file content as string."""
    try:
        content_bytes = await file.read()
        return content_bytes.decode('utf-8', errors='replace')
    except Exception as e:
        raise FileProcessingError(f"Error reading file content: {str(e)}")

# ---------------------------------------------------------------------------
# PDF Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/pdf-to-csv", response_model=ConversionResponse)
async def convert_pdf_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to CSV."""
    
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
        conversion_type="pdf-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.pdf_to_csv(content)
        
        output_filename = _determine_output_filename(filename, file, "pdf_to_csv", ".csv")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PDF to CSV", str(e))

@router.post("/pdf-to-excel", response_model=ConversionResponse)
async def convert_pdf_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to Excel."""
    
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
        conversion_type="pdf-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.pdf_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "pdf_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PDF to Excel", str(e))

@router.post("/pdf-to-word", response_model=ConversionResponse)
async def convert_pdf_to_word(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to Word."""
    
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
        conversion_type="pdf-to-word",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        content = await _read_file_content(file)
        
        # Service takes output_filename but we handle it here for consistency
        # Using a temporary name for service, then rename.
        # Actually service signature is: pdf_to_word(file_content, output_filename=None)
        # If output_filename provided it saves to outputs/filename.
        
        # We can pass the target filename directly if we determine it first.
        output_filename = _determine_output_filename(filename, file, "pdf_to_word", ".docx")
        
        service_output_path = OfficeDocumentsConversionService.pdf_to_word(content, output_filename=output_filename)
        
        # If service returns a path that is what we want.
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="docx"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to Word successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PDF to Word", str(e))


# ---------------------------------------------------------------------------
# Word Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/word-to-pdf", response_model=ConversionResponse)
async def convert_word_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Word to PDF."""
    
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
        conversion_type="word-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="docx", # or doc
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.word_to_pdf(content)
        
        output_filename = _determine_output_filename(filename, file, "word_to_pdf", ".pdf")
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
            message="Word converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Word to PDF", str(e))

@router.post("/word-to-html", response_model=ConversionResponse)
async def convert_word_to_html(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Word to HTML."""
    
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
        conversion_type="word-to-html",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="docx", # or doc
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.word_to_html(content)
        
        output_filename = _determine_output_filename(filename, file, "word_to_html", ".html")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="Word converted to HTML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Word to HTML", str(e))

@router.post("/word-to-text", response_model=ConversionResponse)
async def convert_word_to_text(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Word to Text."""
    
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
        conversion_type="word-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="docx", # or doc
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.word_to_text(content)
        
        output_filename = _determine_output_filename(filename, file, "word_to_text", ".txt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
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
            message="Word converted to Text successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Word to Text", str(e))

# ---------------------------------------------------------------------------
# PowerPoint Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/powerpoint-to-pdf", response_model=ConversionResponse)
async def convert_powerpoint_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint to PDF."""
    
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
        conversion_type="powerpoint-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pptx", # or ppt
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.powerpoint_to_pdf(content)
        
        output_filename = _determine_output_filename(filename, file, "powerpoint_to_pdf", ".pdf")
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
            message="PowerPoint converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PowerPoint to PDF", str(e))

@router.post("/powerpoint-to-html", response_model=ConversionResponse)
async def convert_powerpoint_to_html(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint to HTML."""
    
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
        conversion_type="powerpoint-to-html",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pptx", # or ppt
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.powerpoint_to_html(content)
        
        output_filename = _determine_output_filename(filename, file, "powerpoint_to_html", ".html")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="PowerPoint converted to HTML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PowerPoint to HTML", str(e))

@router.post("/powerpoint-to-text", response_model=ConversionResponse)
async def convert_powerpoint_to_text(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint to Text."""
    
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
        conversion_type="powerpoint-to-text",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pptx", # or ppt
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.powerpoint_to_text(content)
        
        output_filename = _determine_output_filename(filename, file, "powerpoint_to_text", ".txt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
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
            message="PowerPoint converted to Text successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert PowerPoint to Text", str(e))


# ---------------------------------------------------------------------------
# Excel Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/excel-to-pdf", response_model=ConversionResponse)
async def convert_excel_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to PDF."""
    
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
        conversion_type="excel-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.excel_to_pdf(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_pdf", ".pdf")
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
            message="Excel converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to PDF", str(e))

@router.post("/excel-to-xps", response_model=ConversionResponse)
async def convert_excel_to_xps(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to XPS."""
    
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
        conversion_type="excel-to-xps",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.excel_to_xps(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_xps", ".xps")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xps"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to XPS successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to XPS", str(e))

@router.post("/excel-to-html", response_model=ConversionResponse)
async def convert_excel_to_html(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to HTML."""
    
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
        conversion_type="excel-to-html",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.excel_to_html(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_html", ".html")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to HTML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to HTML", str(e))

@router.post("/excel-to-csv", response_model=ConversionResponse)
async def convert_excel_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to CSV."""
    
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
        conversion_type="excel-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.excel_to_csv(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_csv", ".csv")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to CSV successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to CSV", str(e))

@router.post("/excel-to-ods", response_model=ConversionResponse)
async def convert_excel_to_ods(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to ODS."""
    
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
        conversion_type="excel-to-ods",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.excel_to_ods(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_ods", ".ods")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="ods"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to ODS successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to ODS", str(e))

# ---------------------------------------------------------------------------
# ODS Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/ods-to-csv", response_model=ConversionResponse)
async def convert_ods_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ODS to CSV."""
    
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
        conversion_type="ods-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="ods",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.ods_to_csv(content)
        
        output_filename = _determine_output_filename(filename, file, "ods_to_csv", ".csv")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="ODS converted to CSV successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert ODS to CSV", str(e))

@router.post("/ods-to-pdf", response_model=ConversionResponse)
async def convert_ods_to_pdf(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ODS to PDF."""
    
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
        conversion_type="ods-to-pdf",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="ods",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.ods_to_pdf(content)
        
        output_filename = _determine_output_filename(filename, file, "ods_to_pdf", ".pdf")
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
            message="ODS converted to PDF successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert ODS to PDF", str(e))

@router.post("/ods-to-excel", response_model=ConversionResponse)
async def convert_ods_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert ODS to Excel."""
    
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
        conversion_type="ods-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="ods",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.ods_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "ods_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="ODS converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert ODS to Excel", str(e))


@router.post("/csv-to-excel", response_model=ConversionResponse)
async def convert_csv_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert CSV to Excel."""
    
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
        conversion_type="csv-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="csv",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        service_output_path = OfficeDocumentsConversionService.csv_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "csv_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert CSV to Excel", str(e))

@router.post("/excel-to-xml", response_model=ConversionResponse)
async def convert_excel_to_xml(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record"),
    db: Session = Depends(get_db)
):
    """Convert Excel to XML."""
    
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
        conversion_type="excel-to-xml",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.excel_to_xml(content, root_name, record_name)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_xml", ".xml")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xml"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to XML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to XML", str(e))

@router.post("/xml-to-csv", response_model=ConversionResponse)
async def convert_xml_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XML to CSV."""
    
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
        conversion_type="xml-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xml",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        result = OfficeDocumentsConversionService.xml_to_csv(content)
        
        output_filename = _determine_output_filename(filename, file, "xml_to_csv", ".csv")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to CSV successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        OfficeDocumentsConversionService.log_conversion("xml-to-csv", file.filename or "unknown", "", False, str(e))
        return create_error_response("Failed to convert XML to CSV", str(e))

@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XML to Excel."""
    
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
        conversion_type="xml-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xml",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        service_output_path = OfficeDocumentsConversionService.xml_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "xml_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert XML to Excel", str(e))

@router.post("/json-to-excel", response_model=ConversionResponse)
async def convert_json_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JSON to Excel."""
    
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
        conversion_type="json-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="json",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        try:
            json_data = json.loads(content)
        except json.JSONDecodeError:
            raise FileProcessingError("Invalid JSON file")

        service_output_path = OfficeDocumentsConversionService.json_to_excel(json_data)
        
        output_filename = _determine_output_filename(filename, file, "json_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert JSON to Excel", str(e))

@router.post("/excel-to-json", response_model=ConversionResponse)
async def convert_excel_to_json(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to JSON."""
    
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
        conversion_type="excel-to-json",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.excel_to_json(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_json", ".json")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="json"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to JSON successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to JSON", str(e))

@router.post("/json-objects-to-excel", response_model=ConversionResponse)
async def convert_json_objects_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JSON Objects to Excel."""
    
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
        conversion_type="json-objects-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="json",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        try:
            json_objects = json.loads(content)
            if not isinstance(json_objects, list):
                raise FileProcessingError("JSON file must contain a list of objects")
        except json.JSONDecodeError:
            raise FileProcessingError("Invalid JSON file")

        service_output_path = OfficeDocumentsConversionService.json_objects_to_excel(json_objects)
        
        output_filename = _determine_output_filename(filename, file, "json_objects_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="JSON objects converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert JSON objects to Excel", str(e))

@router.post("/bson-to-excel", response_model=ConversionResponse)
async def convert_bson_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert BSON to Excel."""
    
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
        conversion_type="bson-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="bson",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        service_output_path = OfficeDocumentsConversionService.bson_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "bson_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="BSON converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert BSON to Excel", str(e))

# ---------------------------------------------------------------------------
# SRT Conversion Endpoints
# ---------------------------------------------------------------------------

@router.post("/srt-to-excel", response_model=ConversionResponse)
async def convert_srt_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT to Excel."""
    
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
        conversion_type="srt-to-excel",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        service_output_path = OfficeDocumentsConversionService.srt_to_excel(content)
        
        output_filename = _determine_output_filename(filename, file, "srt_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert SRT to Excel", str(e))

@router.post("/srt-to-xlsx", response_model=ConversionResponse)
async def convert_srt_to_xlsx(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT to XLSX."""
    
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
        conversion_type="srt-to-xlsx",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        service_output_path = OfficeDocumentsConversionService.srt_to_xlsx(content)
        
        output_filename = _determine_output_filename(filename, file, "srt_to_xlsx", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xlsx"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT converted to XLSX successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert SRT to XLSX", str(e))

@router.post("/srt-to-xls", response_model=ConversionResponse)
async def convert_srt_to_xls(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT to XLS."""
    
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
        conversion_type="srt-to-xls",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content_str(file)
        
        service_output_path = OfficeDocumentsConversionService.srt_to_xls(content)
        
        output_filename = _determine_output_filename(filename, file, "srt_to_xls", ".xls")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="xls"
        )
        
        return ConversionResponse(
            success=True,
            message="SRT converted to XLS successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert SRT to XLS", str(e))

@router.post("/excel-to-srt", response_model=ConversionResponse)
async def convert_excel_to_srt(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel to SRT."""
    
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
        conversion_type="excel-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx", # or xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.excel_to_srt(content)
        
        output_filename = _determine_output_filename(filename, file, "excel_to_srt", ".srt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to SRT successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert Excel to SRT", str(e))

@router.post("/xlsx-to-srt", response_model=ConversionResponse)
async def convert_xlsx_to_srt(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XLSX to SRT."""
    
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
        conversion_type="xlsx-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xlsx",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.xlsx_to_srt(content)
        
        output_filename = _determine_output_filename(filename, file, "xlsx_to_srt", ".srt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="XLSX converted to SRT successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert XLSX to SRT", str(e))

@router.post("/xls-to-srt", response_model=ConversionResponse)
async def convert_xls_to_srt(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XLS to SRT."""
    
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
        conversion_type="xls-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xls",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = OfficeDocumentsConversionService.xls_to_srt(content)
        
        output_filename = _determine_output_filename(filename, file, "xls_to_srt", ".srt")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
            
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="srt"
        )
        
        return ConversionResponse(
            success=True,
            message="XLS converted to SRT successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        return create_error_response("Failed to convert XLS to SRT", str(e))

@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    try:
        file_path = os.path.join(settings.output_dir, filename)
        
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="File not found")
        
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type='application/octet-stream'
        )
        
    except Exception as e:
        logger.error(f"Error downloading file: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to download file")
