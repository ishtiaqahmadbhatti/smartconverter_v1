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
