# TechMindsForge PDF Tools - Complete API Documentation

## Overview
This document describes all available PDF manipulation tools in the TechMindsForge FastAPI application. The system provides comprehensive PDF processing capabilities including conversion, manipulation, protection, and analysis.

## Available PDF Tools

### 1. PDF Merge
**Endpoint:** `POST /api/v1/pdf/merge`
**Description:** Merge multiple PDF files into one document.
**Request:** Multipart form with multiple PDF files
**Response:** Merged PDF file

### 2. PDF Split
**Endpoint:** `POST /api/v1/pdf/split`
**Description:** Split a PDF into multiple files.
**Parameters:**
- `file`: PDF file to split
- `split_type`: "every_page" or "page_range"
- `page_ranges`: Comma-separated page ranges (e.g., "1-5,6-10")

### 3. PDF Compress
**Endpoint:** `POST /api/v1/pdf/compress`
**Description:** Compress PDF file to reduce size.
**Parameters:**
- `file`: PDF file to compress
- `compression_level`: "low", "medium", "high", or "maximum"

### 4. Remove Pages
**Endpoint:** `POST /api/v1/pdf/remove-pages`
**Description:** Remove specific pages from PDF.
**Parameters:**
- `file`: PDF file
- `pages_to_remove`: Comma-separated page numbers to remove

### 5. Extract Pages
**Endpoint:** `POST /api/v1/pdf/extract-pages`
**Description:** Extract specific pages from PDF.
**Parameters:**
- `file`: PDF file
- `pages_to_extract`: Comma-separated page numbers to extract

### 6. Rotate PDF
**Endpoint:** `POST /api/v1/pdf/rotate`
**Description:** Rotate PDF pages.
**Parameters:**
- `file`: PDF file
- `rotation`: Rotation angle (0, 90, 180, 270)

### 7. Add Watermark
**Endpoint:** `POST /api/v1/pdf/add-watermark`
**Description:** Add watermark to PDF.
**Parameters:**
- `file`: PDF file
- `watermark_text`: Text to use as watermark
- `position`: "top-left", "top-right", "center", "bottom-left", "bottom-right"

### 8. Add Page Numbers
**Endpoint:** `POST /api/v1/pdf/add-page-numbers`
**Description:** Add page numbers to PDF.
**Parameters:**
- `file`: PDF file

### 9. Crop PDF
**Endpoint:** `POST /api/v1/pdf/crop`
**Description:** Crop PDF pages.
**Parameters:**
- `file`: PDF file
- `x`, `y`, `width`, `height`: Crop box coordinates

### 10. Protect PDF
**Endpoint:** `POST /api/v1/pdf/protect`
**Description:** Add password protection to PDF.
**Parameters:**
- `file`: PDF file
- `user_password`: Password for users
- `owner_password`: Password for owner
- `permissions`: Comma-separated permissions ("print,copy,modify,annotate")

### 11. Unlock PDF
**Endpoint:** `POST /api/v1/pdf/unlock`
**Description:** Remove password protection from PDF.
**Parameters:**
- `file`: PDF file
- `password`: Current password

### 12. PDF to JPG
**Endpoint:** `POST /api/v1/pdf/pdf-to-jpg`
**Description:** Convert PDF pages to JPG images.
**Parameters:**
- `file`: PDF file

### 13. JPG to PDF
**Endpoint:** `POST /api/v1/pdf/jpg-to-pdf`
**Description:** Convert JPG images to PDF.
**Parameters:**
- `files`: Multiple JPG files

### 14. HTML to PDF
**Endpoint:** `POST /api/v1/pdf/html-to-pdf`
**Description:** Convert HTML file to PDF.
**Parameters:**
- `file`: HTML file

### 15. Excel to PDF
**Endpoint:** `POST /api/v1/pdf/excel-to-pdf`
**Description:** Convert Excel file to PDF.
**Parameters:**
- `file`: Excel file (.xlsx)

### 16. PowerPoint to PDF
**Endpoint:** `POST /api/v1/pdf/powerpoint-to-pdf`
**Description:** Convert PowerPoint file to PDF.
**Parameters:**
- `file`: PowerPoint file (.pptx)

### 17. OCR PDF
**Endpoint:** `POST /api/v1/pdf/ocr`
**Description:** Extract text from PDF using OCR.
**Parameters:**
- `file`: PDF file

### 18. Repair PDF
**Endpoint:** `POST /api/v1/pdf/repair`
**Description:** Repair corrupted PDF files.
**Parameters:**
- `file`: PDF file

### 19. Compare PDFs
**Endpoint:** `POST /api/v1/pdf/compare`
**Description:** Compare two PDF files and generate difference report.
**Parameters:**
- `file1`: First PDF file
- `file2`: Second PDF file

### 20. Get PDF Metadata
**Endpoint:** `POST /api/v1/pdf/metadata`
**Description:** Extract metadata from PDF file.
**Parameters:**
- `file`: PDF file

## Response Format

All endpoints return a standardized response:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "output_filename": "result.pdf",
  "download_url": "/download/result.pdf",
  "page_count": 10,
  "file_size_before": 1024000,
  "file_size_after": 512000,
  "compression_ratio": 50.0,
  "differences": [],
  "metadata": {}
}
```

## File Upload Limits

- **Maximum file size:** 50MB
- **Supported formats:** PDF, DOCX, PPTX, XLSX, HTML, PNG, JPG, JPEG, GIF, BMP, TIFF, WEBP

## Authentication

All PDF tools require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## Error Handling

The API returns appropriate HTTP status codes:

- `200 OK`: Operation successful
- `400 Bad Request`: Invalid input or file format
- `401 Unauthorized`: Missing or invalid authentication
- `413 Payload Too Large`: File size exceeds limit
- `500 Internal Server Error`: Server-side error

## Usage Examples

### Merge PDFs
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/pdf/merge" \
  -H "Authorization: Bearer <token>" \
  -F "files=@document1.pdf" \
  -F "files=@document2.pdf"
```

### Compress PDF
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/pdf/compress" \
  -H "Authorization: Bearer <token>" \
  -F "file=@large_document.pdf" \
  -F "compression_level=high"
```

### Protect PDF
```bash
curl -X POST "http://127.0.0.1:8000/api/v1/pdf/protect" \
  -H "Authorization: Bearer <token>" \
  -F "file=@document.pdf" \
  -F "user_password=user123" \
  -F "owner_password=owner123" \
  -F "permissions=print,copy"
```

## API Documentation

- **Swagger UI:** http://127.0.0.1:8000/docs
- **ReDoc:** http://127.0.0.1:8000/redoc

## Dependencies

The PDF tools use the following libraries:
- PyPDF2: Basic PDF operations
- PIL (Pillow): Image processing
- ReportLab: PDF generation
- img2pdf: Image to PDF conversion
- pytesseract: OCR functionality

## Production Considerations

1. **File Storage:** Configure proper file storage for production
2. **Rate Limiting:** Implement rate limiting for API endpoints
3. **Security:** Use HTTPS and proper authentication
4. **Monitoring:** Set up logging and monitoring
5. **Backup:** Implement file backup and recovery
6. **Scaling:** Consider horizontal scaling for high loads

## Troubleshooting

### Common Issues

1. **Import Errors:** Ensure all dependencies are installed
2. **File Size Limits:** Check file size against configured limits
3. **Memory Issues:** Large files may require more memory
4. **OCR Issues:** Ensure Tesseract is properly installed for OCR

### Support

For issues or questions:
1. Check the API documentation
2. Review error messages in responses
3. Check server logs for detailed error information
4. Ensure all required dependencies are installed
