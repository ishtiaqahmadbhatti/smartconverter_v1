# CSV Conversion API Documentation

## Overview
The CSV Conversion API provides endpoints for converting CSV files to various formats and performing data manipulation operations.

## Base URL
```
/api/v1/csvconversiontools
```

## Endpoints

### Convert CSV to Excel
**POST** `/csv-to-excel`

Convert CSV file to Excel format.

**Request Body:**
- `file`: CSV file (multipart/form-data)
- `delimiter`: CSV delimiter (optional, default: ",")
- `encoding`: File encoding (optional, default: "utf-8")

**Response:**
```json
{
  "success": true,
  "message": "CSV converted to Excel successfully",
  "output_filename": "data_converted.xlsx",
  "download_url": "/download/data_converted.xlsx"
}
```

### Convert CSV to JSON
**POST** `/csv-to-json`

Convert CSV file to JSON format.

**Request Body:**
- `file`: CSV file (multipart/form-data)
- `delimiter`: CSV delimiter (optional, default: ",")
- `encoding`: File encoding (optional, default: "utf-8")

**Response:**
```json
{
  "success": true,
  "message": "CSV converted to JSON successfully",
  "output_filename": "data_converted.json",
  "download_url": "/download/data_converted.json"
}
```

### Convert CSV to XML
**POST** `/csv-to-xml`

Convert CSV file to XML format.

**Request Body:**
- `file`: CSV file (multipart/form-data)
- `delimiter`: CSV delimiter (optional, default: ",")
- `encoding`: File encoding (optional, default: "utf-8")
- `root_element`: Root XML element name (optional, default: "data")

**Response:**
```json
{
  "success": true,
  "message": "CSV converted to XML successfully",
  "output_filename": "data_converted.xml",
  "download_url": "/download/data_converted.xml"
}
```

### Validate CSV
**POST** `/validate-csv`

Validate CSV file structure and data.

**Request Body:**
- `file`: CSV file (multipart/form-data)
- `delimiter`: CSV delimiter (optional, default: ",")
- `encoding`: File encoding (optional, default: "utf-8")

**Response:**
```json
{
  "success": true,
  "message": "CSV validation completed",
  "validation_result": {
    "is_valid": true,
    "row_count": 100,
    "column_count": 5,
    "errors": [],
    "warnings": []
  }
}
```

### Clean CSV Data
**POST** `/clean-csv`

Clean and format CSV data.

**Request Body:**
- `file`: CSV file (multipart/form-data)
- `delimiter`: CSV delimiter (optional, default: ",")
- `encoding`: File encoding (optional, default: "utf-8")
- `remove_empty_rows`: Remove empty rows (optional, default: true)
- `trim_whitespace`: Trim whitespace (optional, default: true)

**Response:**
```json
{
  "success": true,
  "message": "CSV data cleaned successfully",
  "output_filename": "data_cleaned.csv",
  "download_url": "/download/data_cleaned.csv"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid CSV file or parameters provided"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "CSV file validation failed",
  "errors": ["Row 5: Missing required column", "Row 10: Invalid data format"]
}
```

### 500 Internal Server Error
```json
{
  "detail": "Failed to process CSV conversion"
}
```

## Usage Examples

### cURL Examples

**Convert CSV to Excel:**
```bash
curl -X POST "http://localhost:8002/api/v1/csvconversiontools/csv-to-excel" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.csv" \
  -F "delimiter=,"
```

**Convert CSV to JSON:**
```bash
curl -X POST "http://localhost:8002/api/v1/csvconversiontools/csv-to-json" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.csv" \
  -F "delimiter=;"
```

**Validate CSV:**
```bash
curl -X POST "http://localhost:8002/api/v1/csvconversiontools/validate-csv" \
  -H "Authorization: Bearer <your-token>" \
  -F "file=@data.csv"
```

## Supported Formats

### Input Formats
- CSV files (.csv)
- TSV files (.tsv)
- Delimited text files

### Output Formats
- Excel (.xlsx)
- JSON (.json)
- XML (.xml)
- Cleaned CSV (.csv)

## CSV Delimiters Supported
- Comma (,)
- Semicolon (;)
- Tab (\t)
- Pipe (|)
- Custom delimiters

## File Size Limits
- Maximum file size: 50MB
- Maximum rows: 1,000,000
- Maximum columns: 1,000

## Rate Limits
- 200 requests per hour per user
- 20 concurrent conversions per user

## Authentication
All endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
