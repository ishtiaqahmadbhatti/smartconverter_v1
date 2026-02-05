"""
Website Conversion API Endpoints

This module provides API endpoints for various website and HTML conversion operations.
"""

import json
import logging
import os
import tempfile
from typing import Optional, Union
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Depends, Request, BackgroundTasks
from fastapi.responses import JSONResponse, FileResponse
from sqlalchemy.orm import Session

from app.services.website_conversion_service_simple import WebsiteConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.core.exceptions import create_error_response
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()


# HTML to PDF
# HTML to PDF
@router.post("/html-to-pdf", response_model=ConversionResponse)
async def convert_html_to_pdf(
    request: Request,
    html_content: Optional[str] = Form(None),
    css_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    db: Session = Depends(get_db)
):
    """Convert HTML content or file to PDF."""
    
    # Determine input info for logging
    input_info = "HTML Content"
    input_size = 0
    if html_content:
        input_size = len(html_content)
    
    if isinstance(file, UploadFile):
        input_info = file.filename
        # Try to get size
        file.file.seek(0, 2)
        input_size = file.file.tell()
        file.file.seek(0)
    elif isinstance(file, str):
        # file might be passed as string "null" or empty from some clients
        file = None

    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="html-to-pdf",
        input_filename=input_info,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        if file:
            # Handle file upload
            # Create temporary file
            with tempfile.NamedTemporaryFile(delete=False, suffix=".html") as temp_file:
                content = await file.read()
                temp_file.write(content)
                temp_file_path = temp_file.name
                
            try:
                result = WebsiteConversionService.convert_html_file_to_pdf(temp_file_path, filename)
            finally:
                # Cleanup temp file
                if os.path.exists(temp_file_path):
                    try:
                        os.unlink(temp_file_path)
                    except:
                        pass
        elif html_content:
            # Handle string content
            result = WebsiteConversionService.html_to_pdf(html_content, css_content, filename)
        else:
            raise HTTPException(status_code=400, detail="Either html_content or file must be provided")
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="pdf"
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to PDF successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except HTTPException as he:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(he.detail))
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Website to PDF
# Website to PDF
@router.post("/website-to-pdf", response_model=ConversionResponse)
async def convert_website_to_pdf(
    request: Request,
    url: str = Form(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Website URL to PDF."""
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="website-to-pdf",
        input_filename=url,
        input_file_size=0,
        input_file_type="url",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        result = WebsiteConversionService.website_to_pdf(url, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="pdf"
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to PDF successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Word to HTML
# Word to HTML
@router.post("/word-to-html", response_model=ConversionResponse)
async def convert_word_to_html(
    request: Request,
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Convert Word document to HTML."""
    
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
        input_file_type="docx", # Assuming docx/doc
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.word_to_html(file_content, file.filename, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="Word document converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# PowerPoint to HTML
@router.post("/powerpoint-to-html", response_model=ConversionResponse)
async def convert_powerpoint_to_html(
    request: Request,
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Convert PowerPoint presentation to HTML."""
    
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
        input_file_type="pptx", # Assuming pptx/ppt
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.powerpoint_to_html(file_content, file.filename, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Markdown to HTML
@router.post("/markdown-to-html", response_model=ConversionResponse)
async def convert_markdown_to_html(
    request: Request,
    filename: Optional[str] = Form(None),
    markdown_content: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    """Convert Markdown content or file to HTML."""
    
    input_size = 0
    input_name = "Markdown Content"
    
    if file:
        file.file.seek(0, 2)
        input_size = file.file.tell()
        file.file.seek(0)
        input_name = file.filename
    elif markdown_content:
        input_size = len(markdown_content)

    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="markdown-to-html",
        input_filename=input_name,
        input_file_size=input_size,
        input_file_type="md",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = ""
        
        if file:
            content_bytes = await file.read()
            content = content_bytes.decode('utf-8')
        elif markdown_content:
            content = markdown_content
        else:
            raise HTTPException(status_code=400, detail="Either markdown_content or file must be provided")

        result = WebsiteConversionService.markdown_to_html(content, input_name if file else None, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="Markdown converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except HTTPException as he:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(he.detail))
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Website to JPG
@router.post("/website-to-jpg", response_model=ConversionResponse)
async def convert_website_to_jpg(
    request: Request,
    url: str = Form(...),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080),
    db: Session = Depends(get_db)
):
    """Convert website to JPG image."""
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="website-to-jpg",
        input_filename=url,
        input_file_size=0,
        input_file_type="url",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        result = WebsiteConversionService.website_to_jpg(url, filename, width, height)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="jpg"
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to JPG successfully",
            output_filename=result_filename,
            download_url=download_url
        )

        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML to JPG
# HTML to JPG
@router.post("/html-to-jpg", response_model=ConversionResponse)
async def convert_html_to_jpg(
    request: Request,
    file: Optional[UploadFile] = File(None),
    html_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080),
    db: Session = Depends(get_db)
):
    """Convert HTML content or file to JPG image."""
    
    input_size = 0
    input_name = "HTML Content"
    
    if file:
        input_name = file.filename
        file.file.seek(0, 2)
        input_size = file.file.tell()
        file.file.seek(0)
    elif html_content:
        input_size = len(html_content)

    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="html-to-jpg",
        input_filename=input_name,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        if not file and not html_content:
            raise HTTPException(status_code=400, detail="Either file or html_content must be provided")
            
        content_to_process = ""
        original_filename = None
        
        if file:
            content = await file.read()
            content_to_process = content.decode('utf-8')
            original_filename = file.filename
        else:
            content_to_process = html_content
            
        result = WebsiteConversionService.html_to_jpg(
            content_to_process, 
            original_filename, 
            filename, 
            width, 
            height
        )
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="jpg"
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to JPG successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except HTTPException as he:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(he.detail))
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )



# Website to PNG
@router.post("/website-to-png", response_model=ConversionResponse)
async def convert_website_to_png(
    request: Request,
    url: str = Form(...),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080),
    db: Session = Depends(get_db)
):
    """Convert website to PNG image."""
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="website-to-png",
        input_filename=url,
        input_file_size=0,
        input_file_type="url",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        result = WebsiteConversionService.website_to_png(url, filename, width, height)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="png"
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to PNG successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML to PNG
@router.post("/html-to-png", response_model=ConversionResponse)
async def convert_html_to_png(
    request: Request,
    file: Optional[UploadFile] = File(None),
    html_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080),
    db: Session = Depends(get_db)
):
    """Convert HTML content or file to PNG image."""
    
    input_size = 0
    input_name = "HTML Content"
    
    if file:
        input_name = file.filename
        file.file.seek(0, 2)
        input_size = file.file.tell()
        file.file.seek(0)
    elif html_content:
        input_size = len(html_content)

    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="html-to-png",
        input_filename=input_name,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        if not file and not html_content:
            raise HTTPException(status_code=400, detail="Either file or html_content must be provided")
            
        content_to_process = ""
        original_filename = None
        
        if file:
            content = await file.read()
            content_to_process = content.decode('utf-8')
            original_filename = file.filename
        else:
            content_to_process = html_content
            
        result = WebsiteConversionService.html_to_png(
            content_to_process, 
            original_filename, 
            filename, 
            width, 
            height
        )
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="png"
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to PNG successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except HTTPException as he:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(he.detail))
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML Table to CSV
@router.post("/html-table-to-csv", response_model=ConversionResponse)
async def convert_html_table_to_csv(
    request: Request,
    html_content: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HTML table to CSV."""
    
    input_size = 0
    input_name = "HTML Content"
    
    if file:
        input_name = file.filename
        file.file.seek(0, 2)
        input_size = file.file.tell()
        file.file.seek(0)
    elif html_content:
        input_size = len(html_content)

    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="html-table-to-csv",
        input_filename=input_name,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        original_filename = None
        
        if file:
            content_bytes = await file.read()
            content_to_process = content_bytes.decode('utf-8')
            original_filename = file.filename
        elif html_content:
            content_to_process = html_content
        else:
            raise HTTPException(status_code=400, detail="Either html_content or file must be provided")

        result = WebsiteConversionService.html_table_to_csv(content_to_process, filename, original_filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="csv"
        )
        
        return ConversionResponse(
            success=True,
            message="HTML table converted to CSV successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except HTTPException as he:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(he.detail))
        raise he
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Excel to HTML
@router.post("/excel-to-html", response_model=ConversionResponse)
async def convert_excel_to_html(
    request: Request,
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Convert Excel file to HTML."""
    
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
        input_file_type="xlsx", # Assuming xlsx/xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.excel_to_html(file_content, file.filename, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# PDF to HTML
@router.post("/pdf-to-html", response_model=ConversionResponse)
async def convert_pdf_to_html(
    request: Request,
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Convert PDF to HTML."""
    
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
        conversion_type="pdf-to-html",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="pdf",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.pdf_to_html(file_content, file.filename, filename)
        
        # Create download URL
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=result_filename,
            output_file_type="html"
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Download endpoint for generated files
@router.get("/download/{filename}")
async def download_file(filename: str, background_tasks: BackgroundTasks):
    """Download a generated file and clean up."""
    file_path = os.path.join(settings.output_dir, filename)
    return FileService.create_cleanup_response(file_path, filename, background_tasks)
