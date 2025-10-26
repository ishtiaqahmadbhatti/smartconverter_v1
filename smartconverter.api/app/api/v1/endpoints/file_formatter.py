import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.file_formatter_service import FileFormatterService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/format-json", response_model=ConversionResponse)
async def format_json(
    file: UploadFile = File(...),
    indent: int = Form(2),
    sort_keys: bool = Form(False)
):
    """Format JSON file with proper indentation and sorting."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Format JSON
        output_path = FileFormatterService.format_json(input_path, indent, sort_keys)
        
        return ConversionResponse(
            success=True,
            message="JSON file formatted successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)


@router.post("/validate-json")
async def validate_json(
    file: UploadFile = File(...),
    schema_file: Optional[UploadFile] = File(None)
):
    """Validate JSON file against schema or basic JSON syntax."""
    input_path = None
    schema_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Save schema file if provided
        if schema_file:
            FileService.validate_file(schema_file)
            schema_path = FileService.save_uploaded_file(schema_file)
        
        # Validate JSON
        validation_result = FileFormatterService.validate_json(input_path, schema_path)
        
        return {
            "success": True,
            "message": "JSON validation completed",
            "validation_result": validation_result
        }
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)
        if schema_path:
            FileFormatterService.cleanup_temp_files(schema_path)


@router.post("/validate-xml")
async def validate_xml(
    file: UploadFile = File(...),
    xsd_file: Optional[UploadFile] = File(None)
):
    """Validate XML file against XSD schema or basic XML syntax."""
    input_path = None
    xsd_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Save XSD file if provided
        if xsd_file:
            FileService.validate_file(xsd_file)
            xsd_path = FileService.save_uploaded_file(xsd_file)
        
        # Validate XML
        validation_result = FileFormatterService.validate_xml(input_path, xsd_path)
        
        return {
            "success": True,
            "message": "XML validation completed",
            "validation_result": validation_result
        }
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)
        if xsd_path:
            FileFormatterService.cleanup_temp_files(xsd_path)


@router.post("/validate-xsd")
async def validate_xsd(file: UploadFile = File(...)):
    """Validate XSD schema file."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Validate XSD
        validation_result = FileFormatterService.validate_xsd(input_path)
        
        return {
            "success": True,
            "message": "XSD validation completed",
            "validation_result": validation_result
        }
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)


@router.post("/minify-json", response_model=ConversionResponse)
async def minify_json(file: UploadFile = File(...)):
    """Minify JSON file by removing unnecessary whitespace."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Minify JSON
        output_path = FileFormatterService.minify_json(input_path)
        
        return ConversionResponse(
            success=True,
            message="JSON file minified successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)


@router.post("/format-xml", response_model=ConversionResponse)
async def format_xml(
    file: UploadFile = File(...),
    indent: int = Form(2)
):
    """Format XML file with proper indentation."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Format XML
        output_path = FileFormatterService.format_xml(input_path, indent)
        
        return ConversionResponse(
            success=True,
            message="XML file formatted successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)


@router.post("/json-schema-info")
async def get_json_schema_info(file: UploadFile = File(...)):
    """Get information about JSON structure and schema."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Get JSON schema info
        schema_info = FileFormatterService.get_json_schema_info(input_path)
        
        return {
            "success": True,
            "message": "JSON schema analysis completed",
            "schema_info": schema_info
        }
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            FileFormatterService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input formats."""
    try:
        formats = FileFormatterService.get_supported_formats()
        return {
            "success": True,
            "formats": formats,
            "message": "Supported formats retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported formats",
            details={"error": str(e)},
            status_code=500
        )


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
