# XML Conversion API Documentation

## Overview
The XML Conversion API provides endpoints for converting XML files to various formats and performing XML processing operations.

## Base URL
```
/api/v1/xmlconversiontools
```

## Endpoints

### Convert XML to JSON
**POST** `/xml-to-json`

Convert XML file to JSON format.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")
- `pretty_print`: Pretty print JSON output (optional, default: true)

**Response:**
```json
{
  "success": true,
  "message": "XML converted to JSON successfully",
  "output_filename": "data_converted.json",
  "download_url": "/download/data_converted.json"
}
```

### Convert XML to CSV
**POST** `/xml-to-csv`

Convert XML file to CSV format.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")
- `root_element`: Root element to extract data from (optional)
- `delimiter`: CSV delimiter (optional, default: ",")

**Response:**
```json
{
  "success": true,
  "message": "XML converted to CSV successfully",
  "output_filename": "data_converted.csv",
  "download_url": "/download/data_converted.csv"
}
```

### Convert XML to Excel
**POST** `/xml-to-excel`

Convert XML file to Excel format.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")
- `root_element`: Root element to extract data from (optional)

**Response:**
```json
{
  "success": true,
  "message": "XML converted to Excel successfully",
  "output_filename": "data_converted.xlsx",
  "download_url": "/download/data_converted.xlsx"
}
```

### Validate XML
**POST** `/validate-xml`

Validate XML file structure and syntax.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")
- `schema_file`: XSD schema file for validation (optional)

**Response:**
```json
{
  "success": true,
  "message": "XML validation completed",
  "validation_result": {
    "is_valid": true,
    "errors": [],
    "warnings": [],
    "element_count": 150,
    "attribute_count": 75
  }
}
```

### Transform XML
**POST** `/transform-xml`

Transform XML using XSLT stylesheet.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `xslt_file`: XSLT stylesheet file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")

**Response:**
```json
{
  "success": true,
  "message": "XML transformed successfully",
  "output_filename": "data_transformed.xml",
  "download_url": "/download/data_transformed.xml"
}
```

### Format XML
**POST** `/format-xml`

Format and beautify XML file.

**Request Body:**
- `file`: XML file (multipart/form-data)
- `encoding`: File encoding (optional, default: "utf-8")
- `indent_size`: Indentation size (optional, default: 2)

**Response:**
```json
{
  "success": true,
  "message": "XML formatted successfully",
  "output_filename": "data_formatted.xml",
  "download_url": "/download/data_formatted.xml"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid XML file or parameters provided"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "XML validation failed",
  "errors": ["Line 10: Invalid XML syntax", "Missing required element: 'name'"]
}
```

### 500 Internal Server Error
```json
{
  "detail": "Failed to process XML conversion"
}
```

## Usage Examples

### cURL Examples

**Convert XML to JSON:**
```bash
curl -X POST "http://localhost:8002/api/v1/xmlconversiontools/xml-to-json" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.xml" \
  -F "pretty_print=true"
```

**Convert XML to CSV:**
```bash
curl -X POST "http://localhost:8002/api/v1/xmlconversiontools/xml-to-csv" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.xml" \
  -F "root_element=items"
```

**Validate XML:**
```bash
curl -X POST "http://localhost:8002/api/v1/xmlconversiontools/validate-xml" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.xml"
```

**Transform XML:**
```bash
curl -X POST "http://localhost:8002/api/v1/xmlconversiontools/transform-xml" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.xml" \
  -F "xslt_file=@transform.xslt"
```

## Supported Formats

### Input Formats
- XML files (.xml)
- XSD schema files (.xsd)
- XSLT stylesheets (.xslt)

### Output Formats
- JSON (.json)
- CSV (.csv)
- Excel (.xlsx)
- Formatted XML (.xml)

## XML Features Supported
- XML Schema (XSD) validation
- XSLT transformations
- XML formatting and beautification
- Namespace handling
- CDATA sections
- Comments preservation

## File Size Limits
- Maximum file size: 100MB
- Maximum elements: 1,000,000
- Maximum nesting depth: 50 levels

## Rate Limits
- 150 requests per hour per user
- 15 concurrent conversions per user

## Authentication
All endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
