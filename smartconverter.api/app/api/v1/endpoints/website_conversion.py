"""
Website Conversion API Endpoints

This module provides API endpoints for various website and HTML conversion operations.
"""

import json
import logging
from typing import Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse, FileResponse

from app.services.website_conversion_service_simple import WebsiteConversionService
from app.core.exceptions import create_error_response
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()


# HTML to PDF
@router.post("/html-to-pdf", response_model=ConversionResponse)
async def convert_html_to_pdf(
    html_content: str = Form(...),
    css_content: Optional[str] = Form(None)
):
    """Convert HTML content to PDF."""
    try:
        result = WebsiteConversionService.html_to_pdf(html_content, css_content)
        
        # Create download URL
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{filename}"
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-to-pdf",
            html_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to PDF successfully",
            output_filename=filename,
            download_url=download_url
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-to-pdf",
            html_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Word to HTML
@router.post("/word-to-html", response_model=ConversionResponse)
async def convert_word_to_html(
    file: UploadFile = File(...)
):
    """Convert Word document to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.word_to_html(file_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "word-to-html",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Word document converted to HTML successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "word-to-html",
            f"File: {file.filename if file else 'Unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# PowerPoint to HTML
@router.post("/powerpoint-to-html", response_model=ConversionResponse)
async def convert_powerpoint_to_html(
    file: UploadFile = File(...)
):
    """Convert PowerPoint presentation to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.powerpoint_to_html(file_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "powerpoint-to-html",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to HTML successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "powerpoint-to-html",
            f"File: {file.filename if file else 'Unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Markdown to HTML
@router.post("/markdown-to-html", response_model=ConversionResponse)
async def convert_markdown_to_html(
    markdown_content: str = Form(...)
):
    """Convert Markdown content to HTML."""
    try:
        result = WebsiteConversionService.markdown_to_html(markdown_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "markdown-to-html",
            markdown_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Markdown converted to HTML successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "markdown-to-html",
            markdown_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Website to JPG
@router.post("/website-to-jpg", response_model=ConversionResponse)
async def convert_website_to_jpg(
    url: str = Form(...),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert website to JPG image."""
    try:
        result = WebsiteConversionService.website_to_jpg(url, width, height)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "website-to-jpg",
            url,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to JPG successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "website-to-jpg",
            url,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML to JPG
@router.post("/html-to-jpg", response_model=ConversionResponse)
async def convert_html_to_jpg(
    html_content: str = Form(...),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert HTML content to JPG image."""
    try:
        result = WebsiteConversionService.html_to_jpg(html_content, width, height)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-to-jpg",
            html_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to JPG successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-to-jpg",
            html_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Website to PNG
@router.post("/website-to-png", response_model=ConversionResponse)
async def convert_website_to_png(
    url: str = Form(...),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert website to PNG image."""
    try:
        result = WebsiteConversionService.website_to_png(url, width, height)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "website-to-png",
            url,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to PNG successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "website-to-png",
            url,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML to PNG
@router.post("/html-to-png", response_model=ConversionResponse)
async def convert_html_to_png(
    html_content: str = Form(...),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert HTML content to PNG image."""
    try:
        result = WebsiteConversionService.html_to_png(html_content, width, height)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-to-png",
            html_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to PNG successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-to-png",
            html_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# HTML Table to CSV
@router.post("/html-table-to-csv", response_model=ConversionResponse)
async def convert_html_table_to_csv(
    html_content: str = Form(...)
):
    """Convert HTML table to CSV."""
    try:
        result = WebsiteConversionService.html_table_to_csv(html_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-table-to-csv",
            html_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML table converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-table-to-csv",
            html_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Excel to HTML
@router.post("/excel-to-html", response_model=ConversionResponse)
async def convert_excel_to_html(
    file: UploadFile = File(...)
):
    """Convert Excel file to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.excel_to_html(file_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "excel-to-html",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to HTML successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "excel-to-html",
            f"File: {file.filename if file else 'Unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# PDF to HTML
@router.post("/pdf-to-html", response_model=ConversionResponse)
async def convert_pdf_to_html(
    file: UploadFile = File(...)
):
    """Convert PDF to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.pdf_to_html(file_content)
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "pdf-to-html",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to HTML successfully",
            converted_data=result
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "pdf-to-html",
            f"File: {file.filename if file else 'Unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Download endpoint for generated files
@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download a generated file."""
    try:
        import os
        
        file_path = os.path.join("outputs", filename)
        
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="File not found")
        
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type='application/octet-stream'
        )
        
    except Exception as e:
        logger.error(f"Error downloading file {filename}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error downloading file: {str(e)}")
