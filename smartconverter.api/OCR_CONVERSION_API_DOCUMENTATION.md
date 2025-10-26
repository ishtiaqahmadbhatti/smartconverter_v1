# OCR Conversion API Documentation

## Overview
The OCR Conversion API provides comprehensive Optical Character Recognition (OCR) capabilities for extracting text from images and PDFs, and converting them to various formats.

## Features
- **Text Extraction**: Extract text from PNG, JPG, and PDF files
- **PDF Generation**: Convert images to PDFs with searchable text layers
- **Multi-language Support**: Support for multiple languages
- **Image Preprocessing**: Automatic image enhancement for better OCR results
- **PDF Processing**: Convert image-based PDFs to searchable text PDFs

## Supported Formats

### Input Formats
- **PNG** - Portable Network Graphics
- **JPG/JPEG** - JPEG Image Format
- **PDF** - Portable Document Format
- **TIFF** - Tagged Image File Format
- **BMP** - Bitmap Image Format

### Output Formats
- **Text** - Plain text extraction
- **PDF** - PDF with searchable text layer

## API Endpoints

### Base URL
```
/api/v1/ocrconversiontools
```

## 1. Convert PNG to Text

**Endpoint:** `POST /png-to-text`

Extract text from PNG image using OCR.

**Parameters:**
- `file` (multipart/form-data): PNG image file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/png-to-text" \
  -F "file=@image.png" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "PNG image converted to text successfully",
  "extracted_text": "This is the extracted text from the image..."
}
```

## 2. Convert JPG to Text

**Endpoint:** `POST /jpg-to-text`

Extract text from JPG image using OCR.

**Parameters:**
- `file` (multipart/form-data): JPG image file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/jpg-to-text" \
  -F "file=@image.jpg" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "JPG image converted to text successfully",
  "extracted_text": "This is the extracted text from the image..."
}
```

## 3. Convert PNG to PDF

**Endpoint:** `POST /png-to-pdf`

Convert PNG image to PDF with OCR text layer.

**Parameters:**
- `file` (multipart/form-data): PNG image file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/png-to-pdf" \
  -F "file=@image.png" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "PNG image converted to PDF with OCR successfully",
  "output_filename": "image_ocr.pdf",
  "download_url": "/download/image_ocr.pdf"
}
```

## 4. Convert JPG to PDF

**Endpoint:** `POST /jpg-to-pdf`

Convert JPG image to PDF with OCR text layer.

**Parameters:**
- `file` (multipart/form-data): JPG image file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/jpg-to-pdf" \
  -F "file=@image.jpg" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "JPG image converted to PDF with OCR successfully",
  "output_filename": "image_ocr.pdf",
  "download_url": "/download/image_ocr.pdf"
}
```

## 5. Convert PDF to Text

**Endpoint:** `POST /pdf-to-text`

Extract text from PDF using OCR.

**Parameters:**
- `file` (multipart/form-data): PDF file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/pdf-to-text" \
  -F "file=@document.pdf" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF converted to text using OCR successfully",
  "extracted_text": "This is the extracted text from the PDF document..."
}
```

## 6. Convert PDF Image to PDF Text

**Endpoint:** `POST /pdf-image-to-pdf-text`

Convert PDF with images to PDF with searchable text.

**Parameters:**
- `file` (multipart/form-data): PDF file
- `language` (form data, optional): OCR language (default: eng)
- `ocr_engine` (form data, optional): OCR engine (default: tesseract)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/ocrconversiontools/pdf-image-to-pdf-text" \
  -F "file=@document.pdf" \
  -F "language=eng" \
  -F "ocr_engine=tesseract"
```

**Response:**
```json
{
  "success": true,
  "message": "PDF image converted to PDF text successfully",
  "output_filename": "document_searchable.pdf",
  "download_url": "/download/document_searchable.pdf"
}
```

## 7. Get Supported Languages

**Endpoint:** `GET /supported-languages`

Get list of supported OCR languages.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/ocrconversiontools/supported-languages"
```

**Response:**
```json
{
  "success": true,
  "languages": ["eng", "spa", "fra", "deu", "ita", "por", "rus", "ara", "chi_sim", "chi_tra"],
  "message": "Supported languages retrieved successfully"
}
```

## 8. Get Supported OCR Engines

**Endpoint:** `GET /supported-ocr-engines`

Get list of supported OCR engines.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/ocrconversiontools/supported-ocr-engines"
```

**Response:**
```json
{
  "success": true,
  "engines": ["tesseract"],
  "message": "Supported OCR engines retrieved successfully"
}
```

## 9. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/ocrconversiontools/download/converted_file.pdf" \
  --output converted_file.pdf
```

## Supported Languages

The OCR system supports multiple languages including:

- **English** (eng)
- **Spanish** (spa)
- **French** (fra)
- **German** (deu)
- **Italian** (ita)
- **Portuguese** (por)
- **Russian** (rus)
- **Arabic** (ara)
- **Chinese Simplified** (chi_sim)
- **Chinese Traditional** (chi_tra)

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

# Convert PNG to text
with open('image.png', 'rb') as f:
    files = {'file': f}
    data = {'language': 'eng', 'ocr_engine': 'tesseract'}
    response = requests.post(
        'http://localhost:8000/api/v1/ocrconversiontools/png-to-text',
        files=files, data=data
    )
    print(response.json())

# Convert JPG to PDF with OCR
with open('image.jpg', 'rb') as f:
    files = {'file': f}
    data = {'language': 'eng', 'ocr_engine': 'tesseract'}
    response = requests.post(
        'http://localhost:8000/api/v1/ocrconversiontools/jpg-to-pdf',
        files=files, data=data
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert PNG to text
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('language', 'eng');
formData.append('ocr_engine', 'tesseract');

fetch('/api/v1/ocrconversiontools/png-to-text', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert PDF to text
const pdfFormData = new FormData();
pdfFormData.append('file', pdfFileInput.files[0]);
pdfFormData.append('language', 'eng');

fetch('/api/v1/ocrconversiontools/pdf-to-text', {
    method: 'POST',
    body: pdfFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The OCR conversion functionality requires the following Python packages:

```
pytesseract>=0.3.10
easyocr>=1.7.0
paddleocr>=2.7.0
pymupdf>=1.23.0
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Install Tesseract OCR:
   - **Windows**: Download from https://github.com/UB-Mannheim/tesseract/wiki
   - **macOS**: `brew install tesseract`
   - **Linux**: `sudo apt-get install tesseract-ocr`

3. Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## Image Preprocessing

The OCR service automatically applies image preprocessing to improve text recognition:

- **Denoising**: Removes noise from images
- **Thresholding**: Converts to black and white for better contrast
- **Grayscale Conversion**: Optimizes for text recognition
- **Resolution Enhancement**: Improves text clarity

## Best Practices

1. **Image Quality**: Use high-resolution images for better OCR results
2. **Language Selection**: Choose the correct language for your text
3. **File Formats**: PNG and JPG work best for OCR
4. **Text Orientation**: Ensure text is properly oriented
5. **Contrast**: High contrast between text and background improves results

## Notes

- OCR accuracy depends on image quality and text clarity
- Multi-language documents may require multiple passes
- Large files may take longer to process
- PDF text extraction first attempts direct text extraction before using OCR
- All temporary files are automatically cleaned up after processing
