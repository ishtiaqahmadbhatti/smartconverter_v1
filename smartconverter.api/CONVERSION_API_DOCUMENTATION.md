# General Conversion API Documentation

## Overview
The General Conversion API provides core conversion endpoints for basic file format conversions and processing operations.

## Base URL
```
/api/v1/convert
```

## Endpoints

### File Upload and Convert
**POST** `/upload`

Upload a file and specify conversion parameters.

**Request Body:**
- `file`: File to convert (multipart/form-data)
- `target_format`: Target format for conversion
- `options`: Conversion options (optional)

**Response:**
```json
{
  "success": true,
  "message": "File uploaded and conversion initiated",
  "file_id": "uuid-1234-5678-9abc",
  "status": "processing",
  "estimated_completion": "2024-01-15T10:35:00Z"
}
```

### Get Conversion Status
**GET** `/status/{file_id}`

Check the status of a conversion job.

**Response:**
```json
{
  "file_id": "uuid-1234-5678-9abc",
  "status": "completed",
  "progress": 100,
  "output_filename": "converted_file.pdf",
  "download_url": "/download/converted_file.pdf",
  "file_size": 1024000,
  "processing_time": "15.5s"
}
```

### Download Converted File
**GET** `/download/{file_id}`

Download the converted file.

**Response:**
- File download with appropriate headers

### Batch Conversion
**POST** `/batch`

Convert multiple files in a single request.

**Request Body:**
- `files`: Array of files (multipart/form-data)
- `target_format`: Target format for all files
- `options`: Conversion options (optional)

**Response:**
```json
{
  "success": true,
  "message": "Batch conversion initiated",
  "batch_id": "batch-uuid-1234",
  "total_files": 5,
  "status": "processing",
  "files": [
    {
      "file_id": "file-1-uuid",
      "original_name": "document1.pdf",
      "status": "processing"
    },
    {
      "file_id": "file-2-uuid", 
      "original_name": "document2.pdf",
      "status": "processing"
    }
  ]
}
```

### Get Batch Status
**GET** `/batch/{batch_id}/status`

Check the status of a batch conversion.

**Response:**
```json
{
  "batch_id": "batch-uuid-1234",
  "status": "completed",
  "total_files": 5,
  "completed_files": 5,
  "failed_files": 0,
  "progress": 100,
  "files": [
    {
      "file_id": "file-1-uuid",
      "status": "completed",
      "output_filename": "converted1.pdf",
      "download_url": "/download/converted1.pdf"
    }
  ]
}
```

### Supported Formats
**GET** `/formats`

Get list of supported input and output formats.

**Response:**
```json
{
  "supported_formats": {
    "input": [
      {
        "format": "pdf",
        "extensions": [".pdf"],
        "mime_types": ["application/pdf"]
      },
      {
        "format": "docx",
        "extensions": [".docx"],
        "mime_types": ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
      }
    ],
    "output": [
      {
        "format": "pdf",
        "extensions": [".pdf"],
        "mime_types": ["application/pdf"]
      },
      {
        "format": "docx", 
        "extensions": [".docx"],
        "mime_types": ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
      }
    ],
    "conversions": [
      {
        "from": "pdf",
        "to": "docx",
        "available": true
      },
      {
        "from": "docx",
        "to": "pdf", 
        "available": true
      }
    ]
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid file format or conversion parameters"
}
```

### 404 Not Found
```json
{
  "detail": "File or conversion job not found"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "File processing failed",
  "error": "Unsupported file format"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Conversion service unavailable"
}
```

## Usage Examples

### cURL Examples

**Upload and Convert File:**
```bash
curl -X POST "http://localhost:8002/api/v1/convert/upload" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@document.pdf" \
  -F "target_format=docx"
```

**Check Conversion Status:**
```bash
curl -X GET "http://localhost:8002/api/v1/convert/status/uuid-1234-5678-9abc" \
  -H "Authorization: Bearer <your-token>"
```

**Download Converted File:**
```bash
curl -X GET "http://localhost:8002/api/v1/convert/download/uuid-1234-5678-9abc" \
  -H "Authorization: Bearer <your-token>" \
  -O converted_file.pdf
```

**Batch Conversion:**
```bash
curl -X POST "http://localhost:8002/api/v1/convert/batch" \
  -H "Authorization: Bearer <your-token>" \
  -F "files=@file1.pdf" \
  -F "files=@file2.pdf" \
  -F "target_format=docx"
```

## Supported Conversions

### Document Formats
- PDF ↔ Word (DOCX)
- PDF ↔ Excel (XLSX)
- PDF ↔ PowerPoint (PPTX)
- Word ↔ Excel
- Word ↔ PowerPoint
- Excel ↔ PowerPoint

### Image Formats
- JPG ↔ PNG
- JPG ↔ GIF
- PNG ↔ GIF
- BMP ↔ JPG
- TIFF ↔ PNG

### Text Formats
- TXT ↔ RTF
- TXT ↔ HTML
- RTF ↔ HTML
- Markdown ↔ HTML

## File Size Limits
- Maximum file size: 100MB per file
- Maximum batch size: 500MB total
- Maximum files per batch: 50 files

## Processing Times
- Small files (< 1MB): 5-15 seconds
- Medium files (1-10MB): 15-60 seconds
- Large files (10-100MB): 1-5 minutes

## Rate Limits
- 100 conversions per hour per user
- 10 concurrent conversions per user
- 5 batch conversions per hour per user

## Authentication
All endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
