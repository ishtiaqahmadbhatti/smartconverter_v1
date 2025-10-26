# Website Conversion API Documentation

## Overview
The Website Conversion API provides endpoints for converting websites to various formats including PDF, images, and HTML processing.

## Base URL
```
/api/v1/websiteconversiontools
```

## Endpoints

### Convert Website to PDF
**POST** `/html-to-pdf`

Convert HTML content or website URL to PDF format.

**Request Body:**
```json
{
  "url": "https://example.com",
  "options": {
    "page_size": "A4",
    "orientation": "portrait",
    "margin": "1cm"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Website converted to PDF successfully",
  "output_filename": "website_converted.pdf",
  "download_url": "/download/website_converted.pdf"
}
```

### Website Screenshot
**POST** `/screenshot`

Capture a screenshot of a website.

**Request Body:**
```json
{
  "url": "https://example.com",
  "options": {
    "width": 1920,
    "height": 1080,
    "format": "png"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Screenshot captured successfully",
  "output_filename": "screenshot.png",
  "download_url": "/download/screenshot.png"
}
```

### HTML to Image
**POST** `/html-to-image`

Convert HTML content to image format.

**Request Body:**
```json
{
  "html_content": "<html><body><h1>Hello World</h1></body></html>",
  "options": {
    "format": "png",
    "width": 800,
    "height": 600
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "HTML converted to image successfully",
  "output_filename": "html_image.png",
  "download_url": "/download/html_image.png"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid URL or HTML content provided"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Failed to process website conversion"
}
```

## Usage Examples

### cURL Examples

**Convert Website to PDF:**
```bash
curl -X POST "http://localhost:8002/api/v1/websiteconversiontools/html-to-pdf" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "options": {
      "page_size": "A4",
      "orientation": "portrait"
    }
  }'
```

**Capture Screenshot:**
```bash
curl -X POST "http://localhost:8002/api/v1/websiteconversiontools/screenshot" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "options": {
      "width": 1920,
      "height": 1080
    }
  }'
```

## Supported Formats

### Input Formats
- HTML content
- Website URLs
- HTML files

### Output Formats
- PDF
- PNG
- JPEG
- WebP

## Rate Limits
- 100 requests per hour per user
- 10 concurrent conversions per user

## Authentication
All endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
