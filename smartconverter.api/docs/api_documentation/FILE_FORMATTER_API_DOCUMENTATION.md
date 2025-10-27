# File Formatter API Documentation

## Overview
The File Formatter API provides comprehensive formatting and validation capabilities for JSON and XML files, including schema validation, formatting, and analysis tools.

## Features
- **JSON Formatting**: Format JSON with proper indentation and sorting
- **JSON Validation**: Validate JSON against schemas or basic syntax
- **XML Validation**: Validate XML against XSD schemas or basic syntax
- **XSD Validation**: Validate XSD schema files
- **JSON Minification**: Remove unnecessary whitespace from JSON
- **XML Formatting**: Format XML with proper indentation
- **Schema Analysis**: Analyze JSON structure and schema information

## Supported Formats

### Input Formats
- **JSON** - JavaScript Object Notation
- **XML** - Extensible Markup Language
- **XSD** - XML Schema Definition

### Output Formats
- **JSON** - Formatted or minified JSON
- **XML** - Formatted XML
- **Validation Results** - JSON validation reports

## API Endpoints

### Base URL
```
/api/v1/fileformattertools
```

## 1. Format JSON

**Endpoint:** `POST /format-json`

Format JSON file with proper indentation and sorting.

**Parameters:**
- `file` (multipart/form-data): JSON file to format
- `indent` (form data, optional): Indentation level (default: 2)
- `sort_keys` (form data, optional): Sort keys alphabetically (default: false)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/format-json" \
  -F "file=@data.json" \
  -F "indent=4" \
  -F "sort_keys=true"
```

**Response:**
```json
{
  "success": true,
  "message": "JSON file formatted successfully",
  "output_filename": "data_formatted.json",
  "download_url": "/download/data_formatted.json"
}
```

## 2. Validate JSON

**Endpoint:** `POST /validate-json`

Validate JSON file against schema or basic JSON syntax.

**Parameters:**
- `file` (multipart/form-data): JSON file to validate
- `schema_file` (multipart/form-data, optional): JSON schema file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/validate-json" \
  -F "file=@data.json" \
  -F "schema_file=@schema.json"
```

**Response:**
```json
{
  "success": true,
  "message": "JSON validation completed",
  "validation_result": {
    "valid": true,
    "errors": [],
    "warnings": [],
    "schema_validated": true
  }
}
```

## 3. Validate XML

**Endpoint:** `POST /validate-xml`

Validate XML file against XSD schema or basic XML syntax.

**Parameters:**
- `file` (multipart/form-data): XML file to validate
- `xsd_file` (multipart/form-data, optional): XSD schema file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/validate-xml" \
  -F "file=@data.xml" \
  -F "xsd_file=@schema.xsd"
```

**Response:**
```json
{
  "success": true,
  "message": "XML validation completed",
  "validation_result": {
    "valid": true,
    "errors": [],
    "warnings": [],
    "schema_validated": true
  }
}
```

## 4. Validate XSD

**Endpoint:** `POST /validate-xsd`

Validate XSD schema file.

**Parameters:**
- `file` (multipart/form-data): XSD schema file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/validate-xsd" \
  -F "file=@schema.xsd"
```

**Response:**
```json
{
  "success": true,
  "message": "XSD validation completed",
  "validation_result": {
    "valid": true,
    "errors": [],
    "warnings": [],
    "schema_info": {
      "target_namespace": "http://example.com/schema",
      "element_count": 5,
      "type_count": 3,
      "attribute_count": 2
    }
  }
}
```

## 5. Minify JSON

**Endpoint:** `POST /minify-json`

Minify JSON file by removing unnecessary whitespace.

**Parameters:**
- `file` (multipart/form-data): JSON file to minify

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/minify-json" \
  -F "file=@data.json"
```

**Response:**
```json
{
  "success": true,
  "message": "JSON file minified successfully",
  "output_filename": "data_minified.json",
  "download_url": "/download/data_minified.json"
}
```

## 6. Format XML

**Endpoint:** `POST /format-xml`

Format XML file with proper indentation.

**Parameters:**
- `file` (multipart/form-data): XML file to format
- `indent` (form data, optional): Indentation level (default: 2)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/format-xml" \
  -F "file=@data.xml" \
  -F "indent=4"
```

**Response:**
```json
{
  "success": true,
  "message": "XML file formatted successfully",
  "output_filename": "data_formatted.xml",
  "download_url": "/download/data_formatted.xml"
}
```

## 7. JSON Schema Info

**Endpoint:** `POST /json-schema-info`

Get information about JSON structure and schema.

**Parameters:**
- `file` (multipart/form-data): JSON file to analyze

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/fileformattertools/json-schema-info" \
  -F "file=@data.json"
```

**Response:**
```json
{
  "success": true,
  "message": "JSON schema analysis completed",
  "schema_info": {
    "type": "object",
    "size": 1024,
    "structure": {
      "type": "object",
      "keys": ["name", "age", "email"],
      "key_count": 3,
      "properties": {
        "name": {"type": "str", "value": "John Doe"},
        "age": {"type": "int", "value": 30},
        "email": {"type": "str", "value": "john@example.com"}
      }
    },
    "keys": ["name", "age", "email"],
    "length": 3
  }
}
```

## 8. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/fileformattertools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": ["JSON", "XML", "XSD"],
  "message": "Supported formats retrieved successfully"
}
```

## 9. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/fileformattertools/download/formatted_file.json" \
  --output formatted_file.json
```

## Validation Features

### JSON Validation
- **Syntax Validation**: Check for valid JSON syntax
- **Schema Validation**: Validate against JSON Schema
- **Structure Analysis**: Analyze JSON structure and types
- **Error Reporting**: Detailed error messages and warnings

### XML Validation
- **Syntax Validation**: Check for valid XML syntax
- **XSD Validation**: Validate against XML Schema Definition
- **Namespace Support**: Handle XML namespaces
- **Error Reporting**: Detailed error messages and warnings

### XSD Validation
- **Schema Validation**: Validate XSD schema syntax
- **Schema Analysis**: Analyze schema structure and elements
- **Namespace Support**: Handle schema namespaces
- **Element Information**: Provide detailed schema information

## Formatting Features

### JSON Formatting
- **Indentation**: Configurable indentation levels
- **Key Sorting**: Optional alphabetical key sorting
- **UTF-8 Support**: Full Unicode character support
- **Minification**: Remove unnecessary whitespace

### XML Formatting
- **Indentation**: Configurable indentation levels
- **Pretty Print**: Human-readable XML output
- **UTF-8 Support**: Full Unicode character support
- **Declaration**: Include XML declaration

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

# Format JSON
with open('data.json', 'rb') as f:
    files = {'file': f}
    data = {'indent': 4, 'sort_keys': True}
    response = requests.post(
        'http://localhost:8000/api/v1/fileformattertools/format-json',
        files=files, data=data
    )
    print(response.json())

# Validate JSON with schema
with open('data.json', 'rb') as f, open('schema.json', 'rb') as s:
    files = {'file': f, 'schema_file': s}
    response = requests.post(
        'http://localhost:8000/api/v1/fileformattertools/validate-json',
        files=files
    )
    print(response.json())

# Validate XML with XSD
with open('data.xml', 'rb') as f, open('schema.xsd', 'rb') as s:
    files = {'file': f, 'xsd_file': s}
    response = requests.post(
        'http://localhost:8000/api/v1/fileformattertools/validate-xml',
        files=files
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Format JSON
const formData = new FormData();
formData.append('file', jsonFileInput.files[0]);
formData.append('indent', '4');
formData.append('sort_keys', 'true');

fetch('/api/v1/fileformattertools/format-json', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Validate JSON
const validationFormData = new FormData();
validationFormData.append('file', jsonFileInput.files[0]);
validationFormData.append('schema_file', schemaFileInput.files[0]);

fetch('/api/v1/fileformattertools/validate-json', {
    method: 'POST',
    body: validationFormData
})
.then(response => response.json())
.then(data => console.log(data));

// Validate XML
const xmlFormData = new FormData();
xmlFormData.append('file', xmlFileInput.files[0]);
xmlFormData.append('xsd_file', xsdFileInput.files[0]);

fetch('/api/v1/fileformattertools/validate-xml', {
    method: 'POST',
    body: xmlFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The file formatter functionality requires the following Python packages:

```
jsonschema>=4.19.0
xmlschema>=2.5.0
lxml>=4.9.0
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

## JSON Schema Support

The API supports JSON Schema validation with the following features:

- **Schema Validation**: Full JSON Schema draft 7 support
- **Error Reporting**: Detailed validation error messages
- **Schema Analysis**: Automatic schema structure analysis
- **Type Validation**: String, number, boolean, array, object validation
- **Format Validation**: Email, date, URI format validation

## XML Schema Support

The API supports XML Schema validation with the following features:

- **XSD Validation**: Full XML Schema 1.0 and 1.1 support
- **Namespace Support**: XML namespace handling
- **Element Validation**: Element type and constraint validation
- **Attribute Validation**: Attribute type and constraint validation
- **Schema Analysis**: Automatic schema structure analysis

## Best Practices

1. **File Size**: Large files may take longer to process
2. **Schema Validation**: Use appropriate schemas for validation
3. **Encoding**: Ensure proper UTF-8 encoding for international characters
4. **Format Consistency**: Use consistent formatting for better readability
5. **Error Handling**: Check validation results for errors and warnings

## Notes

- All validation results include detailed error and warning information
- Schema validation is optional but recommended for data integrity
- Formatting preserves data while improving readability
- All temporary files are automatically cleaned up after processing
- JSON and XML files are processed with full UTF-8 support
- Schema analysis provides detailed structure information for debugging
