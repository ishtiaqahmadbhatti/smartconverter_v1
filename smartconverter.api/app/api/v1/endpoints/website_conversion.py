"""
Website Conversion API Endpoints

This module provides API endpoints for various website and HTML conversion operations.
"""

import json
import logging
from typing import Optional, Union
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
    html_content: Optional[str] = Form(None),
    css_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None)
):
    """Convert HTML content or file to PDF."""
    try:
        # Handle case where file is sent as empty string
        if isinstance(file, str):
            file = None

        if file:
            # Handle file upload
            import tempfile
            import os
            
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
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{filename}"
        
        # Log conversion
        input_data = "HTML Content"
        if file:
            input_data = f"File: {file.filename}"
            
        WebsiteConversionService.log_conversion(
            "html-to-pdf",
            input_data,
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
        
    except HTTPException as he:
        raise he
    except Exception as e:
        input_data = "HTML Content"
        if file:
            input_data = f"File: {file.filename}" if file else "Unknown File"
            
        WebsiteConversionService.log_conversion(
            "html-to-pdf",
            input_data,
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


# Website to PDF
@router.post("/website-to-pdf", response_model=ConversionResponse)
async def convert_website_to_pdf(
    url: str = Form(...),
    filename: Optional[str] = Form(None)
):
    """Convert Website URL to PDF."""
    try:
        result = WebsiteConversionService.website_to_pdf(url, filename)
        
        # Create download URL
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{filename}"
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "website-to-pdf",
            url,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Website converted to PDF successfully",
            output_filename=filename,
            download_url=download_url
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "website-to-pdf",
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


# Word to HTML
@router.post("/word-to-html", response_model=ConversionResponse)
async def convert_word_to_html(
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    """Convert Word document to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.word_to_html(file_content, file.filename, filename)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

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
            output_filename=result_filename,
            download_url=download_url
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
    filename: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    """Convert PowerPoint presentation to HTML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = WebsiteConversionService.powerpoint_to_html(file_content, file.filename, filename)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
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
            output_filename=result_filename,
            download_url=download_url
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
    filename: Optional[str] = Form(None),
    markdown_content: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None)
):
    """Convert Markdown content or file to HTML."""
    try:
        content = ""
        input_name = "Markdown Content"
        
        if file:
            content_bytes = await file.read()
            content = content_bytes.decode('utf-8')
            input_name = file.filename
        elif markdown_content:
            content = markdown_content
        else:
            raise HTTPException(status_code=400, detail="Either markdown_content or file must be provided")

        result = WebsiteConversionService.markdown_to_html(content, input_name if file else None, filename)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "markdown-to-html",
            f"Input: {input_name}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Markdown converted to HTML successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "markdown-to-html",
            f"Input: {input_name if 'input_name' in locals() else 'Unknown'}",
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
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert website to JPG image."""
    try:
        result = WebsiteConversionService.website_to_jpg(url, filename, width, height)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
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
            output_filename=result_filename,
            download_url=download_url
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
# HTML to JPG
@router.post("/html-to-jpg", response_model=ConversionResponse)
async def convert_html_to_jpg(
    file: Optional[UploadFile] = File(None),
    html_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert HTML content or file to JPG image."""
    try:
        if not file and not html_content:
            raise HTTPException(status_code=400, detail="Either file or html_content must be provided")
            
        input_name = "HTML Content"
        content_to_process = ""
        original_filename = None
        
        if file:
            content = await file.read()
            content_to_process = content.decode('utf-8')
            input_name = file.filename
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
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-to-jpg",
            f"Input: {input_name}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to JPG successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-to-jpg",
            f"Input: {input_name if 'input_name' in locals() else 'Unknown'}",
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
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert website to PNG image."""
    try:
        result = WebsiteConversionService.website_to_png(url, filename, width, height)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
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
            output_filename=result_filename,
            download_url=download_url
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
    file: Optional[UploadFile] = File(None),
    html_content: Optional[str] = Form(None),
    filename: Optional[str] = Form(None),
    width: int = Form(1920),
    height: int = Form(1080)
):
    """Convert HTML content or file to PNG image."""
    try:
        if not file and not html_content:
            raise HTTPException(status_code=400, detail="Either file or html_content must be provided")
            
        input_name = "HTML Content"
        content_to_process = ""
        original_filename = None
        
        if file:
            content = await file.read()
            content_to_process = content.decode('utf-8')
            input_name = file.filename
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
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"
        
        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-to-png",
            f"Input: {input_name}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML converted to PNG successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        WebsiteConversionService.log_conversion(
            "html-to-png",
            f"Input: {input_name if 'input_name' in locals() else 'Unknown'}",
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
    html_content: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    filename: Optional[str] = Form(None)
):
    """Convert HTML table to CSV."""
    try:
        input_name = "HTML Content"
        original_filename = None
        
        if file:
            content_bytes = await file.read()
            content_to_process = content_bytes.decode('utf-8')
            input_name = file.filename
            original_filename = file.filename
        elif html_content:
            content_to_process = html_content
        else:
            raise HTTPException(status_code=400, detail="Either html_content or file must be provided")

        result = WebsiteConversionService.html_table_to_csv(content_to_process, filename, original_filename)
        
        # Create download URL
        import os
        result_filename = os.path.basename(result)
        download_url = f"/api/v1/websiteconversiontools/download/{result_filename}"

        # Log conversion
        WebsiteConversionService.log_conversion(
            "html-table-to-csv",
            f"Input: {input_name}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="HTML table converted to CSV successfully",
            output_filename=result_filename,
            download_url=download_url
        )
        
    except Exception as e:
        input_name = "HTML Content"
        if file:
            input_name = f"File: {file.filename}" if file else "Unknown File"
            
        WebsiteConversionService.log_conversion(
            "html-table-to-csv",
            f"Input: {input_name}",
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
