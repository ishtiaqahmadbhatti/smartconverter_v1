"""
XML Conversion API Endpoints

This module provides API endpoints for various XML conversion operations.
"""

import json
import logging
from typing import Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse, FileResponse

from app.services.xml_conversion_service import XMLConversionService
from app.core.exceptions import create_error_response
from app.models.schemas import ConversionResponse

logger = logging.getLogger(__name__)

router = APIRouter()


# CSV to XML
@router.post("/csv-to-xml", response_model=ConversionResponse)
async def convert_csv_to_xml(
    csv_content: str = Form(...),
    root_name: str = Form("data"),
    record_name: str = Form("record")
):
    """Convert CSV to XML."""
    try:
        result = XMLConversionService.csv_to_xml(csv_content, root_name, record_name)
        
        # Log conversion
        XMLConversionService.log_conversion(
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
        XMLConversionService.log_conversion(
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


# Excel to XML
@router.post("/excel-to-xml", response_model=ConversionResponse)
async def convert_excel_to_xml(
    file: UploadFile = File(...),
    root_name: str = Form("data"),
    record_name: str = Form("record")
):
    """Convert Excel file to XML."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = XMLConversionService.excel_to_xml(file_content, root_name, record_name)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "excel-to-xml",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to XML successfully",
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
    file: Optional[UploadFile] = File(None)
):
    """
    Convert XML to JSON.
    Accepts either XML content (as string) or XML file upload.
    """
    import os
    from app.services.file_service import FileService
    from app.core.config import settings
    
    xml_data = None
    input_path = None
    
    try:
        # Get XML data from either content or file
        if file and file.filename:
            # Read XML from uploaded file
            input_path = FileService.save_uploaded_file(file)
            with open(input_path, 'r', encoding='utf-8') as f:
                xml_data = f.read()
        elif xml_content:
            # Use XML content directly
            xml_data = xml_content
        else:
            raise ValueError("Either xml_content or file must be provided")
        
        # Convert XML to JSON
        json_result = XMLConversionService.xml_to_json(xml_data)
        
        # Save JSON to file for download
        import uuid
        output_filename = f"xml_to_json_{uuid.uuid4().hex[:8]}.json"
        output_path = os.path.join(settings.output_dir, output_filename)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(json_result)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if len(xml_data) > 500 else xml_data,  # Log first 500 chars
            json_result[:500] if len(json_result) > 500 else json_result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to JSON successfully",
            converted_data=json_result,  # JSON content as string (for preview)
            output_filename=output_filename,  # JSON file name (for download)
            download_url=f"/api/v1/xmlconversiontools/download/{output_filename}"  # Full download URL
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if xml_data and len(xml_data) > 500 else (xml_data or ""),
            "",
            False,
            str(e),
            None
        )
        # Cleanup uploaded file if exists
        if input_path:
            try:
                FileService.cleanup_file(input_path)
            except:
                pass
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
        result = XMLConversionService.xml_to_csv(xml_content)
        
        # Log conversion
        XMLConversionService.log_conversion(
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
        XMLConversionService.log_conversion(
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


# XML to Excel
@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(
    xml_content: str = Form(...)
):
    """Convert XML to Excel file."""
    try:
        result = XMLConversionService.xml_to_excel(xml_content)
        
        # Create download URL
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/xmlconversiontools/download/{filename}"
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-to-excel",
            xml_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to Excel successfully",
            output_filename=filename,
            download_url=download_url
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "xml-to-excel",
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


# Fix XML Escaping
@router.post("/fix-xml-escaping", response_model=ConversionResponse)
async def fix_xml_escaping(
    xml_content: str = Form(...)
):
    """Fix XML escaping issues."""
    try:
        result = XMLConversionService.fix_xml_escaping(xml_content)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "fix-xml-escaping",
            xml_content,
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML escaping fixed successfully",
            converted_data=result
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "fix-xml-escaping",
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


# Convert Excel XML to Excel XLSX
@router.post("/excel-xml-to-xlsx", response_model=ConversionResponse)
async def convert_excel_xml_to_xlsx(
    file: UploadFile = File(...)
):
    """Convert Excel XML to Excel XLSX file."""
    try:
        # Read file content
        file_content = await file.read()
        
        result = XMLConversionService.excel_xml_to_xlsx(file_content)
        
        # Create download URL
        import os
        filename = os.path.basename(result)
        download_url = f"/api/v1/xmlconversiontools/download/{filename}"
        
        # Log conversion
        XMLConversionService.log_conversion(
            "excel-xml-to-xlsx",
            f"File: {file.filename}",
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel XML converted to XLSX successfully",
            output_filename=filename,
            download_url=download_url
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
    xml_content: str = Form(...),
    xsd_content: Optional[str] = Form(None)
):
    """Validate XML against XSD schema."""
    try:
        result = XMLConversionService.xml_xsd_validator(xml_content, xsd_content)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "xml-xsd-validator",
            xml_content,
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


# JSON to XML
@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(
    json_data: dict,
    root_name: str = Form("root")
):
    """Convert JSON to XML."""
    try:
        result = XMLConversionService.json_to_xml(json_data, root_name)
        
        # Log conversion
        XMLConversionService.log_conversion(
            "json-to-xml",
            json.dumps(json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to XML successfully",
            converted_data=result
        )
        
    except Exception as e:
        XMLConversionService.log_conversion(
            "json-to-xml",
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
