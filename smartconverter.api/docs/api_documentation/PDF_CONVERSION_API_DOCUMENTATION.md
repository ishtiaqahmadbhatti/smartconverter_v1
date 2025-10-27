# PDF Conversion API Documentation

## Overview
The PDF Conversion API provides comprehensive conversion capabilities between PDF and various formats including JSON, Markdown, CSV, Excel, Word, PowerPoint, HTML, images, and more.

## Features
- **AI-Powered Conversions**: Convert PDF to JSON, Markdown, CSV, Excel with intelligent data extraction
- **Format Support**: Support for HTML, Word, PowerPoint, OXPS, images, Markdown, Excel, ODS
- **PDF Processing**: Convert PDF to various formats including images, HTML, text
- **Multi-format Support**: Support for all major document and image formats
- **Advanced Features**: Structured data extraction, table detection, metadata preservation

## Supported Formats

### Input Formats
- **PDF** - Portable Document Format
- **HTML** - HyperText Markup Language
- **DOCX** - Microsoft Word Document
- **PPTX** - Microsoft PowerPoint Presentation
- **OXPS** - Open XML Paper Specification
- **JPG/JPEG** - JPEG Image Format
- **PNG** - Portable Network Graphics
- **MD** - Markdown Format
- **XLSX/XLS** - Microsoft Excel Spreadsheet
- **ODS** - OpenDocument Spreadsheet
- **CSV** - Comma-Separated Values
- **TXT** - Plain Text

### Output Formats
- **PDF** - Portable Document Format
- **JSON** - JavaScript Object Notation
- **MD** - Markdown Format
- **CSV** - Comma-Separated Values
- **XLSX** - Microsoft Excel Spreadsheet
- **XPS** - XML Paper Specification
- **JPG** - JPEG Image Format
- **PNG** - Portable Network Graphics
- **TIFF** - Tagged Image File Format
- **SVG** - Scalable Vector Graphics
- **HTML** - HyperText Markup Language
- **TXT** - Plain Text
- **DOCX** - Microsoft Word Document

## API Endpoints

### Base URL
```
/api/v1/pdfconversiontools
```

## AI-Powered Conversions

### 1. AI: Convert PDF to JSON

**Endpoint:** `POST /pdf-to-json`

Convert PDF to JSON with structured data extraction including text, images, annotations, and metadata.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-json" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to JSON successfully",
  "output_filename": "document_converted.json",
  "download_url": "/download/document_converted.json"
}
```

### 2. AI: Convert PDF to Markdown

**Endpoint:** `POST /pdf-to-markdown`

Convert PDF to Markdown format with preserved structure and formatting.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-markdown" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to Markdown successfully",
  "output_filename": "document_converted.md",
  "download_url": "/download/document_converted.md"
}
```

### 3. AI: Convert PDF to CSV

**Endpoint:** `POST /pdf-to-csv`

Convert PDF to CSV format by extracting tabular data.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-csv" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to CSV successfully",
  "output_filename": "document_converted.csv",
  "download_url": "/download/document_converted.csv"
}
```

### 4. AI: Convert PDF to Excel

**Endpoint:** `POST /pdf-to-excel`

Convert PDF to Excel format with structured data extraction.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-excel" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to Excel successfully",
  "output_filename": "document_converted.xlsx",
  "download_url": "/download/document_converted.xlsx"
}
```

## Document to PDF Conversions

### 5. Convert HTML to PDF

**Endpoint:** `POST /html-to-pdf`

Convert HTML file to PDF format.

**Parameters:**
- `file` (multipart/form-data): HTML file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/html-to-pdf" \
  -F "file=@document.html"
```

**Response:**
```json
{
  "success": true,
  "message": "HTML converted to PDF successfully",
  "output_filename": "document_converted.pdf",
  "download_url": "/download/document_converted.pdf"
}
```

### 6. Convert Word to PDF

**Endpoint:** `POST /word-to-pdf`

Convert Word document to PDF format.

**Parameters:**
- `file` (multipart/form-data): Word document to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/word-to-pdf" \
  -F "file=@document.docx"
```

**Response:**
```json
{
  "success": true,
  "message": "Word document converted to PDF successfully",
  "output_filename": "document_converted.pdf",
  "download_url": "/download/document_converted.pdf"
}
```

### 7. Convert PowerPoint to PDF

**Endpoint:** `POST /powerpoint-to-pdf`

Convert PowerPoint presentation to PDF format.

**Parameters:**
- `file` (multipart/form-data): PowerPoint presentation to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/powerpoint-to-pdf" \
  -F "file=@presentation.pptx"
```

**Response:**
```json
{
  "success": true,
  "message": "PowerPoint converted to PDF successfully",
  "output_filename": "presentation_converted.pdf",
  "download_url": "/download/presentation_converted.pdf"
}
```

### 8. Convert OXPS to PDF

**Endpoint:** `POST /oxps-to-pdf`

Convert OXPS (Open XML Paper Specification) to PDF format.

**Parameters:**
- `file` (multipart/form-data): OXPS file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/oxps-to-pdf" \
  -F "file=@document.oxps"
```

**Response:**
```json
{
  "success": true,
  "message": "OXPS converted to PDF successfully",
  "output_filename": "document_converted.pdf",
  "download_url": "/download/document_converted.pdf"
}
```

### 9. Convert JPG to PDF

**Endpoint:** `POST /jpg-to-pdf`

Convert JPG image to PDF format.

**Parameters:**
- `file` (multipart/form-data): JPG image to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/jpg-to-pdf" \
  -F "file=@image.jpg"
```

**Response:**
```json
{
  "success": true,
  "message": "JPG image converted to PDF successfully",
  "output_filename": "image_converted.pdf",
  "download_url": "/download/image_converted.pdf"
}
```

### 10. Convert PNG to PDF

**Endpoint:** `POST /png-to-pdf`

Convert PNG image to PDF format.

**Parameters:**
- `file` (multipart/form-data): PNG image to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/png-to-pdf" \
  -F "file=@image.png"
```

**Response:**
```json
{
  "success": true,
  "message": "PNG image converted to PDF successfully",
  "output_filename": "image_converted.pdf",
  "download_url": "/download/image_converted.pdf"
}
```

### 11. Convert Markdown to PDF

**Endpoint:** `POST /markdown-to-pdf`

Convert Markdown file to PDF format.

**Parameters:**
- `file` (multipart/form-data): Markdown file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/markdown-to-pdf" \
  -F "file=@document.md"
```

**Response:**
```json
{
  "success": true,
  "message": "Markdown converted to PDF successfully",
  "output_filename": "document_converted.pdf",
  "download_url": "/download/document_converted.pdf"
}
```

### 12. Convert Excel to PDF

**Endpoint:** `POST /excel-to-pdf`

Convert Excel spreadsheet to PDF format.

**Parameters:**
- `file` (multipart/form-data): Excel file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/excel-to-pdf" \
  -F "file=@spreadsheet.xlsx"
```

**Response:**
```json
{
  "success": true,
  "message": "Excel converted to PDF successfully",
  "output_filename": "spreadsheet_converted.pdf",
  "download_url": "/download/spreadsheet_converted.pdf"
}
```

### 13. Convert Excel to XPS

**Endpoint:** `POST /excel-to-xps`

Convert Excel spreadsheet to XPS format.

**Parameters:**
- `file` (multipart/form-data): Excel file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/excel-to-xps" \
  -F "file=@spreadsheet.xlsx"
```

**Response:**
```json
{
  "success": true,
  "message": "Excel converted to XPS successfully",
  "output_filename": "spreadsheet_converted.xps",
  "download_url": "/download/spreadsheet_converted.xps"
}
```

### 14. Convert OpenOffice Calc ODS to PDF

**Endpoint:** `POST /ods-to-pdf`

Convert OpenOffice Calc ODS file to PDF format.

**Parameters:**
- `file` (multipart/form-data): ODS file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/ods-to-pdf" \
  -F "file=@spreadsheet.ods"
```

**Response:**
```json
{
  "success": true,
  "message": "ODS converted to PDF successfully",
  "output_filename": "spreadsheet_converted.pdf",
  "download_url": "/download/spreadsheet_converted.pdf"
}
```

## PDF to Other Format Conversions

### 15. Convert PDF to CSV (Extract)

**Endpoint:** `POST /pdf-to-csv-extract`

Extract tabular data from PDF to CSV format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-csv-extract" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to CSV successfully",
  "output_filename": "document_extracted.csv",
  "download_url": "/download/document_extracted.csv"
}
```

### 16. Convert PDF to Excel (Extract)

**Endpoint:** `POST /pdf-to-excel-extract`

Extract tabular data from PDF to Excel format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-excel-extract" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to Excel successfully",
  "output_filename": "document_extracted.xlsx",
  "download_url": "/download/document_extracted.xlsx"
}
```

### 17. Convert PDF to Word (Extract)

**Endpoint:** `POST /pdf-to-word-extract`

Convert PDF to Word document format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-word-extract" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to Word successfully",
  "output_filename": "document_extracted.docx",
  "download_url": "/download/document_extracted.docx"
}
```

### 18. Convert PDF to JPG

**Endpoint:** `POST /pdf-to-jpg`

Convert PDF pages to JPG images.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-jpg" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to 5 JPG images",
  "output_filename": "5_images.zip",
  "download_url": "/download/jpg_conversion",
  "pages_processed": 5
}
```

### 19. Convert PDF to PNG

**Endpoint:** `POST /pdf-to-png`

Convert PDF pages to PNG images.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-png" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to 5 PNG images",
  "output_filename": "5_images.zip",
  "download_url": "/download/png_conversion",
  "pages_processed": 5
}
```

### 20. Convert PDF to TIFF

**Endpoint:** `POST /pdf-to-tiff`

Convert PDF pages to TIFF images.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-tiff" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to 5 TIFF images",
  "output_filename": "5_images.zip",
  "download_url": "/download/tiff_conversion",
  "pages_processed": 5
}
```

### 21. Convert PDF to SVG

**Endpoint:** `POST /pdf-to-svg`

Convert PDF pages to SVG format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-svg" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to 5 SVG files",
  "output_filename": "5_files.zip",
  "download_url": "/download/svg_conversion",
  "pages_processed": 5
}
```

### 22. Convert PDF to HTML

**Endpoint:** `POST /pdf-to-html`

Convert PDF to HTML format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-html" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to HTML successfully",
  "output_filename": "document_converted.html",
  "download_url": "/download/document_converted.html"
}
```

### 23. Convert PDF to Text

**Endpoint:** `POST /pdf-to-text`

Convert PDF to plain text format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/pdfconversiontools/pdf-to-text" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to text successfully",
  "output_filename": "document_converted.txt",
  "download_url": "/download/document_converted.txt"
}
```

## Utility Endpoints

### 24. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/pdfconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["PDF", "HTML", "DOCX", "PPTX", "OXPS", "JPG", "JPEG", "PNG", "MD", "XLSX", "XLS", "ODS", "CSV", "TXT"],
    "output_formats": ["PDF", "JSON", "MD", "CSV", "XLSX", "XPS", "JPG", "PNG", "TIFF", "SVG", "HTML", "TXT", "DOCX"]
  },
  "message": "Supported formats retrieved successfully"
}
```

### 25. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/pdfconversiontools/download/converted_document.pdf" \
  --output converted_document.pdf
```

## AI-Powered Features

### Structured Data Extraction
- **JSON Conversion**: Extracts text, images, annotations, tables, and metadata
- **Markdown Conversion**: Preserves document structure and formatting
- **Table Detection**: Automatically identifies and extracts tabular data
- **Metadata Preservation**: Maintains document properties and information

### Advanced Processing
- **Multi-page Support**: Handles documents with multiple pages
- **Image Extraction**: Extracts embedded images with base64 encoding
- **Annotation Processing**: Processes PDF annotations and comments
- **Format Preservation**: Maintains original formatting when possible

## Error Responses

All endpoints return standardized error responses:

```json
{
  "error_type": "FileProcessingError",
  "message": "Error description",
  "details": {
    "error": "Detailed error information"
  }
}
```

## Common Error Types

- **FileProcessingError**: General file processing error
- **UnsupportedFileTypeError**: Unsupported file type
- **FileSizeExceededError**: File size exceeds limit
- **InternalServerError**: Internal server error

## Usage Examples

### Python Example
```python
import requests

# Convert PDF to JSON
with open('document.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/pdfconversiontools/pdf-to-json',
        files=files
    )
    print(response.json())

# Convert Word to PDF
with open('document.docx', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/pdfconversiontools/word-to-pdf',
        files=files
    )
    print(response.json())

# Convert PDF to images
with open('document.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/pdfconversiontools/pdf-to-jpg',
        files=files
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert PDF to JSON
const formData = new FormData();
formData.append('file', pdfFileInput.files[0]);

fetch('/api/v1/pdfconversiontools/pdf-to-json', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert Word to PDF
const wordFormData = new FormData();
wordFormData.append('file', wordFileInput.files[0]);

fetch('/api/v1/pdfconversiontools/word-to-pdf', {
    method: 'POST',
    body: wordFormData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert PDF to images
const imageFormData = new FormData();
imageFormData.append('file', pdfFileInput.files[0]);

fetch('/api/v1/pdfconversiontools/pdf-to-jpg', {
    method: 'POST',
    body: imageFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The PDF conversion functionality requires the following Python packages:

```
# PDF processing
pymupdf>=1.23.0
reportlab>=4.0.0
weasyprint>=60.0
cairosvg>=2.7.0
odfpy>=1.4.1

# Document processing
python-docx>=1.2.0
python-pptx>=0.6.21
openpyxl>=3.1.0
markdown>=3.5.0

# Image processing
Pillow>=10.0.0
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Install system dependencies for WeasyPrint:
```bash
# Ubuntu/Debian
sudo apt-get install python3-dev python3-pip python3-cffi python3-brotli libpango-1.0-0 libharfbuzz0b libpangoft2-1.0-0

# macOS
brew install pango

# Windows
# Download GTK+ from https://www.gtk.org/download/windows.php
```

3. Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## PDF Conversion Quality

### Format Support
- **PDF**: Universal document format with full feature support
- **JSON**: Structured data extraction with metadata
- **Markdown**: Clean text format with preserved structure
- **CSV/Excel**: Tabular data extraction and formatting
- **Images**: High-quality image conversion
- **HTML**: Web-ready format with preserved styling

### AI-Powered Features
- **Intelligent Table Detection**: Automatically identifies and extracts tables
- **Metadata Extraction**: Preserves document properties and information
- **Structure Recognition**: Maintains document hierarchy and formatting
- **Multi-format Support**: Handles various input and output formats

## Best Practices

1. **File Size**: Large PDF files may take longer to process
2. **Format Selection**: Choose appropriate output format for your use case
3. **Quality Settings**: Use high-quality settings for professional documents
4. **Processing Time**: Complex conversions may take longer to process
5. **Memory Usage**: Large files may require more memory for processing

## Notes

- All PDF conversions preserve original quality when possible
- AI-powered conversions provide structured data extraction
- Table detection works best with clearly formatted tables
- Image extraction includes base64 encoding for web compatibility
- All temporary files are automatically cleaned up after processing
- PDF files are processed with full format support
- Conversion quality depends on source file quality and format compatibility
