# Image Conversion API Documentation

## Overview
The Image Conversion API provides comprehensive image processing and conversion capabilities supporting multiple formats and conversion types.

## Supported Formats

### Input Formats
- **AVIF** - AV1 Image File Format
- **WebP** - WebP Image Format
- **PNG** - Portable Network Graphics
- **JPG/JPEG** - JPEG Image Format
- **TIFF** - Tagged Image File Format
- **SVG** - Scalable Vector Graphics
- **HEIC** - High Efficiency Image Container
- **PGM** - Portable Graymap
- **PPM** - Portable Pixmap
- **GIF** - Graphics Interchange Format
- **BMP** - Bitmap Image Format
- **YUV** - YUV Color Space Format
- **PAM** - Portable Arbitrary Map
- **AI** - Adobe Illustrator Format
- **PDF** - Portable Document Format

### Output Formats
- **AVIF** - AV1 Image File Format
- **WebP** - WebP Image Format
- **PNG** - Portable Network Graphics
- **JPG/JPEG** - JPEG Image Format
- **TIFF** - Tagged Image File Format
- **SVG** - Scalable Vector Graphics
- **HEIC** - High Efficiency Image Container
- **PGM** - Portable Graymap
- **PPM** - Portable Pixmap
- **GIF** - Graphics Interchange Format
- **BMP** - Bitmap Image Format
- **YUV** - YUV Color Space Format
- **PAM** - Portable Arbitrary Map

## API Endpoints

### Base URL
```
/api/v1/imageconversiontools
```

## 1. Convert Image Format

**Endpoint:** `POST /convert-format`

Convert an image from one format to another.

**Parameters:**
- `file` (multipart/form-data): Image file to convert
- `output_format` (form data): Target format (AVIF, WebP, PNG, JPG, JPEG, TIFF, SVG, HEIC, PGM, PPM)
- `quality` (form data, optional): Quality for lossy formats (1-100, default: 95)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/convert-format" \
  -F "file=@image.png" \
  -F "output_format=JPEG" \
  -F "quality=90"
```

**Response:**
```json
{
  "success": true,
  "message": "Image converted to JPEG successfully",
  "output_filename": "image_converted.jpg",
  "download_url": "/download/image_converted.jpg"
}
```

## 2. Convert Image to JSON

**Endpoint:** `POST /image-to-json`

Convert an image to JSON format with metadata and base64 encoding.

**Parameters:**
- `file` (multipart/form-data): Image file to convert
- `include_metadata` (form data, optional): Include image metadata (default: true)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/image-to-json" \
  -F "file=@image.png" \
  -F "include_metadata=true"
```

**Response:**
```json
{
  "success": true,
  "message": "Image converted to JSON successfully",
  "output_filename": "image.json",
  "download_url": "/download/image.json"
}
```

**JSON Structure:**
```json
{
  "image_data": {
    "base64": "iVBORw0KGgoAAAANSUhEUgAA...",
    "format": "PNG",
    "mime_type": "image/png"
  },
  "metadata": {
    "filename": "image.png",
    "format": "PNG",
    "mode": "RGB",
    "size": [800, 600],
    "width": 800,
    "height": 600,
    "has_transparency": false
  },
  "conversion_info": {
    "converted_at": "2024-01-01T12:00:00",
    "original_size": 12345,
    "base64_size": 16460
  }
}
```

## 3. Convert Image to PDF

**Endpoint:** `POST /image-to-pdf`

Convert an image to PDF format.

**Parameters:**
- `file` (multipart/form-data): Image file to convert
- `page_size` (form data, optional): PDF page size (default: A4)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/image-to-pdf" \
  -F "file=@image.png" \
  -F "page_size=A4"
```

**Response:**
```json
{
  "success": true,
  "message": "Image converted to PDF successfully",
  "output_filename": "image.pdf",
  "download_url": "/download/image.pdf"
}
```

## 4. Convert Website to Image

**Endpoint:** `POST /website-to-image`

Convert a website to an image using headless browser.

**Parameters:**
- `url` (form data): Website URL to convert
- `output_format` (form data, optional): Output format (default: PNG)
- `width` (form data, optional): Image width (default: 1920)
- `height` (form data, optional): Image height (default: 1080)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/website-to-image" \
  -F "url=https://www.google.com" \
  -F "output_format=PNG" \
  -F "width=1920" \
  -F "height=1080"
```

**Response:**
```json
{
  "success": true,
  "message": "Website converted to PNG successfully",
  "output_filename": "website_https___www_google_com.png",
  "download_url": "/download/website_https___www_google_com.png"
}
```

## 5. Convert HTML to Image

**Endpoint:** `POST /html-to-image`

Convert HTML content to an image.

**Parameters:**
- `html_content` (form data): HTML content to convert
- `output_format` (form data, optional): Output format (default: PNG)
- `width` (form data, optional): Image width (default: 1920)
- `height` (form data, optional): Image height (default: 1080)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/html-to-image" \
  -F "html_content=<html><body><h1>Hello World</h1></body></html>" \
  -F "output_format=PNG" \
  -F "width=800" \
  -F "height=600"
```

**Response:**
```json
{
  "success": true,
  "message": "HTML converted to PNG successfully",
  "output_filename": "html_content.png",
  "download_url": "/download/html_content.png"
}
```

## 6. Convert PDF to Image

**Endpoint:** `POST /pdf-to-image`

Convert a PDF page to an image.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert
- `output_format` (form data, optional): Output format (default: PNG)
- `dpi` (form data, optional): Image DPI (default: 300)
- `page_number` (form data, optional): Page number to convert (default: 1)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/pdf-to-image" \
  -F "file=@document.pdf" \
  -F "output_format=PNG" \
  -F "dpi=300" \
  -F "page_number=1"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF page 1 converted to PNG successfully",
  "output_filename": "document_page_1.png",
  "download_url": "/download/document_page_1.png"
}
```

## 7. Convert PDF to TIFF

**Endpoint:** `POST /pdf-to-tiff`

Convert a PDF page to TIFF format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert
- `dpi` (form data, optional): Image DPI (default: 300)
- `page_number` (form data, optional): Page number to convert (default: 1)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/pdf-to-tiff" \
  -F "file=@document.pdf" \
  -F "dpi=300" \
  -F "page_number=1"
```

## 8. Convert PDF to SVG

**Endpoint:** `POST /pdf-to-svg`

Convert a PDF page to SVG format.

**Parameters:**
- `file` (multipart/form-data): PDF file to convert
- `dpi` (form data, optional): Image DPI (default: 300)
- `page_number` (form data, optional): Page number to convert (default: 1)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/pdf-to-svg" \
  -F "file=@document.pdf" \
  -F "dpi=300" \
  -F "page_number=1"
```

## 9. Convert AI to SVG

**Endpoint:** `POST /ai-to-svg`

Convert Adobe Illustrator (AI) file to SVG format.

**Parameters:**
- `file` (multipart/form-data): AI file to convert

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/ai-to-svg" \
  -F "file=@design.ai"
```

## 10. Remove EXIF Data

**Endpoint:** `POST /remove-exif`

Remove EXIF metadata from an image.

**Parameters:**
- `file` (multipart/form-data): Image file to process

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/imageconversiontools/remove-exif" \
  -F "file=@image.jpg"
```

**Response:**
```json
{
  "success": true,
  "message": "EXIF data removed successfully",
  "output_filename": "image_no_exif.jpg",
  "download_url": "/download/image_no_exif.jpg"
}
```

## 11. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/imageconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["AVIF", "WEBP", "PNG", "JPG", "JPEG", "TIFF", "SVG", "HEIC", "PGM", "PPM"],
    "output_formats": ["AVIF", "WEBP", "PNG", "JPG", "JPEG", "TIFF", "SVG", "HEIC", "PGM", "PPM"]
  },
  "message": "Supported formats retrieved successfully"
}
```

## 12. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/imageconversiontools/download/converted_image.jpg" \
  --output converted_image.jpg
```

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

# Convert image format
with open('image.png', 'rb') as f:
    files = {'file': f}
    data = {'output_format': 'JPEG', 'quality': 95}
    response = requests.post(
        'http://localhost:8000/api/v1/imageconversiontools/convert-format',
        files=files, data=data
    )
    print(response.json())

# Convert website to image
data = {
    'url': 'https://www.example.com',
    'output_format': 'PNG',
    'width': 1920,
    'height': 1080
}
response = requests.post(
    'http://localhost:8000/api/v1/imageconversiontools/website-to-image',
    data=data
)
print(response.json())
```

### JavaScript Example
```javascript
// Convert image format
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('output_format', 'JPEG');
formData.append('quality', '95');

fetch('/api/v1/imageconversiontools/convert-format', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert website to image
const data = {
    url: 'https://www.example.com',
    output_format: 'PNG',
    width: 1920,
    height: 1080
};

fetch('/api/v1/imageconversiontools/website-to-image', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams(data)
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The image conversion functionality requires the following Python packages:

```
opencv-python>=4.8.0
pillow-heif>=0.13.0
cairosvg>=2.7.0
wand>=0.6.11
selenium>=4.15.0
webdriver-manager>=4.0.0
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. For website/HTML to image conversion, ensure Chrome browser is installed.

3. Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## Testing

Use the provided test script to verify functionality:

```bash
python test_image_conversion.py
```

## Notes

- All conversions preserve image quality and metadata where possible
- Website/HTML to image conversion requires Chrome browser
- PDF to image conversion supports high DPI output
- Image to JSON includes comprehensive metadata and base64 encoding
- All endpoints support proper error handling and validation
