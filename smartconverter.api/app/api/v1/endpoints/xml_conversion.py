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
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Depends, Request, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.services.xml_conversion_service import XMLConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
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
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record"),
    db: Session = Depends(get_db)
):
    """Convert CSV to XML. Requires CSV file upload."""
    
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
        conversion_type="csv-to-xml",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="csv",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

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
            message="CSV converted to XML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Excel to XML
@router.post("/excel-to-xml", response_model=ConversionResponse)
async def convert_excel_to_xml(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
    record_name: str = Form("record"),
    db: Session = Depends(get_db)
):
    """Convert Excel file to XML."""
    
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
        input_file_type="xlsx", # Assuming xlsx/xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = XMLConversionService.excel_to_xml(file_content, root_name, record_name)
        
        # Determine filename
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
            message="Excel file converted to XML successfully",
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
            converted_data=result
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# XML to JSON
@router.post("/xml-to-json", response_model=ConversionResponse)
async def convert_xml_to_json(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """
    Convert XML to JSON.
    Requires XML file upload.
    """
    
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
        conversion_type="xml-to-json",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xml",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

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
            message="XML converted to JSON successfully",
            converted_data=json_result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# XML to CSV
@router.post("/xml-to-csv", response_model=ConversionResponse)
async def convert_xml_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XML to CSV. Requires XML file upload."""
    
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
        content = await _read_file_content(file)

        if not content.strip():
            raise FileProcessingError("XML file is empty")

        result = XMLConversionService.xml_to_csv(content)
        
        # Determine filename
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
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# XML to Excel
@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert XML to Excel file. Requires XML file upload."""
    
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
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Fix XML Escaping
@router.post("/fix-xml-escaping", response_model=ConversionResponse)
async def fix_xml_escaping(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Fix XML escaping issues. Requires XML file upload."""
    
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
        conversion_type="fix-xml-escaping",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="xml",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

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
            message="XML escaping fixed successfully",
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )





# XML/XSD Validator
@router.post("/xml-xsd-validator", response_model=ConversionResponse)
async def validate_xml_xsd(
    request: Request,
    file_xml: UploadFile = File(...),
    file_xsd: Union[UploadFile, str, None] = File(None),
    db: Session = Depends(get_db)
):
    """Validate XML against XSD schema. Requires XML file. XSD file is optional."""
    
    # Get file info for XML
    file_xml.file.seek(0, 2)
    input_size = file_xml.file.tell()
    file_xml.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)

    # Initial log
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="xml-xsd-validator",
        input_filename=file_xml.filename,
        input_file_size=input_size,
        input_file_type="xml",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Get XML Content
        xml_text = await _read_file_content(file_xml)
        
        if not xml_text.strip():
            raise FileProcessingError("XML file is empty")

        # Get XSD Content (Optional)
        xsd_text = None
        if file_xsd and isinstance(file_xsd, UploadFile):
            xsd_text = await _read_file_content(file_xsd)
        
        result = XMLConversionService.xml_xsd_validator(xml_text, xsd_text)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=None, # No output file for validation
            output_file_type=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML validation completed successfully",
            converted_data=json.dumps(result)
        )
        
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# JSON to XML
@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("root"),
    db: Session = Depends(get_db)
):
    """Convert JSON to XML. Requires JSON file upload."""
    
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
        conversion_type="json-to-xml",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="json", # Assuming json
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

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
            message="JSON converted to XML successfully",
            converted_data=result,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename)
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
