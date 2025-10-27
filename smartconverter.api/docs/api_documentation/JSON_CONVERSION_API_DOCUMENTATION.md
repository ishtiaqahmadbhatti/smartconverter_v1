# JSON Conversion Tools API Documentation

## Overview
This API provides comprehensive JSON conversion tools with full database logging and error handling. All conversions are logged to the database for tracking and analytics.

## Base URL
```
http://your-domain.com/api/v1/convert/json
```

## Authentication
All endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### 1. XML to JSON Conversion
**POST** `/xml-to-json`

Convert XML content to JSON format.

**Request Body:**
```json
{
  "xml_content": "<root><person><name>John</name><age>30</age></person></root>"
}
```

**Response:**
```json
{
  "success": true,
  "message": "XML converted to JSON successfully",
  "converted_data": {
    "person": {
      "name": "John",
      "age": "30"
    }
  }
}
```

### 2. JSON to XML Conversion
**POST** `/json-to-xml`

Convert JSON data to XML format.

**Request Body:**
```json
{
  "json_data": {
    "person": {
      "name": "John",
      "age": 30
    }
  },
  "root_name": "root"
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON converted to XML successfully",
  "converted_data": "<root><person><name>John</name><age>30</age></person></root>"
}
```

### 3. JSON Formatter
**POST** `/json-formatter`

Format JSON with proper indentation.

**Request Body:**
```json
{
  "json_data": {"name":"John","age":30,"city":"New York"}
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON formatted successfully",
  "converted_data": "{\n  \"name\": \"John\",\n  \"age\": 30,\n  \"city\": \"New York\"\n}"
}
```

### 4. JSON Validator
**POST** `/json-validator`

Validate JSON format and return detailed analysis.

**Request Body:**
```json
{
  "json_content": "{\"name\":\"John\",\"age\":30}"
}
```

**Response (Valid JSON):**
```json
{
  "valid": true,
  "message": "JSON is valid",
  "size": 20,
  "structure": {
    "type": "object",
    "keys": ["name", "age"],
    "size": 2
  }
}
```

**Response (Invalid JSON):**
```json
{
  "valid": false,
  "message": "Invalid JSON: Expecting ',' delimiter: line 1 column 15 (char 14)",
  "error_line": 1,
  "error_column": 15
}
```

### 5. JSON to CSV Conversion
**POST** `/json-to-csv`

Convert JSON array to CSV format.

**Request Body:**
```json
{
  "json_data": [
    {"name": "John", "age": 30, "city": "New York"},
    {"name": "Jane", "age": 25, "city": "Los Angeles"}
  ],
  "delimiter": ","
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON converted to CSV successfully",
  "converted_data": "name,age,city\nJohn,30,New York\nJane,25,Los Angeles"
}
```

### 6. JSON to Excel Conversion
**POST** `/json-to-excel`

Convert JSON array to Excel file.

**Request Body:**
```json
{
  "json_objects": [
    {"name": "John", "age": 30, "city": "New York"},
    {"name": "Jane", "age": 25, "city": "Los Angeles"}
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON converted to Excel successfully",
  "output_filename": "converted_20241201_143022.xlsx",
  "download_url": "/download/converted_20241201_143022.xlsx"
}
```

### 7. Excel to JSON Conversion
**POST** `/excel-to-json`

Convert Excel file to JSON format.

**Request:**
- **Content-Type:** `multipart/form-data`
- **Body:** Excel file upload

**Response:**
```json
{
  "success": true,
  "message": "Excel converted to JSON successfully",
  "converted_data": {
    "data": [
      {"name": "John", "age": 30, "city": "New York"},
      {"name": "Jane", "age": 25, "city": "Los Angeles"}
    ],
    "columns": ["name", "age", "city"],
    "shape": [2, 3],
    "info": {
      "rows": 2,
      "columns": 3
    }
  }
}
```

### 8. CSV to JSON Conversion
**POST** `/csv-to-json`

Convert CSV file to JSON format.

**Request:**
- **Content-Type:** `multipart/form-data`
- **Body:** CSV file upload + delimiter parameter

**Response:**
```json
{
  "success": true,
  "message": "CSV converted to JSON successfully",
  "converted_data": [
    {"name": "John", "age": "30", "city": "New York"},
    {"name": "Jane", "age": "25", "city": "Los Angeles"}
  ]
}
```

### 9. JSON to YAML Conversion
**POST** `/json-to-yaml`

Convert JSON to YAML format.

**Request Body:**
```json
{
  "json_data": {
    "name": "John",
    "age": 30,
    "hobbies": ["reading", "swimming"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON converted to YAML successfully",
  "converted_data": "name: John\nage: 30\nhobbies:\n- reading\n- swimming\n"
}
```

### 10. YAML to JSON Conversion
**POST** `/yaml-to-json`

Convert YAML to JSON format.

**Request Body:**
```json
{
  "yaml_content": "name: John\nage: 30\nhobbies:\n- reading\n- swimming"
}
```

**Response:**
```json
{
  "success": true,
  "message": "YAML converted to JSON successfully",
  "converted_data": {
    "name": "John",
    "age": 30,
    "hobbies": ["reading", "swimming"]
  }
}
```

### 11. JSON Objects to CSV
**POST** `/json-objects-to-csv`

Convert JSON objects array to CSV format.

**Request Body:**
```json
{
  "json_objects": [
    {"name": "John", "age": 30, "city": "New York"},
    {"name": "Jane", "age": 25, "city": "Los Angeles"}
  ],
  "delimiter": ","
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON objects converted to CSV successfully",
  "converted_data": "name,age,city\nJohn,30,New York\nJane,25,Los Angeles"
}
```

### 12. JSON Objects to Excel
**POST** `/json-objects-to-excel`

Convert JSON objects array to Excel file.

**Request Body:**
```json
{
  "json_objects": [
    {"name": "John", "age": 30, "city": "New York"},
    {"name": "Jane", "age": 25, "city": "Los Angeles"}
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "JSON objects converted to Excel successfully",
  "output_filename": "converted_20241201_143022.xlsx",
  "download_url": "/download/converted_20241201_143022.xlsx"
}
```

## File Download
**GET** `/download/{filename}`

Download converted files (Excel, etc.).

## Error Handling

All endpoints return consistent error responses:

```json
{
  "detail": {
    "error_type": "FileProcessingError",
    "message": "Invalid JSON format: Expecting ',' delimiter",
    "details": {
      "error": "Specific error details"
    }
  }
}
```

## Database Logging

All conversion operations are automatically logged to the database with:
- Conversion type
- Input data size
- Output data size
- Success/failure status
- Error messages (if any)
- User ID
- Timestamp

## Rate Limiting

- No specific rate limiting implemented
- File size limits apply (configurable)
- Large files may take longer to process

## Supported File Types

### Input Formats:
- JSON (string, object, array)
- XML (string)
- YAML (string)
- CSV (file upload)
- Excel (.xlsx, .xls) (file upload)

### Output Formats:
- JSON (formatted, validated)
- XML (formatted)
- YAML (formatted)
- CSV (with custom delimiters)
- Excel (.xlsx)

## Examples

### Complete Workflow Example:

1. **Validate JSON:**
```bash
curl -X POST "http://localhost:8000/api/v1/convert/json/json-validator" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"json_content": "{\"name\":\"John\",\"age\":30}"}'
```

2. **Format JSON:**
```bash
curl -X POST "http://localhost:8000/api/v1/convert/json/json-formatter" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"json_data": {"name":"John","age":30}}'
```

3. **Convert to CSV:**
```bash
curl -X POST "http://localhost:8000/api/v1/convert/json/json-to-csv" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"json_data": [{"name":"John","age":30}], "delimiter": ","}'
```

4. **Convert to Excel:**
```bash
curl -X POST "http://localhost:8000/api/v1/convert/json/json-to-excel" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"json_objects": [{"name":"John","age":30}]}'
```

## Testing

Run the comprehensive test suite:
```bash
python -m pytest tests/test_json_conversion.py -v
```

## Dependencies

Required Python packages:
- `PyYAML>=6.0.1` - YAML processing
- `pandas>=2.0.0` - Excel/CSV processing
- `fastapi` - API framework
- `pydantic` - Data validation

## Notes

- All conversions preserve data integrity
- Large files are processed efficiently
- Database logging provides full audit trail
- Error handling is comprehensive and user-friendly
- File uploads are validated for type and size
- Generated files are automatically cleaned up after download
