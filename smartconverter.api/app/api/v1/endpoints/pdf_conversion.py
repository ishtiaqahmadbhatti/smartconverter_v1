import os
from typing import List, Optional
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends
from fastapi.responses import FileResponse
from pydantic import BaseModel
from app.services.file_service import FileService
from app.services.pdf_conversion_service import PDFConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.api.v1.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter()


class PDFConversionResponse(BaseModel):
    """Response model for PDF conversion operations."""
    success: bool
    message: str
    output_filename: Optional[str] = None
    download_url: Optional[str] = None
    file_size_before: Optional[int] = None
    file_size_after: Optional[int] = None
    pages_processed: Optional[int] = None
    extracted_data: Optional[dict] = None


# AI: Convert PDF to JSON
@router.post("/pdf-to-json", response_model=PDFConversionResponse)
async def convert_pdf_to_json(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user)
):
    """AI: Convert PDF to JSON with structured data extraction."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to JSON
        output_path = FileService.get_output_path(input_path, "_converted.json")
        result_path = PDFConversionService.pdf_to_json(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to JSON successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to Markdown
@router.post("/pdf-to-markdown", response_model=PDFConversionResponse)
async def convert_pdf_to_markdown(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user)
):
    """AI: Convert PDF to Markdown format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Markdown
        output_path = FileService.get_output_path(input_path, "_converted.md")
        result_path = PDFConversionService.pdf_to_markdown(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Markdown successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to CSV
@router.post("/pdf-to-csv", response_model=PDFConversionResponse)
async def convert_pdf_to_csv(file: UploadFile = File(...)):
    """AI: Convert PDF to CSV format (extract tabular data)."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to CSV
        output_path = FileService.get_output_path(input_path, "_converted.csv")
        result_path = PDFConversionService.pdf_to_csv(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# AI: Convert PDF to Excel
@router.post("/pdf-to-excel", response_model=PDFConversionResponse)
async def convert_pdf_to_excel(file: UploadFile = File(...)):
    """AI: Convert PDF to Excel format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Excel
        output_path = FileService.get_output_path(input_path, "_converted.xlsx")
        result_path = PDFConversionService.pdf_to_excel(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert HTML to PDF
@router.post("/html-to-pdf", response_model=PDFConversionResponse)
async def convert_html_to_pdf(file: UploadFile = File(...)):
    """Convert HTML to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert HTML to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.html_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="HTML converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Word to PDF
@router.post("/word-to-pdf", response_model=PDFConversionResponse)
async def convert_word_to_pdf(file: UploadFile = File(...)):
    """Convert Word document to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Word to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.word_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="Word document converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PowerPoint to PDF
@router.post("/powerpoint-to-pdf", response_model=PDFConversionResponse)
async def convert_powerpoint_to_pdf(file: UploadFile = File(...)):
    """Convert PowerPoint to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PowerPoint to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.powerpoint_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PowerPoint converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert OXPS to PDF
@router.post("/oxps-to-pdf", response_model=PDFConversionResponse)
async def convert_oxps_to_pdf(file: UploadFile = File(...)):
    """Convert OXPS to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert OXPS to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.oxps_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="OXPS converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert JPG to PDF
@router.post("/jpg-to-pdf", response_model=PDFConversionResponse)
async def convert_jpg_to_pdf(file: UploadFile = File(...)):
    """Convert JPG image to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert JPG to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.image_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="JPG image converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PNG to PDF
@router.post("/png-to-pdf", response_model=PDFConversionResponse)
async def convert_png_to_pdf(file: UploadFile = File(...)):
    """Convert PNG image to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PNG to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.image_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PNG image converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Markdown to PDF
@router.post("/markdown-to-pdf", response_model=PDFConversionResponse)
async def convert_markdown_to_pdf(file: UploadFile = File(...)):
    """Convert Markdown to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Markdown to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.markdown_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="Markdown converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Excel to PDF
@router.post("/excel-to-pdf", response_model=PDFConversionResponse)
async def convert_excel_to_pdf(file: UploadFile = File(...)):
    """Convert Excel to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.excel_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="Excel converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert Excel to XPS
@router.post("/excel-to-xps", response_model=PDFConversionResponse)
async def convert_excel_to_xps(file: UploadFile = File(...)):
    """Convert Excel to XPS."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert Excel to XPS
        output_path = FileService.get_output_path(input_path, "_converted.xps")
        result_path = PDFConversionService.excel_to_xps(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="Excel converted to XPS successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert OpenOffice Calc ODS to PDF
@router.post("/ods-to-pdf", response_model=PDFConversionResponse)
async def convert_ods_to_pdf(file: UploadFile = File(...)):
    """Convert OpenOffice Calc ODS to PDF."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert ODS to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFConversionService.ods_to_pdf(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="ODS converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to CSV
@router.post("/pdf-to-csv-extract", response_model=PDFConversionResponse)
async def convert_pdf_to_csv_extract(file: UploadFile = File(...)):
    """Convert PDF to CSV (extract tabular data)."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to CSV
        output_path = FileService.get_output_path(input_path, "_extracted.csv")
        result_path = PDFConversionService.pdf_to_csv_extract(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Excel
@router.post("/pdf-to-excel-extract", response_model=PDFConversionResponse)
async def convert_pdf_to_excel_extract(file: UploadFile = File(...)):
    """Convert PDF to Excel (extract tabular data)."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Excel
        output_path = FileService.get_output_path(input_path, "_extracted.xlsx")
        result_path = PDFConversionService.pdf_to_excel_extract(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Word
@router.post("/pdf-to-word-extract", response_model=PDFConversionResponse)
async def convert_pdf_to_word_extract(file: UploadFile = File(...)):
    """Convert PDF to Word document."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Word
        output_path = FileService.get_output_path(input_path, "_extracted.docx")
        result_path = PDFConversionService.pdf_to_word_extract(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to Word successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to JPG
@router.post("/pdf-to-jpg", response_model=PDFConversionResponse)
async def convert_pdf_to_jpg(file: UploadFile = File(...)):
    """Convert PDF pages to JPG images."""
    input_path = None
    output_files = []
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to JPG
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_images"))
        result_files = PDFConversionService.pdf_to_image(input_path, output_dir, "jpg")
        output_files = result_files
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(result_files)} JPG images",
            output_filename=f"{len(result_files)}_images.zip",
            download_url=f"/download/jpg_conversion",
            pages_processed=len(result_files)
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to PNG
@router.post("/pdf-to-png", response_model=PDFConversionResponse)
async def convert_pdf_to_png(file: UploadFile = File(...)):
    """Convert PDF pages to PNG images."""
    input_path = None
    output_files = []
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to PNG
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_images"))
        result_files = PDFConversionService.pdf_to_image(input_path, output_dir, "png")
        output_files = result_files
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(result_files)} PNG images",
            output_filename=f"{len(result_files)}_images.zip",
            download_url=f"/download/png_conversion",
            pages_processed=len(result_files)
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to TIFF
@router.post("/pdf-to-tiff", response_model=PDFConversionResponse)
async def convert_pdf_to_tiff(file: UploadFile = File(...)):
    """Convert PDF pages to TIFF images."""
    input_path = None
    output_files = []
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to TIFF
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_images"))
        result_files = PDFConversionService.pdf_to_tiff(input_path, output_dir)
        output_files = result_files
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(result_files)} TIFF images",
            output_filename=f"{len(result_files)}_images.zip",
            download_url=f"/download/tiff_conversion",
            pages_processed=len(result_files)
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to SVG
@router.post("/pdf-to-svg", response_model=PDFConversionResponse)
async def convert_pdf_to_svg(file: UploadFile = File(...)):
    """Convert PDF pages to SVG."""
    input_path = None
    output_files = []
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to SVG
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_images"))
        result_files = PDFConversionService.pdf_to_svg(input_path, output_dir)
        output_files = result_files
        
        return PDFConversionResponse(
            success=True,
            message=f"PDF converted to {len(result_files)} SVG files",
            output_filename=f"{len(result_files)}_files.zip",
            download_url=f"/download/svg_conversion",
            pages_processed=len(result_files)
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to HTML
@router.post("/pdf-to-html", response_model=PDFConversionResponse)
async def convert_pdf_to_html(file: UploadFile = File(...)):
    """Convert PDF to HTML."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to HTML
        output_path = FileService.get_output_path(input_path, "_converted.html")
        result_path = PDFConversionService.pdf_to_html(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to HTML successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Convert PDF to Text
@router.post("/pdf-to-text", response_model=PDFConversionResponse)
async def convert_pdf_to_text(file: UploadFile = File(...)):
    """Convert PDF to plain text."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert PDF to Text
        output_path = FileService.get_output_path(input_path, "_converted.txt")
        result_path = PDFConversionService.pdf_to_text(input_path, output_path)
        
        return PDFConversionResponse(
            success=True,
            message="PDF converted to text successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
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
            PDFConversionService.cleanup_temp_files(input_path)


# Get supported formats
@router.get("/supported-formats")
async def get_supported_formats():
    """Get supported input and output formats."""
    try:
        formats = PDFConversionService.get_supported_formats()
        return {
            "success": True,
            "formats": formats,
            "message": "Supported formats retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )


# Download converted file
@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download a converted file."""
    try:
        file_path = os.path.join("outputs", filename)
        if os.path.exists(file_path):
            return FileResponse(
                path=file_path,
                filename=filename,
                media_type='application/octet-stream'
            )
        else:
            raise HTTPException(status_code=404, detail="File not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
