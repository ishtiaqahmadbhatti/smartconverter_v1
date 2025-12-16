"""
XML Conversion API Endpoints

This module provides API endpoints for various XML conversion operations.
"""

import json
import os
import logging
import uuid
import shutil
from typing import Optional, Dict, Any, List, Union, Tuple
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

from app.services.xml_conversion_service import XMLConversionService
from app.services.file_service import FileService
from app.core.config import settings
from app.core.exceptions import (
    FileProcessingError,
    UnsupportedFileTypeError,
    FileSizeExceededError,
    create_error_response,
)
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------

def _build_download_url(filename: str) -> str:
    """Build consistent download url for generated files."""
    return f"/api/v1/xmlconversiontools/download/{filename}"

def _cleanup_files(*paths: Optional[str]) -> None:
    """Cleanup temporary files if they exist."""
    for path in paths:
        if path:
            FileService.cleanup_file(path)

async def _get_content_from_file_or_text(
    file: Union[UploadFile, str, None],
    text: Optional[str],
    file_type_name: str = "file"
) -> Tuple[Optional[str], Optional[str]]:
    """
    Helper to extract content from either uploaded file or text input.
    Returns (content_string, file_path_to_cleanup).
    """
    input_path = None
    content = None

    # Handle file parameter
    actual_file = None
    if file is not None and file != "" and not (isinstance(file, str) and not file.strip()):
        if hasattr(file, 'filename'):
            actual_file = file
    
    # Check if file is provided
    has_file = (
        actual_file is not None 
        and hasattr(actual_file, 'filename') 
        and actual_file.filename 
        and actual_file.filename.strip() != ""
    )
    
    # Clean up text
    cleaned_text = None
    if text and text.strip():
        if text.strip().lower() not in ['string', 'null', 'none', '']:
            cleaned_text = text.strip()
    
    if not has_file and not cleaned_text:
        return None, None
        
    if has_file:
        input_path = FileService.save_uploaded_file(actual_file)
        with open(input_path, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()
    elif cleaned_text:
        content = cleaned_text
        
    return content, input_path

def _determine_output_filename(
    user_filename: Optional[str],
    input_file: Union[UploadFile, str, None],
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
        if input_file is not None and hasattr(input_file, 'filename') and input_file.filename:
            # Strip input extension
            base_name = os.path.splitext(input_file.filename)[0]
        
        # Avoid collisions or just return base? 
        # User requested "jo file selected osi name say save kary" (Save with same name as selected file)
        # But we need to ensure unique output if we don't want to overwrite?
        # json_conversion.py uses base_name directly. I will follow that.
        # But if text input (no file), we might want UUID to avoid constant overwrite of "xml_to_json.json"
        
        if not (input_file and hasattr(input_file, 'filename')):
             # For text input, append short UUID to avoid conflicts
             base_name = f"{base_name}_{uuid.uuid4().hex[:8]}"
             
        return f"{base_name}{extension}"

# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

# CSV to XML
@router.post("/csv-to-xml", response_model=ConversionResponse)
async def convert_csv_to_xml(
    csv_content: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record")
):
    """Convert CSV to XML. Supports file upload or text input."""
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, csv_content, "CSV")
        
        if not content:
             raise FileProcessingError("Please provide either a CSV file or CSV text")

        result = XMLConversionService.csv_to_xml(content, root_name, record_name)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "csv_to_xml", ".xml")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)

        # Log conversion
        XMLConversionService.log_conversion(
            "csv-to-xml",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to XML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "csv-to-xml",
            csv_content if csv_content else (file.filename if hasattr(file, 'filename') else "Unknown"),
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
    finally:
        _cleanup_files(input_path)


# Excel to XML
@router.post("/excel-to-xml", response_model=ConversionResponse)
async def convert_excel_to_xml(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record")
):
    """Convert Excel file to XML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = XMLConversionService.excel_to_xml(file_content, root_name, record_name)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "excel_to_xml", ".xml")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)

        # Log conversion
        XMLConversionService.log_conversion(
            "excel-to-xml",
            f"File: {file.filename}",
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to XML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "excel-to-xml",
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


# XML to JSON
@router.post("/xml-to-json", response_model=ConversionResponse)
async def convert_xml_to_json(
    xml_content: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None)
):
    """
    Convert XML to JSON.
    Accepts either XML content (as string) or XML file upload.
    """
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, xml_content, "XML")
        
        if not content:
            raise FileProcessingError("Please provide either an XML file or XML content")
        
        # Convert XML to JSON
        json_result = XMLConversionService.xml_to_json(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "xml_to_json", ".json")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(json_result)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-to-json",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to JSON successfully",
            converted_data=json_result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-to-json",
            xml_content if xml_content else (file.filename if hasattr(file, 'filename') else "Unknown"),
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
    finally:
        _cleanup_files(input_path)


# XML to CSV
@router.post("/xml-to-csv", response_model=ConversionResponse)
async def convert_xml_to_csv(
    xml_content: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None)
):
    """Convert XML to CSV. Supports file upload or text."""
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, xml_content, "XML")

        if not content:
            raise FileProcessingError("Please provide either XML file or text")

        result = XMLConversionService.xml_to_csv(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "xml_to_csv", ".csv")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)

        # Log conversion
        XMLConversionService.log_conversion(
            "xml-to-csv",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to CSV successfully",
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-to-csv",
            "",
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
    finally:
        _cleanup_files(input_path)


# XML to Excel
@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(
    xml_content: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None)
):
    """Convert XML to Excel file. Supports file upload or text."""
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, xml_content, "XML")

        if not content:
            raise FileProcessingError("Please provide either XML file or text")

        # Service method saves file directly and returns path
        service_output_path = XMLConversionService.xml_to_excel(content)
        
        # Rename/Move to desired filename
        output_filename = _determine_output_filename(filename, file, "xml_to_excel", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        # If paths are different, move/rename
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-to-excel",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to Excel successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-to-excel",
            "",
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
    finally:
        _cleanup_files(input_path)


# Fix XML Escaping
@router.post("/fix-xml-escaping", response_model=ConversionResponse)
async def fix_xml_escaping(
    xml_content: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None)
):
    """Fix XML escaping issues. Supports file upload or text."""
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, xml_content, "XML")

        if not content:
            raise FileProcessingError("Please provide either XML file or text")

        result = XMLConversionService.fix_xml_escaping(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "fixed_xml", ".xml")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)

        # Log conversion
        XMLConversionService.log_conversion(
            "fix-xml-escaping",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML escaping fixed successfully",
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "fix-xml-escaping",
            "",
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
    finally:
        _cleanup_files(input_path)


# Convert Excel XML to Excel XLSX
@router.post("/excel-xml-to-xlsx", response_model=ConversionResponse)
async def convert_excel_xml_to_xlsx(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert Excel XML to Excel XLSX file."""
    try:
        # Read file content
        file_content = await file.read()
        
        service_output_path = XMLConversionService.excel_xml_to_xlsx(file_content)
        
        # Rename/Move to desired filename
        output_filename = _determine_output_filename(filename, file, "excel_xml_to_xlsx", ".xlsx")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        # If paths are different, move/rename
        if os.path.abspath(service_output_path) != os.path.abspath(output_path):
            shutil.move(service_output_path, output_path)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "excel-xml-to-xlsx",
            f"File: {file.filename}",
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel XML converted to XLSX successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "excel-xml-to-xlsx",
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


# XML/XSD Validator
@router.post("/xml-xsd-validator", response_model=ConversionResponse)
async def validate_xml_xsd(
    xml_content: Optional[str] = Form(None),
    file_xml: Union[UploadFile, str, None] = File(None),
    xsd_content: Optional[str] = Form(None),
    file_xsd: Union[UploadFile, str, None] = File(None)
):
    """Validate XML against XSD schema. Check both text or file inputs."""
    xml_input_path = None
    xsd_input_path = None
    try:
        # Get XML Content
        xml_text, xml_input_path = await _get_content_from_file_or_text(file_xml, xml_content, "XML")
        
        if not xml_text:
            raise FileProcessingError("Please provide XML content or file")

        # Get XSD Content (Optional)
        xsd_text, xsd_input_path = await _get_content_from_file_or_text(file_xsd, xsd_content, "XSD")
        
        result = XMLConversionService.xml_xsd_validator(xml_text, xsd_text)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-xsd-validator",
            xml_text[:500] if len(xml_text) > 500 else xml_text,
            json.dumps(result),
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML validation completed successfully",
            converted_data=json.dumps(result)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-xsd-validator",
            "",
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
    finally:
        _cleanup_files(xml_input_path, xsd_input_path)


# JSON to XML
@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(
    json_text: Optional[str] = Form(None),
    file: Union[UploadFile, str, None] = File(None),
    filename: Optional[str] = Form(None),
    root_name: str = Form("root")
):
    """Convert JSON to XML. Supports file upload or text."""
    input_path = None
    try:
        content, input_path = await _get_content_from_file_or_text(file, json_text, "JSON")
        
        if not content:
            raise FileProcessingError("Please provide either JSON file or text")

        # Parse JSON
        try:
            json_data = json.loads(content)
        except json.JSONDecodeError as e:
            raise FileProcessingError(f"Invalid JSON format: {str(e)}")

        result = XMLConversionService.json_to_xml(json_data, root_name)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "json_to_xml", ".xml")
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(result)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "json-to-xml",
            content[:500] if len(content) > 500 else content,
            f"Output: {output_filename}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to XML successfully",
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "json-to-xml",
            "",
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
    finally:
        _cleanup_files(input_path)


# Download endpoint for generated files
@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download a generated file."""
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
        logger.error(f"Error downloading file {filename}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error downloading file: {str(e)}")
