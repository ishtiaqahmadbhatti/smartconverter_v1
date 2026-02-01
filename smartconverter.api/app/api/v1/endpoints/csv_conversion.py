"""
CSV Conversion API Endpoints

This module provides API endpoints for various CSV conversion operations.
"""

import json
import logging
from typing import Optional, List
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Depends, Request
from fastapi.responses import JSONResponse, FileResponse, Response
import shutil
import os
import uuid
from sqlalchemy.orm import Session

from app.services.csv_conversion_service import CSVConversionService
from app.services.conversion_log_service import ConversionLogService
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.services.file_service import FileService
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
    return f"/api/v1/csvconversiontools/download/{filename}"

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


# HTML Table to CSV
@router.post("/html-table-to-csv", response_model=ConversionResponse)
async def convert_html_table_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert HTML table to CSV. Requires HTML file upload."""
    
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
        conversion_type="html-table-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="html",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = CSVConversionService.html_table_to_csv(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "html_table_to_csv", ".csv")
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
            message="HTML table converted to CSV successfully",
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


# Excel to CSV
@router.post("/excel-to-csv", response_model=ConversionResponse)
async def convert_excel_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert Excel file to CSV."""
    
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
        input_file_type="xlsx", # Assuming xlsx/xls
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.excel_to_csv(file_content)
        
        # Determine filename
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
            message="Excel file converted to CSV successfully",
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


# OpenOffice Calc ODS to CSV
@router.post("/ods-to-csv", response_model=ConversionResponse)
async def convert_ods_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert OpenOffice Calc ODS file to CSV."""
    
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
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.ods_to_csv(file_content)
        
        # Determine filename
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
            message="ODS file converted to CSV successfully",
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


# CSV to Excel
@router.post("/csv-to-excel", response_model=ConversionResponse)
async def convert_csv_to_excel(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert CSV to Excel file. Requires CSV file upload."""
    
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
        content = await _read_file_content(file)
        
        # Service method saves file directly and returns path
        service_output_path = CSVConversionService.csv_to_excel(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "csv_to_excel", ".xlsx")
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
            message="CSV converted to Excel successfully",
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


# CSV to XML
@router.post("/csv-to-xml", response_model=ConversionResponse)
async def convert_csv_to_xml(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    root_name: str = Form("data"),
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
        
        result = CSVConversionService.csv_to_xml(content, root_name)
        
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
        
        result = CSVConversionService.xml_to_csv(content)
        
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


# PDF to CSV
@router.post("/pdf-to-csv", response_model=ConversionResponse)
async def convert_pdf_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert PDF to CSV. Requires PDF file upload."""
    
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
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.pdf_to_csv(file_content)
        
        # Determine filename
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
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# JSON to CSV
@router.post("/json-to-csv", response_model=ConversionResponse)
async def convert_json_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JSON to CSV. Requires JSON file upload."""
    
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
        conversion_type="json-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="json", # Assuming json
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        # Parse JSON
        try:
            json_data = json.loads(content)
        except json.JSONDecodeError:
            raise FileProcessingError("Invalid JSON file")

        result = CSVConversionService.json_to_csv(json_data)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "json_to_csv", ".csv")
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
            message="JSON converted to CSV successfully",
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


# CSV to JSON
@router.post("/csv-to-json", response_model=ConversionResponse)
async def convert_csv_to_json(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert CSV to JSON. Requires CSV file upload."""
    
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
        conversion_type="csv-to-json",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="csv",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = CSVConversionService.csv_to_json(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "csv_to_json", ".json")
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
            message="CSV converted to JSON successfully",
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


# JSON Objects to CSV
@router.post("/json-objects-to-csv", response_model=ConversionResponse)
async def convert_json_objects_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert JSON objects to CSV. Requires JSON file upload."""
    
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
        conversion_type="json-objects-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="json", # Assuming json
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        try:
             json_objects = json.loads(content)
             if not isinstance(json_objects, list):
                 raise FileProcessingError("JSON file must contain a list of objects")
        except json.JSONDecodeError:
            raise FileProcessingError("Invalid JSON file")

        result = CSVConversionService.json_objects_to_csv(json_objects)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "json_objects_to_csv", ".csv")
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
            message="JSON objects converted to CSV successfully",
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


# BSON to CSV
@router.post("/bson-to-csv", response_model=ConversionResponse)
async def convert_bson_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert BSON file to CSV. Requires BSON file upload."""
    
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
        conversion_type="bson-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="bson",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.bson_to_csv(file_content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "bson_to_csv", ".csv")
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
            message="BSON file converted to CSV successfully",
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


# SRT to CSV
@router.post("/srt-to-csv", response_model=ConversionResponse)
async def convert_srt_to_csv(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert SRT subtitle file to CSV. Requires SRT file upload."""
    
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
        conversion_type="srt-to-csv",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="srt",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = CSVConversionService.srt_to_csv(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "srt_to_csv", ".csv")
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
            message="SRT file converted to CSV successfully",
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


# CSV to SRT
@router.post("/csv-to-srt", response_model=ConversionResponse)
async def convert_csv_to_srt(
    request: Request,
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert CSV to SRT subtitle file. Requires CSV file upload."""
    
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
        conversion_type="csv-to-srt",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="csv",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )

    try:
        content = await _read_file_content(file)
        
        result = CSVConversionService.csv_to_srt(content)
        
        # Determine filename
        output_filename = _determine_output_filename(filename, file, "csv_to_srt", ".srt")
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
            message="CSV converted to SRT successfully",
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
