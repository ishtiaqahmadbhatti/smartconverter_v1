import json
import os
import uuid
import logging
from datetime import date, datetime
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



# Custom JSON Encoder to handle date/datetime objects
class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (date, datetime)):
            return obj.isoformat()
        return super().default(obj)


# Custom dependency to handle optional file upload (handles empty string from Swagger UI)
async def optional_file_upload(file: Union[UploadFile, str, None] = File(default=None)) -> Optional[UploadFile]:
    """Handle file upload that may be None, empty string, or actual file."""
    if file is None or file == "" or (isinstance(file, str) and not file.strip()):
        return None
    if isinstance(file, UploadFile):
        return file
    return None


logger = logging.getLogger(__name__)
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
    filename: Optional[str] = Form(None)
):
    """AI-assisted image to JSON conversion with OCR text extraction."""
    input_path: Optional[str] = None
    output_path: Optional[str] = None

    try:
        FileService.validate_file(file, "image")
        # Accept only PNG files
        ext = os.path.splitext(file.filename or "")[1].lower()
        if ext != ".png":
            raise UnsupportedFileTypeError("Only PNG image files are allowed for this tool.")

        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "png_to_json"
            output_filename = f"{base_name}.json"
        
        output_path = os.path.join(settings.output_dir, output_filename)
        
        # Convert image to JSON
        result_path = ImageConversionService.image_to_json(input_path, output_path=output_path)
        
        # Create download URL
        result_filename = os.path.basename(result_path)
        download_url = _build_download_url(result_filename)

        JSONConversionService.log_conversion(
            "ai-png-to-json",
            f"File: {file.filename}",
            f"Output: {result_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="AI: PNG converted to JSON successfully",
            output_filename=result_filename,
            download_url=download_url,
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
    filename: Optional[str] = Form(None)
):
    """AI-assisted JPG to JSON conversion with OCR text extraction."""
    input_path: Optional[str] = None
    output_path: Optional[str] = None

    try:
        FileService.validate_file(file, "image")
        # Accept only JPG/JPEG files
        ext = os.path.splitext(file.filename or "")[1].lower()
        if ext not in {".jpg", ".jpeg"}:
            raise UnsupportedFileTypeError("Only JPG/JPEG image files are allowed for this tool.")

        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "jpg_to_json"
            output_filename = f"{base_name}.json"
        
        output_path = os.path.join(settings.output_dir, output_filename)
        
        # Convert image to JSON
        result_path = ImageConversionService.image_to_json(input_path, output_path=output_path)
        
        # Create download URL
        result_filename = os.path.basename(result_path)
        download_url = _build_download_url(result_filename)

        JSONConversionService.log_conversion(
            "ai-jpg-to-json",
            f"File: {file.filename}",
            f"Output: {result_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="AI: JPG converted to JSON successfully",
            output_filename=result_filename,
            download_url=download_url,
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
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
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

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "xml_to_json"
            output_filename = f"{base_name}.json"

        output_path = os.path.join(settings.output_dir, output_filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(json_string)

        # Create download URL
        download_url = _build_download_url(output_filename)

        JSONConversionService.log_conversion(
            "xml-to-json",
            xml_data[:500] if xml_data and len(xml_data) > 500 else (xml_data or ""),
            f"Output: {output_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="XML converted to JSON successfully",
            output_filename=output_filename,
            download_url=download_url,
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
async def format_json(
    json_text: Optional[str] = Form(default=None),
    filename: Optional[str] = Form(default=None),
    indent: int = Form(default=2),
    file: Union[UploadFile, str, None] = File(default=None),
):
    """Format JSON with proper indentation. Supports both file upload and direct JSON text input."""
    input_path = None
    json_data_str = None
    
    try:
        # Handle file parameter (may be UploadFile, empty string, or None)
        actual_file = None
        if file is not None and file != "" and not (isinstance(file, str) and not file.strip()):
            # Check if it's an UploadFile by checking for the 'filename' attribute (duck typing)
            if hasattr(file, 'filename'):
                actual_file = file
        
        # Check if file is actually provided (has filename and content)
        has_file = (
            actual_file is not None 
            and hasattr(actual_file, 'filename') 
            and actual_file.filename 
            and actual_file.filename.strip() != ""
        )
        
        # Clean up json_text - ignore common placeholder values
        cleaned_json_text = None
        if json_text and json_text.strip():
            # Ignore common placeholder values from Swagger UI
            if json_text.strip().lower() not in ['string', 'null', 'none', '']:
                cleaned_json_text = json_text.strip()
        
        # Validate that at least one input method is provided
        if not has_file and not cleaned_json_text:
            raise FileProcessingError("Please provide either a JSON file or JSON text")
        
        # Handle file upload (priority over text)
        if has_file:
            input_path = FileService.save_uploaded_file(actual_file)
            with open(input_path, "r", encoding="utf-8") as f:
                json_data_str = f.read()
                if not json_data_str.strip():
                    raise FileProcessingError("Input file is empty")
        # Handle direct JSON text input
        elif cleaned_json_text:
            json_data_str = cleaned_json_text
        
        # Parse JSON
        try:
            parsed_json = json.loads(json_data_str)
        except json.JSONDecodeError as e:
            raise FileProcessingError(f"Invalid JSON format: {str(e)}")
        
        # Format JSON
        formatted_json = json.dumps(parsed_json, indent=indent, ensure_ascii=False, cls=DateTimeEncoder)
        
        # If file was uploaded, save formatted JSON to file and return download URL
        # If direct JSON text, just return formatted JSON in response
        if has_file:
            # Determine output filename
            if filename and filename.strip() and filename.lower() != "string":
                if not filename.lower().endswith('.json'):
                    filename += '.json'
                output_filename = filename
            else:
                base_name = os.path.splitext(actual_file.filename)[0] if actual_file.filename else "formatted"
                output_filename = f"{base_name}_formatted.json"
            
            # Save formatted JSON to file
            output_filename_path = FileService.get_output_path(output_filename, ".json")
            with open(output_filename_path, "w", encoding="utf-8") as f:
                f.write(formatted_json)
            
            final_filename = os.path.basename(output_filename_path)

            JSONConversionService.log_conversion(
                "json-formatter",
                json_data_str[:500] if len(json_data_str) > 500 else json_data_str,
                f"Output file: {final_filename}",
                True,
                user_id=None,
            )

            return ConversionResponse(
                success=True,
                message="JSON formatted successfully",
                output_filename=final_filename,
                download_url=_build_download_url(final_filename),
                converted_data=formatted_json,
            )
        else:
            # Direct JSON text - just return formatted content
            JSONConversionService.log_conversion(
                "json-formatter",
                json_data_str[:500] if len(json_data_str) > 500 else json_data_str,
                "Direct text formatting",
                True,
                user_id=None,
            )

            return ConversionResponse(
                success=True,
                message="JSON formatted successfully",
                converted_data=formatted_json,
            )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-formatter",
            json_data_str[:500] if json_data_str and len(json_data_str) > 500 else (json_data_str or ""),
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
            "json-formatter",
            f"File: {file.filename if file else 'JSON text input'}",
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
# 6. JSON Validator
# ---------------------------------------------------------------------------

@router.post("/json-validator")
async def validate_json(
    json_text: Optional[str] = Form(default=None),
    file: Union[UploadFile, str, None] = File(default=None),
):
    """Validate JSON. Supports both file upload and direct JSON text input."""
    input_path = None
    json_data_str = None
    
    try:
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
        
        # Clean up json_text
        cleaned_json_text = None
        if json_text and json_text.strip():
            if json_text.strip().lower() not in ['string', 'null', 'none', '']:
                cleaned_json_text = json_text.strip()
        
        # Validate input
        if not has_file and not cleaned_json_text:
            raise FileProcessingError("Please provide either a JSON file or JSON text")
        
        # Get JSON content
        if has_file:
            input_path = FileService.save_uploaded_file(actual_file)
            with open(input_path, "r", encoding="utf-8") as f:
                json_data_str = f.read()
                if not json_data_str.strip():
                    raise FileProcessingError("Input file is empty")
        elif cleaned_json_text:
            json_data_str = cleaned_json_text
        
        # Validate JSON
        is_valid = False
        error_message = None
        line_number = None
        column_number = None
        
        try:
            parsed_json = json.loads(json_data_str)
            is_valid = True
        except json.JSONDecodeError as e:
            is_valid = False
            error_message = str(e.msg)
            line_number = e.lineno
            column_number = e.colno
        except Exception as e:
            is_valid = False
            error_message = str(e)
        
        # Prepare response
        result = {
            "valid": is_valid,
            "message": "JSON is valid!" if is_valid else f"Invalid JSON: {error_message}",
        }
        
        if not is_valid:
            result["error"] = {
                "message": error_message,
                "line": line_number,
                "column": column_number,
            }
        
        # Log
        JSONConversionService.log_conversion(
            "json-validator",
            json_data_str[:500] if len(json_data_str) > 500 else json_data_str,
            json.dumps(result),
            is_valid,
            None if is_valid else error_message,
            None,
        )
        
        return result

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        JSONConversionService.log_conversion(
            "json-validator",
            json_data_str[:500] if json_data_str and len(json_data_str) > 500 else (json_data_str or ""),
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
            "json-validator",
            f"File: {file.filename if file and hasattr(file, 'filename') else 'JSON text input'}",
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
# 7. Convert JSON to XML
# ---------------------------------------------------------------------------

@router.post("/json-to-xml", response_model=ConversionResponse)
async def convert_json_to_xml(
    file: UploadFile = File(...),
    root_name: Optional[str] = Form("root"),
    filename: Optional[str] = Form(None)
):
    """
    Convert JSON to XML format.

    Only multipart/form-data with an uploaded JSON file is supported.
    """
    json_data: Optional[str] = None
    input_path: Optional[str] = None
    
    try:
        FileService.validate_file(file, "json")
        input_path = FileService.save_uploaded_file(file)
        with open(input_path, "r", encoding="utf-8") as f:
            json_data = f.read()

        # Parse JSON and convert to XML
        parsed_json = json.loads(json_data)
        xml_result = JSONConversionService.json_to_xml(parsed_json, root_name)

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.xml'):
                filename += '.xml'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_xml"
            output_filename = f"{base_name}.xml"

        output_path = os.path.join(settings.output_dir, output_filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(xml_result)

        # Create download URL
        download_url = _build_download_url(output_filename)

        JSONConversionService.log_conversion(
            "json-to-xml",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
            f"Output: {output_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to XML successfully",
            output_filename=output_filename,
            download_url=download_url,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-to-xml",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
            "json-to-xml",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
# 8. Convert JSON to CSV
# ---------------------------------------------------------------------------

@router.post("/json-to-csv", response_model=ConversionResponse)
async def convert_json_to_csv(
    file: UploadFile = File(...),
    delimiter: Optional[str] = Form(","),
    filename: Optional[str] = Form(None)
):
    """
    Convert JSON to CSV format.

    Only multipart/form-data with an uploaded JSON file is supported.
    """
    json_data: Optional[str] = None
    input_path: Optional[str] = None
    
    try:
        FileService.validate_file(file, "json")
        input_path = FileService.save_uploaded_file(file)
        with open(input_path, "r", encoding="utf-8") as f:
            json_data = f.read()

        # Parse JSON and convert to CSV
        parsed_json = json.loads(json_data)
        csv_result = JSONConversionService.json_to_csv(parsed_json, delimiter)

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.csv'):
                filename += '.csv'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_csv"
            output_filename = f"{base_name}.csv"

        output_path = os.path.join(settings.output_dir, output_filename)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(csv_result)

        # Create download URL
        download_url = _build_download_url(output_filename)

        JSONConversionService.log_conversion(
            "json-to-csv",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
            f"Output: {output_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to CSV successfully",
            output_filename=output_filename,
            download_url=download_url,
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-to-csv",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
            "json-to-csv",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
# 9. Convert JSON to Excel
# ---------------------------------------------------------------------------

@router.post("/json-to-excel", response_model=ConversionResponse)
async def convert_json_to_excel(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert JSON file to Excel."""
    input_path = None
    json_data = None
    
    try:
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Read and parse JSON
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                raise FileProcessingError("Input file is empty")
            try:
                parsed_json = json.loads(content)
                json_data = content  # For logging
            except json.JSONDecodeError as e:
                raise FileProcessingError(f"Invalid JSON format: {str(e)}")

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.xlsx'):
                filename += '.xlsx'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_excel"
            output_filename = f"{base_name}.xlsx"

        # Convert to Excel
        output_filename_path = JSONConversionService.json_to_excel(parsed_json, output_filename)
        
        final_filename = os.path.basename(output_filename_path)

        JSONConversionService.log_conversion(
            "json-to-excel",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to Excel successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-to-excel",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
            "json-to-excel",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
# 10. Convert Excel to JSON
# ---------------------------------------------------------------------------

@router.post("/excel-to-json", response_model=ConversionResponse)
async def convert_excel_to_json(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert Excel file to JSON."""
    input_path: Optional[str] = None

    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)

        # Convert to JSON
        result = JSONConversionService.excel_to_json(input_path)
        
        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "excel_to_json"
            output_filename = f"{base_name}.json"
        output_path = os.path.join(settings.output_dir, output_filename)
        
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
            
        final_filename = os.path.basename(output_path)
        download_url = _build_download_url(final_filename)

        JSONConversionService.log_conversion(
            "excel-to-json",
            f"File: {file.filename}",
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="Excel converted to JSON successfully",
            output_filename=final_filename,
            download_url=download_url,
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
    filename: Optional[str] = Form(None),
):
    """Convert CSV file to JSON."""
    input_path: Optional[str] = None

    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)

        with open(input_path, "r", encoding="utf-8") as f:
            csv_content = f.read()

        result = JSONConversionService.csv_to_json(csv_content, delimiter)

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "converted"
            output_filename = f"{base_name}.json"

        # Save JSON to file
        output_filename_path = FileService.get_output_path(output_filename, ".json")
        with open(output_filename_path, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)

        final_filename = os.path.basename(output_filename_path)

        JSONConversionService.log_conversion(
            "csv-to-json",
            f"File: {file.filename}",
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="CSV converted to JSON successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
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
async def convert_json_to_yaml(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert JSON file to YAML."""
    input_path = None
    json_data = None
    
    try:
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Read and parse JSON
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                raise FileProcessingError("Input file is empty")
            try:
                parsed_json = json.loads(content)
                json_data = content  # For logging
            except json.JSONDecodeError as e:
                raise FileProcessingError(f"Invalid JSON format: {str(e)}")

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.yaml'):
                filename += '.yaml'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_yaml"
            output_filename = f"{base_name}.yaml"

        # Convert to YAML
        yaml_content = JSONConversionService.json_to_yaml(parsed_json)
        
        # Save YAML to file
        output_filename_path = FileService.get_output_path(output_filename, ".yaml")
        with open(output_filename_path, "w", encoding="utf-8") as f:
            f.write(yaml_content)
        
        final_filename = os.path.basename(output_filename_path)

        JSONConversionService.log_conversion(
            "json-to-yaml",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON converted to YAML successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-to-yaml",
            json_data[:500] if json_data and len(json_data) > 500 else (json_data or ""),
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
async def convert_json_objects_to_csv(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
    delimiter: str = Form(","),
):
    """Convert JSON file (list of objects) to CSV."""
    input_path = None
    json_data_for_log = None

    try:
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)

        # Read and parse JSON
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                raise FileProcessingError("Input file is empty")
            try:
                parsed_json = json.loads(content)
                json_data_for_log = content  # For logging
            except json.JSONDecodeError as e:
                raise FileProcessingError(f"Invalid JSON format: {str(e)}")

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.csv'):
                filename += '.csv'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_csv"
            output_filename = f"{base_name}.csv"

        # Convert to CSV
        csv_content = JSONConversionService.json_objects_to_csv(parsed_json, delimiter=delimiter)

        # Save CSV to file
        output_filename_path = FileService.get_output_path(output_filename, ".csv")
        with open(output_filename_path, "w", encoding="utf-8", newline="") as f:
            f.write(csv_content)

        final_filename = os.path.basename(output_filename_path)

        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json_data_for_log[:500] if json_data_for_log and len(json_data_for_log) > 500 else (json_data_for_log or ""),
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON objects converted to CSV successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-objects-to-csv",
            json_data_for_log[:500] if json_data_for_log and len(json_data_for_log) > 500 else (json_data_for_log or ""),
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
            "json-objects-to-csv",
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
# 14. Convert JSON objects to Excel
# ---------------------------------------------------------------------------

@router.post("/json-objects-to-excel", response_model=ConversionResponse)
async def convert_json_objects_to_excel(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None),
):
    """Convert JSON file (list of objects) to Excel."""
    input_path = None
    json_data_for_log = None

    try:
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)

        # Read and parse JSON
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                raise FileProcessingError("Input file is empty")
            try:
                parsed_json = json.loads(content)
                json_data_for_log = content  # For logging
            except json.JSONDecodeError as e:
                raise FileProcessingError(f"Invalid JSON format: {str(e)}")

        # Validate it's a list of objects
        if not isinstance(parsed_json, list):
            raise FileProcessingError("Input must be a list of JSON objects")

        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.xlsx'):
                filename += '.xlsx'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "json_to_excel"
            output_filename = f"{base_name}.xlsx"

        # Convert to Excel using the service method
        output_path = JSONConversionService.json_objects_to_excel(parsed_json, filename=output_filename)

        final_filename = os.path.basename(output_path)

        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json_data_for_log[:500] if json_data_for_log and len(json_data_for_log) > 500 else (json_data_for_log or ""),
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="JSON objects converted to Excel successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "json-objects-to-excel",
            json_data_for_log[:500] if json_data_for_log and len(json_data_for_log) > 500 else (json_data_for_log or ""),
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
            "json-objects-to-excel",
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
# 15. Convert YAML to JSON
# ---------------------------------------------------------------------------

@router.post("/yaml-to-json", response_model=ConversionResponse)
async def convert_yaml_to_json(
    file: UploadFile = File(...),
    filename: Optional[str] = Form(None)
):
    """Convert YAML file to JSON."""
    input_path = None
    yaml_data = None
    
    try:
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Read YAML content
        with open(input_path, "r", encoding="utf-8") as f:
            content = f.read()
            if not content.strip():
                raise FileProcessingError("Input file is empty")
            yaml_data = content  # For logging

        # Convert to JSON
        parsed_data = JSONConversionService.yaml_to_json(content)
        
        # Determine output filename
        if filename and filename.strip() and filename.lower() != "string":
            if not filename.lower().endswith('.json'):
                filename += '.json'
            output_filename = filename
        else:
            base_name = os.path.splitext(file.filename)[0] if file.filename else "yaml_to_json"
            output_filename = f"{base_name}.json"

        # Save JSON to file
        output_filename_path = FileService.get_output_path(output_filename, ".json")
        with open(output_filename_path, "w", encoding="utf-8") as f:
            json.dump(parsed_data, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        
        final_filename = os.path.basename(output_filename_path)

        JSONConversionService.log_conversion(
            "yaml-to-json",
            yaml_data[:500] if yaml_data and len(yaml_data) > 500 else (yaml_data or ""),
            f"Output: {final_filename}",
            True,
            user_id=None,
        )

        return ConversionResponse(
            success=True,
            message="YAML converted to JSON successfully",
            output_filename=final_filename,
            download_url=_build_download_url(final_filename),
        )

    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError, ValueError) as e:
        JSONConversionService.log_conversion(
            "yaml-to-json",
            yaml_data[:500] if yaml_data and len(yaml_data) > 500 else (yaml_data or ""),
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
            "yaml-to-json",
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
