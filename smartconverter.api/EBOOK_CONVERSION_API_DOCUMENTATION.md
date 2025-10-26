# eBook Conversion API Documentation

## Overview
The eBook Conversion API provides comprehensive conversion capabilities between various eBook formats including ePUB, MOBI, AZW, PDF, FB2, and Markdown.

## Features
- **Format Conversion**: Convert between ePUB, MOBI, AZW, AZW3, PDF, FB2, FBZ formats
- **Markdown Support**: Convert Markdown files to ePUB format
- **PDF Integration**: Convert PDFs to and from various eBook formats
- **Metadata Preservation**: Maintain book metadata during conversion
- **Quality Conversion**: High-quality format conversion with content preservation

## Supported Formats

### Input Formats
- **ePUB** - Electronic Publication format
- **MOBI** - Mobipocket eBook format
- **AZW** - Amazon Kindle format
- **AZW3** - Amazon Kindle format (newer)
- **PDF** - Portable Document Format
- **FB2** - FictionBook format
- **FBZ** - FictionBook ZIP format
- **MD/MARKDOWN** - Markdown format

### Output Formats
- **ePUB** - Electronic Publication format
- **MOBI** - Mobipocket eBook format
- **AZW** - Amazon Kindle format
- **AZW3** - Amazon Kindle format (newer)
- **PDF** - Portable Document Format
- **FB2** - FictionBook format
- **FBZ** - FictionBook ZIP format

## API Endpoints

### Base URL
```
/api/v1/ebookconversiontools
```

## 1. Convert Markdown to ePUB

**Endpoint:** `POST /markdown-to-epub`

Convert Markdown file to ePUB format.

**Parameters:**
- `file` (multipart/form-data): Markdown file to convert
- `title` (form data, optional): Book title (default: "Converted Book")
- `author` (form data, optional): Book author (default: "Unknown")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/markdown-to-epub" \
  -F "file=@book.md" \
  -F "title=My Book" \
  -F "author=John Doe"
```

**Response:**
```json
{
  "success": true,
  "message": "Markdown file converted to ePUB successfully",
  "output_filename": "book.epub",
  "download_url": "/download/book.epub"
}
```

## 2. Convert ePUB to MOBI

**Endpoint:** `POST /epub-to-mobi`

Convert ePUB file to MOBI format.

**Parameters:**
- `file` (multipart/form-data): ePUB file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/epub-to-mobi" \
  -F "file=@book.epub"
```

**Response:**
```json
{
  "success": true,
  "message": "ePUB file converted to MOBI successfully",
  "output_filename": "book.mobi",
  "download_url": "/download/book.mobi"
}
```

## 3. Convert ePUB to AZW

**Endpoint:** `POST /epub-to-azw`

Convert ePUB file to AZW format.

**Parameters:**
- `file` (multipart/form-data): ePUB file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/epub-to-azw" \
  -F "file=@book.epub"
```

**Response:**
```json
{
  "success": true,
  "message": "ePUB file converted to AZW successfully",
  "output_filename": "book.azw",
  "download_url": "/download/book.azw"
}
```

## 4. Convert MOBI to ePUB

**Endpoint:** `POST /mobi-to-epub`

Convert MOBI file to ePUB format.

**Parameters:**
- `file` (multipart/form-data): MOBI file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/mobi-to-epub" \
  -F "file=@book.mobi"
```

**Response:**
```json
{
  "success": true,
  "message": "MOBI file converted to ePUB successfully",
  "output_filename": "book.epub",
  "download_url": "/download/book.epub"
}
```

## 5. Convert MOBI to AZW

**Endpoint:** `POST /mobi-to-azw`

Convert MOBI file to AZW format.

**Parameters:**
- `file` (multipart/form-data): MOBI file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/mobi-to-azw" \
  -F "file=@book.mobi"
```

**Response:**
```json
{
  "success": true,
  "message": "MOBI file converted to AZW successfully",
  "output_filename": "book.azw",
  "download_url": "/download/book.azw"
}
```

## 6. Convert AZW to ePUB

**Endpoint:** `POST /azw-to-epub`

Convert AZW file to ePUB format.

**Parameters:**
- `file` (multipart/form-data): AZW file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/azw-to-epub" \
  -F "file=@book.azw"
```

**Response:**
```json
{
  "success": true,
  "message": "AZW file converted to ePUB successfully",
  "output_filename": "book.epub",
  "download_url": "/download/book.epub"
}
```

## 7. Convert AZW to MOBI

**Endpoint:** `POST /azw-to-mobi`

Convert AZW file to MOBI format.

**Parameters:**
- `file` (multipart/form-data): AZW file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/azw-to-mobi" \
  -F "file=@book.azw"
```

**Response:**
```json
{
  "success": true,
  "message": "AZW file converted to MOBI successfully",
  "output_filename": "book.mobi",
  "download_url": "/download/book.mobi"
}
```

## 8. Convert ePUB to PDF

**Endpoint:** `POST /epub-to-pdf`

Convert ePUB file to PDF format.

**Parameters:**
- `file` (multipart/form-data): ePUB file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/epub-to-pdf" \
  -F "file=@book.epub"
```

**Response:**
```json
{
  "success": true,
  "message": "ePUB file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 9. Convert MOBI to PDF

**Endpoint:** `POST /mobi-to-pdf`

Convert MOBI file to PDF format.

**Parameters:**
- `file` (multipart/form-data): MOBI file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/mobi-to-pdf" \
  -F "file=@book.mobi"
```

**Response:**
```json
{
  "success": true,
  "message": "MOBI file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 10. Convert AZW to PDF

**Endpoint:** `POST /azw-to-pdf`

Convert AZW file to PDF format.

**Parameters:**
- `file` (multipart/form-data): AZW file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/azw-to-pdf" \
  -F "file=@book.azw"
```

**Response:**
```json
{
  "success": true,
  "message": "AZW file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 11. Convert AZW3 to PDF

**Endpoint:** `POST /azw3-to-pdf`

Convert AZW3 file to PDF format.

**Parameters:**
- `file` (multipart/form-data): AZW3 file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/azw3-to-pdf" \
  -F "file=@book.azw3"
```

**Response:**
```json
{
  "success": true,
  "message": "AZW3 file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 12. Convert FB2 to PDF

**Endpoint:** `POST /fb2-to-pdf`

Convert FB2 file to PDF format.

**Parameters:**
- `file` (multipart/form-data): FB2 file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/fb2-to-pdf" \
  -F "file=@book.fb2"
```

**Response:**
```json
{
  "success": true,
  "message": "FB2 file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 13. Convert FBZ to PDF

**Endpoint:** `POST /fbz-to-pdf`

Convert FBZ file to PDF format.

**Parameters:**
- `file` (multipart/form-data): FBZ file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/fbz-to-pdf" \
  -F "file=@book.fbz"
```

**Response:**
```json
{
  "success": true,
  "message": "FBZ file converted to PDF successfully",
  "output_filename": "book.pdf",
  "download_url": "/download/book.pdf"
}
```

## 14. Convert PDF to ePUB

**Endpoint:** `POST /pdf-to-epub`

Convert PDF file to ePUB format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-epub" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to ePUB successfully",
  "output_filename": "book.epub",
  "download_url": "/download/book.epub"
}
```

## 15. Convert PDF to MOBI

**Endpoint:** `POST /pdf-to-mobi`

Convert PDF file to MOBI format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-mobi" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to MOBI successfully",
  "output_filename": "book.mobi",
  "download_url": "/download/book.mobi"
}
```

## 16. Convert PDF to AZW

**Endpoint:** `POST /pdf-to-azw`

Convert PDF file to AZW format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-azw" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to AZW successfully",
  "output_filename": "book.azw",
  "download_url": "/download/book.azw"
}
```

## 17. Convert PDF to AZW3

**Endpoint:** `POST /pdf-to-azw3`

Convert PDF file to AZW3 format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-azw3" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to AZW3 successfully",
  "output_filename": "book.azw3",
  "download_url": "/download/book.azw3"
}
```

## 18. Convert PDF to FB2

**Endpoint:** `POST /pdf-to-fb2`

Convert PDF file to FB2 format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-fb2" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to FB2 successfully",
  "output_filename": "book.fb2",
  "download_url": "/download/book.fb2"
}
```

## 19. Convert PDF to FBZ

**Endpoint:** `POST /pdf-to-fbz`

Convert PDF file to FBZ format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ebookconversiontools/pdf-to-fbz" \
  -F "file=@book.pdf"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF file converted to FBZ successfully",
  "output_filename": "book.fbz",
  "download_url": "/download/book.fbz"
}
```

## 20. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/ebookconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["EPUB", "MOBI", "AZW", "AZW3", "PDF", "FB2", "FBZ", "MD", "MARKDOWN"],
    "output_formats": ["EPUB", "MOBI", "AZW", "AZW3", "PDF", "FB2", "FBZ"]
  },
  "message": "Supported formats retrieved successfully"
}
```

## 21. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted eBook file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/ebookconversiontools/download/converted_book.epub" \
  --output converted_book.epub
```

## eBook Format Features

### ePUB Format
- **Open Standard**: Industry-standard eBook format
- **Reflowable Text**: Adapts to different screen sizes
- **Rich Content**: Supports images, tables, and formatting
- **Accessibility**: Screen reader compatible
- **Cross-Platform**: Works on most e-readers

### MOBI Format
- **Kindle Compatible**: Native Amazon Kindle format
- **DRM Support**: Digital Rights Management support
- **Reflowable**: Text adapts to screen size
- **Rich Formatting**: Supports images and formatting
- **Wide Support**: Compatible with many e-readers

### AZW/AZW3 Format
- **Amazon Kindle**: Native Kindle format
- **Enhanced Features**: Advanced formatting support
- **DRM Protected**: Digital Rights Management
- **High Quality**: Optimized for Kindle devices
- **Rich Content**: Supports multimedia content

### PDF Format
- **Universal Compatibility**: Works on all devices
- **Fixed Layout**: Preserves exact formatting
- **High Quality**: Vector graphics support
- **Print Ready**: Optimized for printing
- **Rich Content**: Supports complex layouts

### FB2/FBZ Format
- **Open Standard**: FictionBook format
- **XML Based**: Structured markup language
- **Rich Metadata**: Comprehensive book information
- **Reflowable**: Text adapts to screen size
- **Cross-Platform**: Works on many e-readers

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

# Convert Markdown to ePUB
with open('book.md', 'rb') as f:
    files = {'file': f}
    data = {'title': 'My Book', 'author': 'John Doe'}
    response = requests.post(
        'http://localhost:8000/api/v1/ebookconversiontools/markdown-to-epub',
        files=files, data=data
    )
    print(response.json())

# Convert ePUB to MOBI
with open('book.epub', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/ebookconversiontools/epub-to-mobi',
        files=files
    )
    print(response.json())

# Convert PDF to ePUB
with open('book.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/ebookconversiontools/pdf-to-epub',
        files=files
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert Markdown to ePUB
const formData = new FormData();
formData.append('file', markdownFileInput.files[0]);
formData.append('title', 'My Book');
formData.append('author', 'John Doe');

fetch('/api/v1/ebookconversiontools/markdown-to-epub', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert ePUB to MOBI
const epubFormData = new FormData();
epubFormData.append('file', epubFileInput.files[0]);

fetch('/api/v1/ebookconversiontools/epub-to-mobi', {
    method: 'POST',
    body: epubFormData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert PDF to ePUB
const pdfFormData = new FormData();
pdfFormData.append('file', pdfFileInput.files[0]);

fetch('/api/v1/ebookconversiontools/pdf-to-epub', {
    method: 'POST',
    body: pdfFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The eBook conversion functionality requires the following Python packages:

```
ebooklib>=0.18
markdown>=3.5.0
kindle-unpack>=0.3.0
calibre>=6.0.0
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

## eBook Conversion Quality

### Markdown to ePUB
- **High Quality**: Excellent conversion from Markdown
- **Metadata Support**: Book title and author information
- **Rich Content**: Supports images, tables, and formatting
- **Structure**: Maintains document structure
- **Compatibility**: Works on all ePUB readers

### ePUB Conversions
- **Format Preservation**: Maintains formatting and structure
- **Metadata**: Preserves book metadata
- **Content Quality**: High-quality content conversion
- **Compatibility**: Works with target format specifications
- **Error Handling**: Comprehensive error management

### PDF Conversions
- **Text Extraction**: High-quality text extraction
- **Format Preservation**: Maintains document structure
- **Image Support**: Preserves images and graphics
- **Metadata**: Extracts and preserves book information
- **Quality**: Optimized for target format

## Best Practices

1. **File Quality**: Use high-quality source files for best results
2. **File Size**: Large files may take longer to process
3. **Format Support**: Check supported formats before processing
4. **Metadata**: Provide accurate book metadata for better results
5. **Testing**: Test converted files on target devices

## Notes

- All eBook conversions preserve content and formatting
- Metadata is maintained during conversion when possible
- Large files may take longer to process
- All temporary files are automatically cleaned up after processing
- eBook files are processed with full UTF-8 support
- Conversion quality depends on source file quality and format compatibility
