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

def _determine_output_filename(
    user_filename: Optional[str],
    input_file: UploadFile,
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

async def _read_file_content(file: UploadFile) -> str:
    """Read and decode file content to string."""
    try:
        content_bytes = await file.read()
        return content_bytes.decode('utf-8', errors='replace')
    except Exception as e:
        raise FileProcessingError(f"Error reading file content: {str(e)}")

# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

# CSV to XML
@router.post("/csv-to-xml", response_model=ConversionResponse)
async def convert_csv_to_xml(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record")
):
    """Convert CSV to XML. Requires CSV file upload."""
    try:
        content = await _read_file_content(file)
        
        if not content.strip():
             raise FileProcessingError("CSV file is empty")

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
            file.filename if file else "Unknown",
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
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """
    Convert XML to JSON.
    Requires XML file upload.
    """
    try:
        content = await _read_file_content(file)
        
        if not content.strip():
            raise FileProcessingError("XML file is empty")
        
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
            file.filename if file else "Unknown",
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


# XML to CSV
@router.post("/xml-to-csv", response_model=ConversionResponse)
async def convert_xml_to_csv(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert XML to CSV. Requires XML file upload."""
    try:
        content = await _read_file_content(file)

        if not content.strip():
            raise FileProcessingError("XML file is empty")

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


# XML to Excel
@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert XML to Excel file. Requires XML file upload."""
    try:
        content = await _read_file_content(file)

        if not content.strip():
            raise FileProcessingError("XML file is empty")

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


# Fix XML Escaping
@router.post("/fix-xml-escaping", response_model=ConversionResponse)
async def fix_xml_escaping(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Fix XML escaping issues. Requires XML file upload."""
    try:
        content = await _read_file_content(file)

        if not content.strip():
            raise FileProcessingError("XML file is empty")

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
    file_xml: UploadFile = File(...),
    file_xsd: Optional[UploadFile] = File(None)
):
    """Validate XML against XSD schema. Requires XML file. XSD file is optional."""
    try:
        # Get XML Content
        xml_text = await _read_file_content(file_xml)
        
        if not xml_text.strip():
            raise FileProcessingError("XML file is empty")

        # Get XSD Content (Optional)
        xsd_text = None
        if file_xsd:
            xsd_text = await _read_file_content(file_xsd)
        
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


# JSON to XML
@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("root")
):
    """Convert JSON to XML. Requires JSON file upload."""
    try:
        content = await _read_file_content(file)
        
        if not content.strip():
            raise FileProcessingError("JSON file is empty")

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
