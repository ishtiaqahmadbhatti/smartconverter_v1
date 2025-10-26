import json
import os
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from fastapi.responses import FileResponse
from typing import Optional, Dict, Any, List
from pydantic import BaseModel
from app.models.schemas import ConversionResponse
from app.services.json_conversion_service import JSONConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService
# from app.api.v1.dependencies import get_current_user  # Removed authentication

router = APIRouter()


# Request/Response Models
class XMLToJSONRequest(BaseModel):
    xml_content: str

class JSONToXMLRequest(BaseModel):
    json_data: Dict[str, Any]
    root_name: Optional[str] = "root"

class JSONFormatRequest(BaseModel):
    json_data: Dict[str, Any]

class JSONValidateRequest(BaseModel):
    json_content: str

class JSONToCSVRequest(BaseModel):
    json_data: List[Dict[str, Any]]
    delimiter: Optional[str] = ","

class JSONToYAMLRequest(BaseModel):
    json_data: Dict[str, Any]

class YAMLToJSONRequest(BaseModel):
    yaml_content: str

class JSONObjectsToCSVRequest(BaseModel):
    json_objects: List[Dict[str, Any]]
    delimiter: Optional[str] = ","

class JSONObjectsToExcelRequest(BaseModel):
    json_objects: List[Dict[str, Any]]


# XML to JSON
@router.post("/xml-to-json", response_model=ConversionResponse)
async def convert_xml_to_json(
    request: XMLToJSONRequest
):
    """Convert XML to JSON format."""
    try:
        result = JSONConversionService.xml_to_json(request.xml_content)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "xml-to-json",
            request.xml_content,
            json.dumps(result),
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="XML converted to JSON successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "xml-to-json",
            request.xml_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "xml-to-json",
            request.xml_content,
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
    request: JSONToXMLRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON to XML format."""
    try:
        result = JSONConversionService.json_to_xml(request.json_data, request.root_name)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to XML successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
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


# JSON Formatter
@router.post("/json-formatter", response_model=ConversionResponse)
async def format_json(
    request: JSONFormatRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Format JSON with proper indentation."""
    try:
        result = JSONConversionService.format_json(request.json_data)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON formatted successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
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


# JSON Validator (accepts JSON directly)
@router.post("/json-validator")
async def validate_json(json_data: dict):
    """Validate JSON directly without string wrapper."""
    try:
        # Convert dict to JSON string for validation
        json_string = json.dumps(json_data)
        result = JSONConversionService.validate_json(json_string)
        
        # Log validation without user info
        JSONConversionService.log_conversion(
            "json-validator",
            json_string,
            json.dumps(result),
            result.get("valid", False),
            None if result.get("valid") else result.get("message"),
            None
        )
        
        return result
        
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-validator",
            str(json_data),
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


# Public JSON Formatter (no authentication required)
@router.post("/public/json-formatter", response_model=ConversionResponse)
async def format_json_public(request: JSONFormatRequest):
    """Format JSON with proper indentation (public endpoint)."""
    try:
        result = JSONConversionService.format_json(request.json_data)
        
        # Log conversion without user info
        JSONConversionService.log_conversion(
            "json-formatter-public",
            json.dumps(request.json_data),
            result,
            True,
            None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON formatted successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-formatter-public",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-formatter-public",
            json.dumps(request.json_data),
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
    request: JSONToCSVRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON to CSV format."""
    try:
        result = JSONConversionService.json_to_csv(request.json_data, request.delimiter)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to CSV successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
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


# JSON to Excel
@router.post("/json-to-excel", response_model=ConversionResponse)
async def convert_json_to_excel(
    request: JSONObjectsToExcelRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON to Excel file."""
    try:
        output_path = JSONConversionService.json_to_excel(request.json_objects)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
            f"File: {output_path}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to Excel successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
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


# Excel to JSON
@router.post("/excel-to-json", response_model=ConversionResponse)
async def convert_excel_to_json(
    file: UploadFile = File(...),
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert Excel file to JSON."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to JSON
        result = JSONConversionService.excel_to_json(input_path)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename}",
            json.dumps(result),
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="Excel converted to JSON successfully",
            converted_data=result
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename if file else 'unknown'}",
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
        # Cleanup temporary files
        if input_path:
            JSONConversionService.cleanup_temp_files(input_path)


# CSV to JSON
@router.post("/csv-to-json", response_model=ConversionResponse)
async def convert_csv_to_json(
    file: UploadFile = File(...),
    delimiter: str = Form(","),
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert CSV file to JSON."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Read CSV content
        with open(input_path, 'r', encoding='utf-8') as f:
            csv_content = f.read()
        
        # Convert CSV to JSON
        result = JSONConversionService.csv_to_json(csv_content, delimiter)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename}",
            json.dumps(result),
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="CSV converted to JSON successfully",
            converted_data=result
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename if file else 'unknown'}",
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
        # Cleanup temporary files
        if input_path:
            JSONConversionService.cleanup_temp_files(input_path)


# JSON to YAML
@router.post("/json-to-yaml", response_model=ConversionResponse)
async def convert_json_to_yaml(
    request: JSONToYAMLRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON to YAML format."""
    try:
        result = JSONConversionService.json_to_yaml(request.json_data)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON converted to YAML successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
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


# YAML to JSON
@router.post("/yaml-to-json", response_model=ConversionResponse)
async def convert_yaml_to_json(
    request: YAMLToJSONRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert YAML to JSON format."""
    try:
        result = JSONConversionService.yaml_to_json(request.yaml_content)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
            json.dumps(result),
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="YAML converted to JSON successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
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
    request: JSONObjectsToCSVRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON objects array to CSV format."""
    try:
        result = JSONConversionService.json_objects_to_csv(request.json_objects, request.delimiter)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
            result,
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON objects converted to CSV successfully",
            converted_data=result
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
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


# JSON Objects to Excel
@router.post("/json-objects-to-excel", response_model=ConversionResponse)
async def convert_json_objects_to_excel(
    request: JSONObjectsToExcelRequest,
    # current_user: dict = Depends(get_current_user)  # Removed authentication
):
    """Convert JSON objects array to Excel file."""
    try:
        output_path = JSONConversionService.json_objects_to_excel(request.json_objects)
        
        # Log conversion
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
            f"File: {output_path}",
            True,
            user_id=None
        )
        
        return ConversionResponse(
            success=True,
            message="JSON objects converted to Excel successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
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
    """Download converted file."""
    from app.core.config import settings
    import os
    
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
