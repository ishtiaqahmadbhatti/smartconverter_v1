import os
from typing import List, Optional
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form
from fastapi.responses import FileResponse
from pydantic import BaseModel
from app.models.schemas import (
    PDFOperationResponse, PDFMergeRequest, PDFSplitRequest, 
    PDFCompressRequest, PDFProtectRequest, PDFSignRequest,
    PDFRedactRequest, PDFCompareRequest
)
from app.services.file_service import FileService
from app.services.pdf_tools_service import PDFToolsService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)

router = APIRouter()


# PDF Merge
@router.post("/merge", response_model=PDFOperationResponse)
async def merge_pdfs(files: List[UploadFile] = File(...)):
    """Merge multiple PDF files into one."""
    input_paths = []
    output_path = None
    
    try:
        # Save uploaded files
        for file in files:
            FileService.validate_file(file)
            input_path = FileService.save_uploaded_file(file)
            input_paths.append(input_path)
        
        # Create output path
        output_path = FileService.get_output_path(input_paths[0], "_merged.pdf")
        
        # Merge PDFs
        result_path = PDFToolsService.merge_pdfs(input_paths, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="PDFs merged successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFMergeError",
            message=str(e),
            status_code=400
        )
    finally:
        # Cleanup input files
        for path in input_paths:
            if path:
                PDFToolsService.cleanup_temp_files(path)


# PDF Split
@router.post("/split", response_model=PDFOperationResponse)
async def split_pdf(
    file: UploadFile = File(...),
    split_type: str = Form("every_page"),
    page_ranges: Optional[str] = Form(None)
):
    """Split PDF into multiple files."""
    input_path = None
    output_files = []
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Parse page ranges if provided
        ranges = None
        if page_ranges:
            ranges = [r.strip() for r in page_ranges.split(',')]
        
        # Split PDF
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_split"))
        result_files = PDFToolsService.split_pdf(input_path, output_dir, split_type, ranges)
        output_files = result_files
        
        return PDFOperationResponse(
            success=True,
            message=f"PDF split into {len(result_files)} files",
            output_filename=f"{len(result_files)}_files.zip",  # Would need zip creation
            download_url=f"/download/split_results"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFSplitError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# PDF Compress
@router.post("/compress", response_model=PDFOperationResponse)
async def compress_pdf(
    file: UploadFile = File(...),
    compression_level: str = Form("medium")
):
    """Compress PDF file."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Get original file size
        original_size = os.path.getsize(input_path)
        
        # Compress PDF
        output_path = FileService.get_output_path(input_path, "_compressed.pdf")
        result_path = PDFToolsService.compress_pdf(input_path, output_path, compression_level)
        
        # Get compressed file size
        compressed_size = os.path.getsize(result_path)
        compression_ratio = (original_size - compressed_size) / original_size * 100
        
        return PDFOperationResponse(
            success=True,
            message="PDF compressed successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}",
            file_size_before=original_size,
            file_size_after=compressed_size,
            compression_ratio=compression_ratio
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFCompressError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Remove Pages
@router.post("/remove-pages", response_model=PDFOperationResponse)
async def remove_pages(
    file: UploadFile = File(...),
    pages_to_remove: str = Form(...)
):
    """Remove specific pages from PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Parse pages to remove
        pages = [int(p.strip()) for p in pages_to_remove.split(',')]
        
        # Remove pages
        output_path = FileService.get_output_path(input_path, "_pages_removed.pdf")
        result_path = PDFToolsService.remove_pages(input_path, output_path, pages)
        
        return PDFOperationResponse(
            success=True,
            message=f"Pages {pages} removed successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFRemovePagesError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Extract Pages
@router.post("/extract-pages", response_model=PDFOperationResponse)
async def extract_pages(
    file: UploadFile = File(...),
    pages_to_extract: str = Form(...)
):
    """Extract specific pages from PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Parse pages to extract
        pages = [int(p.strip()) for p in pages_to_extract.split(',')]
        
        # Extract pages
        output_path = FileService.get_output_path(input_path, "_extracted.pdf")
        result_path = PDFToolsService.extract_pages(input_path, output_path, pages)
        
        return PDFOperationResponse(
            success=True,
            message=f"Pages {pages} extracted successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFExtractPagesError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Rotate PDF
@router.post("/rotate", response_model=PDFOperationResponse)
async def rotate_pdf(
    file: UploadFile = File(...),
    rotation: int = Form(90)
):
    """Rotate PDF pages."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Rotate PDF
        output_path = FileService.get_output_path(input_path, f"_rotated_{rotation}.pdf")
        result_path = PDFToolsService.rotate_pdf(input_path, output_path, rotation)
        
        return PDFOperationResponse(
            success=True,
            message=f"PDF rotated {rotation} degrees successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFRotateError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Add Watermark
@router.post("/add-watermark", response_model=PDFOperationResponse)
async def add_watermark(
    file: UploadFile = File(...),
    watermark_text: str = Form(...),
    position: str = Form("center")
):
    """Add watermark to PDF.
    
    Supported positions:
    - top-left, top-right, center, bottom-left, bottom-right
    - diagonal (45° angle)
    - diagonal-reverse (-45° angle)
    """
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Add watermark
        output_path = FileService.get_output_path(input_path, "_watermarked.pdf")
        result_path = PDFToolsService.add_watermark(input_path, output_path, watermark_text, position)
        
        return PDFOperationResponse(
            success=True,
            message="Watermark added successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFWatermarkError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Add Page Numbers
@router.post("/add-page-numbers", response_model=PDFOperationResponse)
async def add_page_numbers(file: UploadFile = File(...)):
    """Add page numbers to PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Add page numbers
        output_path = FileService.get_output_path(input_path, "_numbered.pdf")
        result_path = PDFToolsService.add_page_numbers(input_path, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="Page numbers added successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFPageNumbersError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Crop PDF
@router.post("/crop", response_model=PDFOperationResponse)
async def crop_pdf(
    file: UploadFile = File(...),
    x: int = Form(0),
    y: int = Form(0),
    width: int = Form(100),
    height: int = Form(100)
):
    """Crop PDF pages."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Crop PDF
        crop_box = {"x": x, "y": y, "width": width, "height": height}
        output_path = FileService.get_output_path(input_path, "_cropped.pdf")
        result_path = PDFToolsService.crop_pdf(input_path, output_path, crop_box)
        
        return PDFOperationResponse(
            success=True,
            message="PDF cropped successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFCropError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Protect PDF
@router.post("/protect", response_model=PDFOperationResponse)
async def protect_pdf(
    file: UploadFile = File(...),
    password: str = Form(...)
):
    """Protect PDF with password."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Protect PDF
        output_path = FileService.get_output_path(input_path, "_protected.pdf")
        result_path = PDFToolsService.protect_pdf(input_path, output_path, password)
        
        return PDFOperationResponse(
            success=True,
            message="PDF protected successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFProtectError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Unlock PDF
@router.post("/unlock", response_model=PDFOperationResponse)
async def unlock_pdf(
    file: UploadFile = File(...),
    password: str = Form(...)
):
    """Remove password protection from PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Unlock PDF
        output_path = FileService.get_output_path(input_path, "_unlocked.pdf")
        result_path = PDFToolsService.unlock_pdf(input_path, output_path, password)
        
        return PDFOperationResponse(
            success=True,
            message="PDF unlocked successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFUnlockError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# PDF to JPG
@router.post("/pdf-to-jpg", response_model=PDFOperationResponse)
async def pdf_to_jpg(file: UploadFile = File(...)):
    """Convert PDF pages to JPG images."""
    input_path = None
    output_files = []
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Convert to JPG
        output_dir = os.path.dirname(FileService.get_output_path(input_path, "_images"))
        result_files = PDFToolsService.pdf_to_jpg(input_path, output_dir)
        output_files = result_files
        
        return PDFOperationResponse(
            success=True,
            message=f"PDF converted to {len(result_files)} JPG images",
            output_filename=f"{len(result_files)}_images.zip",  # Would need zip creation
            download_url=f"/download/jpg_conversion"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFToJPGError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# JPG to PDF
@router.post("/jpg-to-pdf", response_model=PDFOperationResponse)
async def jpg_to_pdf(files: List[UploadFile] = File(...)):
    """Convert JPG images to PDF."""
    input_paths = []
    output_path = None
    
    try:
        # Save uploaded files
        for file in files:
            FileService.validate_file(file)
            input_path = FileService.save_uploaded_file(file)
            input_paths.append(input_path)
        
        # Convert to PDF
        output_path = FileService.get_output_path(input_paths[0], "_converted.pdf")
        result_path = PDFToolsService.jpg_to_pdf(input_paths, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="JPG images converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="JPGToPDFError",
            message=str(e),
            status_code=400
        )
    finally:
        for path in input_paths:
            if path:
                PDFToolsService.cleanup_temp_files(path)


# HTML to PDF
@router.post("/html-to-pdf", response_model=PDFOperationResponse)
async def html_to_pdf(file: UploadFile = File(...)):
    """Convert HTML to PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Convert to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFToolsService.html_to_pdf(input_path, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="HTML converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="HTMLToPDFError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Excel to PDF
@router.post("/excel-to-pdf", response_model=PDFOperationResponse)
async def excel_to_pdf(file: UploadFile = File(...)):
    """Convert Excel to PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Convert to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFToolsService.excel_to_pdf(input_path, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="Excel converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="ExcelToPDFError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# PowerPoint to PDF
@router.post("/powerpoint-to-pdf", response_model=PDFOperationResponse)
async def powerpoint_to_pdf(file: UploadFile = File(...)):
    """Convert PowerPoint to PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Convert to PDF
        output_path = FileService.get_output_path(input_path, "_converted.pdf")
        result_path = PDFToolsService.powerpoint_to_pdf(input_path, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="PowerPoint converted to PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PowerPointToPDFError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# OCR PDF
@router.post("/ocr", response_model=PDFOperationResponse)
async def ocr_pdf(file: UploadFile = File(...)):
    """Extract text from PDF using OCR."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Extract text using OCR
        output_path = FileService.get_output_path(input_path, "_ocr.txt")
        result_path = PDFToolsService.ocr_pdf(input_path, output_path)
        
        # Read extracted text
        with open(result_path, 'r', encoding='utf-8') as f:
            extracted_text = f.read()
        
        return PDFOperationResponse(
            success=True,
            message="Text extracted from PDF successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}",
            extracted_text=extracted_text
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFOCRError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Repair PDF
@router.post("/repair", response_model=PDFOperationResponse)
async def repair_pdf(file: UploadFile = File(...)):
    """Repair corrupted PDF."""
    input_path = None
    output_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Repair PDF
        output_path = FileService.get_output_path(input_path, "_repaired.pdf")
        result_path = PDFToolsService.repair_pdf(input_path, output_path)
        
        return PDFOperationResponse(
            success=True,
            message="PDF repaired successfully",
            output_filename=os.path.basename(result_path),
            download_url=f"/download/{os.path.basename(result_path)}"
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFRepairError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)


# Compare PDFs
@router.post("/compare", response_model=PDFOperationResponse)
async def compare_pdfs(
    file1: UploadFile = File(...),
    file2: UploadFile = File(...)
):
    """Compare two PDFs."""
    input_path1 = None
    input_path2 = None
    output_path = None
    
    try:
        # Save uploaded files
        FileService.validate_file(file1)
        FileService.validate_file(file2)
        input_path1 = FileService.save_uploaded_file(file1)
        input_path2 = FileService.save_uploaded_file(file2)
        
        # Compare PDFs
        output_path = FileService.get_output_path(input_path1, "_comparison.txt")
        comparison_result = PDFToolsService.compare_pdfs(input_path1, input_path2, output_path)
        
        return PDFOperationResponse(
            success=True,
            message=f"PDFs compared successfully. Found {comparison_result['differences_count']} differences",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}",
            differences=comparison_result['differences']
        )
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFCompareError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path1:
            PDFToolsService.cleanup_temp_files(input_path1)
        if input_path2:
            PDFToolsService.cleanup_temp_files(input_path2)


# Get PDF Metadata
@router.post("/metadata")
async def get_pdf_metadata(file: UploadFile = File(...)):
    """Get PDF metadata."""
    input_path = None
    
    try:
        FileService.validate_file(file)
        input_path = FileService.save_uploaded_file(file)
        
        # Get metadata
        metadata = PDFToolsService.get_pdf_metadata(input_path)
        
        return {
            "success": True,
            "message": "PDF metadata extracted successfully",
            "metadata": metadata
        }
        
    except Exception as e:
        raise create_error_response(
            error_type="PDFMetadataError",
            message=str(e),
            status_code=400
        )
    finally:
        if input_path:
            PDFToolsService.cleanup_temp_files(input_path)
