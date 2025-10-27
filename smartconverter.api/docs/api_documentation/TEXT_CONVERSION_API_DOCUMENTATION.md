# Text Conversion API Documentation

## Overview
The Text Conversion API provides comprehensive text extraction capabilities from various document formats including Word, PowerPoint, PDF, and subtitle files.

## Features
- **Document Text Extraction**: Extract text from Word, PowerPoint, and PDF documents
- **Subtitle Text Extraction**: Extract text from SRT and VTT subtitle files
- **Format Preservation**: Maintain document structure and formatting
- **Multi-format Support**: Support for various document and subtitle formats
- **Clean Text Output**: Clean, readable text extraction

## Supported Formats

### Input Formats
- **DOCX/DOC** - Microsoft Word Documents
- **PPTX/PPT** - Microsoft PowerPoint Presentations
- **PDF** - Portable Document Format
- **SRT** - SubRip Subtitle Format
- **VTT** - WebVTT Subtitle Format
- **TXT** - Plain Text Format

### Output Format
- **TXT** - Plain Text Format

## API Endpoints

### Base URL
```
/api/v1/textconversiontools
```

## 1. Convert Word to Text

**Endpoint:** `POST /word-to-text`

Extract text from Word document.

**Parameters:**
- `file` (multipart/form-data): Word document file (DOCX/DOC)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/textconversiontools/word-to-text" \
  -F "file=@document.docx"
```

**Response:**
```json
{
  "success": true,
  "message": "Word document converted to text successfully",
  "output_filename": "document.txt",
  "download_url": "/download/document.txt"
}
```

## 2. Convert PowerPoint to Text

**Endpoint:** `POST /powerpoint-to-text`

Extract text from PowerPoint presentation.

**Parameters:**
- `file` (multipart/form-data): PowerPoint presentation file (PPTX/PPT)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/textconversiontools/powerpoint-to-text" \
  -F "file=@presentation.pptx"
```

**Response:**
```json
{
  "success": true,
  "message": "PowerPoint presentation converted to text successfully",
  "output_filename": "presentation.txt",
  "download_url": "/download/presentation.txt"
}
```

## 3. Convert PDF to Text

**Endpoint:** `POST /pdf-to-text`

Extract text from PDF document.

**Parameters:**
- `file` (multipart/form-data): PDF document file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/textconversiontools/pdf-to-text" \
  -F "file=@document.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF document converted to text successfully",
  "output_filename": "document.txt",
  "download_url": "/download/document.txt"
}
```

## 4. Convert SRT to Text

**Endpoint:** `POST /srt-to-text`

Extract text from SRT subtitle file.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/textconversiontools/srt-to-text" \
  -F "file=@subtitles.srt"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT subtitle file converted to text successfully",
  "output_filename": "subtitles.txt",
  "download_url": "/download/subtitles.txt"
}
```

## 5. Convert VTT to Text

**Endpoint:** `POST /vtt-to-text`

Extract text from VTT subtitle file.

**Parameters:**
- `file` (multipart/form-data): VTT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/textconversiontools/vtt-to-text" \
  -F "file=@subtitles.vtt"
```

**Response:**
```json
{
  "success": true,
  "message": "VTT subtitle file converted to text successfully",
  "output_filename": "subtitles.txt",
  "download_url": "/download/subtitles.txt"
}
```

## 6. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/textconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": ["DOCX", "DOC", "PPTX", "PPT", "PDF", "SRT", "VTT", "TXT"],
  "message": "Supported formats retrieved successfully"
}
```

## 7. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted text file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/textconversiontools/download/converted_file.txt" \
  --output converted_file.txt
```

## Text Extraction Features

### Word Document Processing
- **Paragraph Text**: Extracts text from all paragraphs
- **Table Content**: Extracts text from tables with proper formatting
- **Structure Preservation**: Maintains document structure
- **Clean Output**: Removes formatting while preserving content

### PowerPoint Processing
- **Slide-by-Slide**: Processes each slide individually
- **Shape Text**: Extracts text from all shapes and text boxes
- **Table Content**: Extracts text from tables within slides
- **Slide Organization**: Organizes text by slide number

### PDF Processing
- **Page-by-Page**: Processes each page individually
- **Text Extraction**: Extracts all readable text content
- **Page Organization**: Organizes text by page number
- **Clean Formatting**: Removes PDF-specific formatting

### Subtitle Processing
- **SRT Files**: Extracts subtitle text without timing information
- **VTT Files**: Extracts caption text without timing information
- **Clean Text**: Provides clean, readable text output
- **Sequential Order**: Maintains subtitle order

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

# Convert Word to text
with open('document.docx', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/textconversiontools/word-to-text',
        files=files
    )
    print(response.json())

# Convert PowerPoint to text
with open('presentation.pptx', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/textconversiontools/powerpoint-to-text',
        files=files
    )
    print(response.json())

# Convert PDF to text
with open('document.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/textconversiontools/pdf-to-text',
        files=files
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert Word to text
const formData = new FormData();
formData.append('file', wordFileInput.files[0]);

fetch('/api/v1/textconversiontools/word-to-text', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert PowerPoint to text
const pptFormData = new FormData();
pptFormData.append('file', pptFileInput.files[0]);

fetch('/api/v1/textconversiontools/powerpoint-to-text', {
    method: 'POST',
    body: pptFormData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert PDF to text
const pdfFormData = new FormData();
pdfFormData.append('file', pdfFileInput.files[0]);

fetch('/api/v1/textconversiontools/pdf-to-text', {
    method: 'POST',
    body: pdfFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The text conversion functionality requires the following Python packages:

```
python-docx>=1.2.0
python-pptx>=0.6.21
pymupdf>=1.23.0
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## Text Extraction Quality

### Word Documents
- **High Quality**: Excellent text extraction from modern Word documents
- **Table Support**: Proper table text extraction
- **Formatting**: Preserves paragraph structure
- **Encoding**: Full UTF-8 support for international characters

### PowerPoint Presentations
- **Slide Organization**: Clear slide-by-slide text extraction
- **Content Types**: Extracts text from shapes, text boxes, and tables
- **Structure**: Maintains presentation structure
- **Clean Output**: Removes presentation-specific formatting

### PDF Documents
- **Text Quality**: High-quality text extraction from text-based PDFs
- **Page Organization**: Clear page-by-page organization
- **Encoding**: Full UTF-8 support
- **Limitations**: May not extract text from image-based PDFs (use OCR tools)

### Subtitle Files
- **Clean Text**: Extracts only the subtitle text content
- **Order Preservation**: Maintains subtitle sequence
- **Format Cleanup**: Removes timing and formatting information
- **Encoding**: Full UTF-8 support for international subtitles

## Best Practices

1. **File Quality**: Use high-quality source documents for best results
2. **File Size**: Large files may take longer to process
3. **Encoding**: Ensure proper UTF-8 encoding for international text
4. **Format Support**: Check supported formats before processing
5. **Text Quality**: Review extracted text for accuracy

## Notes

- Text extraction quality depends on source document quality
- Image-based PDFs may require OCR tools for text extraction
- Large files may take longer to process
- All temporary files are automatically cleaned up after processing
- Text output is always in UTF-8 encoding
- Subtitle text extraction removes timing information for clean text output
