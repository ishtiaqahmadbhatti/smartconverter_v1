"""
CSV Conversion API Endpoints

This module provides API endpoints for various CSV conversion operations.
"""

import json
import logging
from typing import Optional, List
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse, FileResponse

from app.services.csv_conversion_service import CSVConversionService
from app.core.exceptions import create_error_response
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()


# HTML Table to CSV
@router.post("/html-table-to-csv", response_model=ConversionResponse)
async def convert_html_table_to_csv(
    html_content: str = Form(...)
):
    """Convert HTML table to CSV."""
    try:
        result = CSVConversionService.html_table_to_csv(html_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
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
        CSVConversionService.log_conversion(
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


# Excel to CSV
@router.post("/excel-to-csv", response_model=ConversionResponse)
async def convert_excel_to_csv(
    file: UploadFile = File(...)
):
    """Convert Excel file to CSV."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.excel_to_csv(file_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "excel-to-csv",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "excel-to-csv",
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


# OpenOffice Calc ODS to CSV
@router.post("/ods-to-csv", response_model=ConversionResponse)
async def convert_ods_to_csv(
    file: UploadFile = File(...)
):
    """Convert OpenOffice Calc ODS file to CSV."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.ods_to_csv(file_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "ods-to-csv",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="ODS file converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "ods-to-csv",
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


# CSV to Excel
@router.post("/csv-to-excel", response_model=ConversionResponse)
async def convert_csv_to_excel(
    csv_content: str = Form(...)
):
    """Convert CSV to Excel file."""
    try:
        result = CSVConversionService.csv_to_excel(csv_content)
        
        # Create download URL
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/csvconversiontools/download/{filename}"
        
        # Log conversion
        CSVConversionService.log_conversion(
            "csv-to-excel",
            csv_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to Excel successfully",
            output_filename=filename,
            download_url=download_url
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "csv-to-excel",
            csv_content,
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


# CSV to XML
@router.post("/csv-to-xml", response_model=ConversionResponse)
async def convert_csv_to_xml(
    csv_content: str = Form(...),
    root_name: str = Form("data")
):
    """Convert CSV to XML."""
    try:
        result = CSVConversionService.csv_to_xml(csv_content, root_name)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "csv-to-xml",
            csv_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to XML successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "csv-to-xml",
            csv_content,
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
    xml_content: str = Form(...)
):
    """Convert XML to CSV."""
    try:
        result = CSVConversionService.xml_to_csv(xml_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "xml-to-csv",
            xml_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "xml-to-csv",
            xml_content,
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


# PDF to CSV
@router.post("/pdf-to-csv", response_model=ConversionResponse)
async def convert_pdf_to_csv(
    file: UploadFile = File(...)
):
    """Convert PDF to CSV."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.pdf_to_csv(file_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "pdf-to-csv",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "pdf-to-csv",
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


# JSON to CSV
@router.post("/json-to-csv", response_model=ConversionResponse)
async def convert_json_to_csv(
    json_data: dict
):
    """Convert JSON to CSV."""
    try:
        result = CSVConversionService.json_to_csv(json_data)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "json-to-csv",
            json.dumps(json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "json-to-csv",
            json.dumps(json_data) if json_data else "",
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


# CSV to JSON
@router.post("/csv-to-json", response_model=ConversionResponse)
async def convert_csv_to_json(
    csv_content: str = Form(...)
):
    """Convert CSV to JSON."""
    try:
        result = CSVConversionService.csv_to_json(csv_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "csv-to-json",
            csv_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to JSON successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "csv-to-json",
            csv_content,
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


# JSON Objects to CSV
@router.post("/json-objects-to-csv", response_model=ConversionResponse)
async def convert_json_objects_to_csv(
    json_objects: List[dict]
):
    """Convert JSON objects to CSV."""
    try:
        result = CSVConversionService.json_objects_to_csv(json_objects)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(json_objects),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON objects converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(json_objects) if json_objects else "",
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


# BSON to CSV
@router.post("/bson-to-csv", response_model=ConversionResponse)
async def convert_bson_to_csv(
    file: UploadFile = File(...)
):
    """Convert BSON file to CSV."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = CSVConversionService.bson_to_csv(file_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "bson-to-csv",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="BSON file converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "bson-to-csv",
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


# SRT to CSV
@router.post("/srt-to-csv", response_model=ConversionResponse)
async def convert_srt_to_csv(
    srt_content: str = Form(...)
):
    """Convert SRT subtitle file to CSV."""
    try:
        result = CSVConversionService.srt_to_csv(srt_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "srt-to-csv",
            srt_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="SRT file converted to CSV successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "srt-to-csv",
            srt_content,
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


# CSV to SRT
@router.post("/csv-to-srt", response_model=ConversionResponse)
async def convert_csv_to_srt(
    csv_content: str = Form(...)
):
    """Convert CSV to SRT subtitle file."""
    try:
        result = CSVConversionService.csv_to_srt(csv_content)
        
        # Log conversion
        CSVConversionService.log_conversion(
            "csv-to-srt",
            csv_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to SRT successfully",
            converted_data=result
        )
        
    except Exception as e:
        CSVConversionService.log_conversion(
            "csv-to-srt",
            csv_content,
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
