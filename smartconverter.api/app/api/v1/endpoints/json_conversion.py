import json
import os
import uuid
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import FileResponse
from typing import Optional, Dict, Any, List, Union
from pydantic import BaseModel

from app.models.schemas import ConversionResponse
from app.services.json_conversion_service import JSONConversionService
from app.services.pdf_conversion_service import PDFConversionService
from app.services.image_conversion_service import ImageConversionService
from app.services.file_service import FileService
from app.core.config import settings
from app.core.exceptions import (
    FileProcessingError,
    UnsupportedFileTypeError,
    FileSizeExceededError,
    create_error_response,
)


router = APIRouter()


# ---------------------------------------------------------------------------
# Request Models
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------

def _build_download_url(filename: str) -> str:
    """Build consistent download url for generated files."""
    return f"/api/v1/jsonconversiontools/download/{filename}"


def _cleanup_files(*paths: Optional[str]) -> None:
    """Cleanup temporary files if they exist."""
    for path in paths:
        if path:
            FileService.cleanup_file(path)


# ---------------------------------------------------------------------------
# 1. AI: Convert PDF to JSON
# ---------------------------------------------------------------------------

@router.post("/ai/pdf-to-json", response_model=ConversionResponse)
async def ai_convert_pdf_to_json(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """AI-assisted PDF to JSON conversion with structured extraction."""
    input_path: Optional[str] = None
    output_path: Optional[str] = None

    try:
        FileService.validate_file(file, "document")
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "pdf_to_json"
            output_filename = f"{base_name}.json"
        
        output_path = os.path.join(settings.output_dir, output_filename)

        result_path = PDFConversionService.pdf_to_json(input_path, output_path)
        
        # Create download URL
        result_filename = os.path.basename(result_path)
        download_url = _build_download_url(result_filename)

        JSONConversionService.log_conversion(
            "ai-pdf-to-json",
            f"File: {file.filename}",
            f"Output: {result_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="AI: PDF converted to JSON successfully",
            output_filename=result_filename,
            download_url=download_url,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "ai-pdf-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "ai-pdf-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)



# ---------------------------------------------------------------------------
# 2. AI: Convert PNG to JSON
# ---------------------------------------------------------------------------

@router.post("/ai/png-to-json", response_model=ConversionResponse)
async def ai_convert_png_to_json(
    file: UploadFile = File(...),
    include_metadata: bool = Form(True),
):
    """AI-assisted PNG to JSON conversion (base64 + metadata)."""
    input_path: Optional[str] = None
    output_path: Optional[str] = None

    try:
        FileService.validate_file(file, "image")
        ext = os.path.splitext(file.filename or "")[1].lower()
        if ext != ".png":
            raise UnsupportedFileTypeError("Only PNG images are allowed for this tool.")

        input_path = FileService.save_uploaded_file(file)
        output_path = ImageConversionService.image_to_json(input_path, include_metadata)

        with open(output_path, "r", encoding="utf-8") as f:
            json_payload = f.read()

        JSONConversionService.log_conversion(
            "ai-png-to-json",
            f"File: {file.filename}",
            json_payload[:500],
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="AI: PNG converted to JSON successfully",
            output_filename=os.path.basename(output_path),
            download_url=_build_download_url(os.path.basename(output_path)),
            converted_data=json_payload,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "ai-png-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "ai-png-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)


# ---------------------------------------------------------------------------
# 3. AI: Convert JPG to JSON
# ---------------------------------------------------------------------------

@router.post("/ai/jpg-to-json", response_model=ConversionResponse)
async def ai_convert_jpg_to_json(
    file: UploadFile = File(...),
    include_metadata: bool = Form(True),
):
    """AI-assisted JPG/JPEG to JSON conversion (base64 + metadata)."""
    input_path: Optional[str] = None
    output_path: Optional[str] = None

    try:
        FileService.validate_file(file, "image")
        ext = os.path.splitext(file.filename or "")[1].lower()
        if ext not in {".jpg", ".jpeg"}:
            raise UnsupportedFileTypeError("Only JPG or JPEG images are allowed for this tool.")

        input_path = FileService.save_uploaded_file(file)
        output_path = ImageConversionService.image_to_json(input_path, include_metadata)

        with open(output_path, "r", encoding="utf-8") as f:
            json_payload = f.read()

        JSONConversionService.log_conversion(
            "ai-jpg-to-json",
            f"File: {file.filename}",
            json_payload[:500],
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="AI: JPG converted to JSON successfully",
            output_filename=os.path.basename(output_path),
            download_url=_build_download_url(os.path.basename(output_path)),
            converted_data=json_payload,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "ai-jpg-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "ai-jpg-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)


# ---------------------------------------------------------------------------
# 4. Convert XML to JSON
# ---------------------------------------------------------------------------

@router.post("/xml-to-json", response_model=ConversionResponse)
async def convert_xml_to_json(
    file: UploadFile = File(...)
):
    """
    Convert XML to JSON format.

    Only multipart/form-data with an uploaded XML file is supported.
    """
    xml_data: Optional[str] = None
    input_path: Optional[str] = None
    
    try:
        FileService.validate_file(file, "xml")
        input_path = FileService.save_uploaded_file(file)
        with open(input_path, "r", encoding="utf-8") as f:
            xml_data = f.read()

        json_result = JSONConversionService.xml_to_json(xml_data)
        json_string = json.dumps(json_result, indent=2)

        output_filename = f"xml_to_json_{uuid.uuid4().hex[:8]}.json"
        output_path = os.path.join(settings.output_dir, output_filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(json_string)

        JSONConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if xml_data and len(xml_data) > 500 else (xml_data or ""),
            json_string[:500] if len(json_string) > 500 else json_string,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="XML converted to JSON successfully",
            converted_data=json_string,
            output_filename=output_filename,
            download_url=_build_download_url(output_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if xml_data and len(xml_data) > 500 else (xml_data or ""),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if xml_data and len(xml_data) > 500 else (xml_data or ""),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)


# ---------------------------------------------------------------------------
# 5. JSON Formatter
# ---------------------------------------------------------------------------

@router.post("/json-formatter", response_model=ConversionResponse)
async def format_json(request: JSONFormatRequest):
    """Format JSON with proper indentation."""
    try:
        formatted = JSONConversionService.format_json(request.json_data)

        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
            formatted,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON formatted successfully",
            converted_data=formatted,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-formatter",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 6. JSON Validator
# ---------------------------------------------------------------------------

@router.post("/json-validator")
async def validate_json(json_data: dict):
    """Validate JSON directly without string wrapper."""
    try:
        json_string = json.dumps(json_data)
        result = JSONConversionService.validate_json(json_string)

        JSONConversionService.log_conversion(
            "json-validator",
            json_string,
            json.dumps(result),
            result.get("valid", False),
            None if result.get("valid") else result.get("message"),
            None,
        )

        return result

    except Exception as e:
        JSONConversionService.log_conversion(
            "json-validator",
            str(json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 7. Convert JSON to XML
# ---------------------------------------------------------------------------

@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(request: JSONToXMLRequest):
    """Convert JSON to XML format."""
    try:
        result = JSONConversionService.json_to_xml(request.json_data, request.root_name)

        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to XML successfully",
            converted_data=result,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-xml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 8. Convert JSON to CSV
# ---------------------------------------------------------------------------

@router.post("/json-to-csv", response_model=ConversionResponse)
async def convert_json_to_csv(request: JSONToCSVRequest):
    """Convert JSON to CSV format."""
    try:
        result = JSONConversionService.json_to_csv(request.json_data, request.delimiter)

        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to CSV successfully",
            converted_data=result,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-csv",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 9. Convert JSON to Excel
# ---------------------------------------------------------------------------

@router.post("/json-to-excel", response_model=ConversionResponse)
async def convert_json_to_excel(request: JSONObjectsToExcelRequest):
    """Convert JSON to Excel file."""
    try:
        output_path = JSONConversionService.json_to_excel(request.json_objects)

        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
            f"File: {output_path}",
            True,
            user_id=None,
        )

        filename = os.path.basename(output_path)
        return ConversionResponse(
            success=True,
            message="JSON converted to Excel successfully",
            output_filename=filename,
            download_url=_build_download_url(filename),
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 10. Convert Excel to JSON
# ---------------------------------------------------------------------------

@router.post("/excel-to-json", response_model=ConversionResponse)
async def convert_excel_to_json(file: UploadFile = File(...)):
    """Convert Excel file to JSON."""
    input_path: Optional[str] = None

    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)

        result = JSONConversionService.excel_to_json(input_path)

        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename}",
            json.dumps(result),
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="Excel converted to JSON successfully",
            converted_data=result,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)


# ---------------------------------------------------------------------------
# 11. Convert CSV to JSON
# ---------------------------------------------------------------------------

@router.post("/csv-to-json", response_model=ConversionResponse)
async def convert_csv_to_json(
    file: UploadFile = File(...),
    delimiter: str = Form(","),
):
    """Convert CSV file to JSON."""
    input_path: Optional[str] = None

    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)

        with open(input_path, "r", encoding="utf-8") as f:
            csv_content = f.read()

        result = JSONConversionService.csv_to_json(csv_content, delimiter)

        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename}",
            json.dumps(result),
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="CSV converted to JSON successfully",
            converted_data=result,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename if file else 'unknown'}",
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )
    finally:
        _cleanup_files(input_path)


# ---------------------------------------------------------------------------
# 12. Convert JSON to YAML
# ---------------------------------------------------------------------------

@router.post("/json-to-yaml", response_model=ConversionResponse)
async def convert_json_to_yaml(request: JSONToYAMLRequest):
    """Convert JSON to YAML format."""
    try:
        result = JSONConversionService.json_to_yaml(request.json_data)

        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
            result,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to YAML successfully",
            converted_data=result,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json.dumps(request.json_data),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 13. Convert JSON objects to CSV
# ---------------------------------------------------------------------------

@router.post("/json-objects-to-csv", response_model=ConversionResponse)
async def convert_json_objects_to_csv(request: JSONObjectsToCSVRequest):
    """Convert JSON objects array to CSV format."""
    try:
        result = JSONConversionService.json_objects_to_csv(request.json_objects, request.delimiter)

        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
            result,
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON objects converted to CSV successfully",
            converted_data=result,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 14. Convert JSON objects to Excel
# ---------------------------------------------------------------------------

@router.post("/json-objects-to-excel", response_model=ConversionResponse)
async def convert_json_objects_to_excel(request: JSONObjectsToExcelRequest):
    """Convert JSON objects array to Excel file."""
    try:
        output_path = JSONConversionService.json_objects_to_excel(request.json_objects)

        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
            f"File: {output_path}",
            True,
            user_id=None,
        )

        filename = os.path.basename(output_path)
        return ConversionResponse(
            success=True,
            message="JSON objects converted to Excel successfully",
            output_filename=filename,
            download_url=_build_download_url(filename),
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json.dumps(request.json_objects),
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# 15. Convert YAML to JSON
# ---------------------------------------------------------------------------

@router.post("/yaml-to-json", response_model=ConversionResponse)
async def convert_yaml_to_json(request: YAMLToJSONRequest):
    """Convert YAML to JSON format."""
    try:
        result = JSONConversionService.yaml_to_json(request.yaml_content)

        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
            json.dumps(result),
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="YAML converted to JSON successfully",
            converted_data=result,
        )

    except FileProcessingError as e:
        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="FileProcessingError",
            message=str(e),
            status_code=400,
        )
    except Exception as e:
        JSONConversionService.log_conversion(
            "yaml-to-json",
            request.yaml_content,
            "",
            False,
            str(e),
            None,
        )
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500,
        )


# ---------------------------------------------------------------------------
# Download Endpoint
# ---------------------------------------------------------------------------

@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    file_path = os.path.join(settings.output_dir, filename)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(
        path=file_path,
        filename=filename,
        media_type="application/octet-stream",
    )
