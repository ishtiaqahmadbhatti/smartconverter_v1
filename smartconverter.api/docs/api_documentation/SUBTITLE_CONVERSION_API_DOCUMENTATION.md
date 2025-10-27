# Subtitle Conversion API Documentation

## Overview
The Subtitle Conversion API provides comprehensive subtitle processing capabilities including format conversion, AI translation, and multi-format support for subtitle files.

## Features
- **Format Conversion**: Convert between SRT, VTT, CSV, Excel, and text formats
- **AI Translation**: Translate subtitle files using Google Translate API
- **Multi-language Support**: Support for 70+ languages
- **Excel Integration**: Full Excel (XLSX, XLS) support
- **Time Format Handling**: Automatic time format conversion
- **Text Extraction**: Extract plain text from subtitle files

## Supported Formats

### Input Formats
- **SRT** - SubRip Subtitle Format
- **VTT** - WebVTT Format
- **CSV** - Comma-Separated Values
- **XLSX** - Excel 2007+ Format
- **XLS** - Excel 97-2003 Format
- **TXT** - Plain Text Format

### Output Formats
- **SRT** - SubRip Subtitle Format
- **VTT** - WebVTT Format
- **CSV** - Comma-Separated Values
- **XLSX** - Excel 2007+ Format
- **XLS** - Excel 97-2003 Format
- **TXT** - Plain Text Format

## API Endpoints

### Base URL
```
/api/v1/subtitlesconversiontools
```

## 1. Translate SRT

**Endpoint:** `POST /translate-srt`

Translate SRT subtitle file using AI translation.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file
- `target_language` (form data, optional): Target language code (default: en)
- `source_language` (form data, optional): Source language code (default: auto)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/translate-srt" \
  -F "file=@subtitles.srt" \
  -F "target_language=es" \
  -F "source_language=en"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT file translated to es successfully",
  "output_filename": "subtitles_translated_es.srt",
  "download_url": "/download/subtitles_translated_es.srt"
}
```

## 2. Convert SRT to CSV

**Endpoint:** `POST /srt-to-csv`

Convert SRT subtitle file to CSV format.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/srt-to-csv" \
  -F "file=@subtitles.srt"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT file converted to CSV successfully",
  "output_filename": "subtitles.csv",
  "download_url": "/download/subtitles.csv"
}
```

## 3. Convert SRT to Excel

**Endpoint:** `POST /srt-to-excel`

Convert SRT subtitle file to Excel format.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file
- `format_type` (form data, optional): Excel format (xlsx, xls) (default: xlsx)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/srt-to-excel" \
  -F "file=@subtitles.srt" \
  -F "format_type=xlsx"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT file converted to XLSX successfully",
  "output_filename": "subtitles.xlsx",
  "download_url": "/download/subtitles.xlsx"
}
```

## 4. Convert SRT to Text

**Endpoint:** `POST /srt-to-text`

Convert SRT subtitle file to plain text.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/srt-to-text" \
  -F "file=@subtitles.srt"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT file converted to text successfully",
  "output_filename": "subtitles.txt",
  "download_url": "/download/subtitles.txt"
}
```

## 5. Convert SRT to VTT

**Endpoint:** `POST /srt-to-vtt`

Convert SRT subtitle file to VTT format.

**Parameters:**
- `file` (multipart/form-data): SRT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/srt-to-vtt" \
  -F "file=@subtitles.srt"
```

**Response:**
```json
{
  "success": true,
  "message": "SRT file converted to VTT successfully",
  "output_filename": "subtitles.vtt",
  "download_url": "/download/subtitles.vtt"
}
```

## 6. Convert VTT to Text

**Endpoint:** `POST /vtt-to-text`

Convert VTT subtitle file to plain text.

**Parameters:**
- `file` (multipart/form-data): VTT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/vtt-to-text" \
  -F "file=@subtitles.vtt"
```

**Response:**
```json
{
  "success": true,
  "message": "VTT file converted to text successfully",
  "output_filename": "subtitles.txt",
  "download_url": "/download/subtitles.txt"
}
```

## 7. Convert VTT to SRT

**Endpoint:** `POST /vtt-to-srt`

Convert VTT subtitle file to SRT format.

**Parameters:**
- `file` (multipart/form-data): VTT subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/vtt-to-srt" \
  -F "file=@subtitles.vtt"
```

**Response:**
```json
{
  "success": true,
  "message": "VTT file converted to SRT successfully",
  "output_filename": "subtitles.srt",
  "download_url": "/download/subtitles.srt"
}
```

## 8. Convert CSV to SRT

**Endpoint:** `POST /csv-to-srt`

Convert CSV subtitle file to SRT format.

**Parameters:**
- `file` (multipart/form-data): CSV subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/csv-to-srt" \
  -F "file=@subtitles.csv"
```

**Response:**
```json
{
  "success": true,
  "message": "CSV file converted to SRT successfully",
  "output_filename": "subtitles.srt",
  "download_url": "/download/subtitles.srt"
}
```

## 9. Convert Excel to SRT

**Endpoint:** `POST /excel-to-srt`

Convert Excel subtitle file to SRT format.

**Parameters:**
- `file` (multipart/form-data): Excel subtitle file

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/subtitlesconversiontools/excel-to-srt" \
  -F "file=@subtitles.xlsx"
```

**Response:**
```json
{
  "success": true,
  "message": "Excel file converted to SRT successfully",
  "output_filename": "subtitles.srt",
  "download_url": "/download/subtitles.srt"
}
```

## 10. Get Supported Languages

**Endpoint:** `GET /supported-languages`

Get list of supported translation languages.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/subtitlesconversiontools/supported-languages"
```

**Response:**
```json
{
  "success": true,
  "languages": ["en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "ar", "hi", "th", "vi", "tr", "pl", "nl", "sv", "da", "no", "fi", "cs", "hu", "ro", "bg", "hr", "sk", "sl", "et", "lv", "lt", "el", "he", "fa", "ur", "bn", "ta", "te", "ml", "kn", "gu", "pa", "or", "as", "ne", "si", "my", "km", "lo", "ka", "am", "sw", "zu", "af", "sq", "az", "be", "bs", "ca", "cy", "eu", "gl", "is", "mk", "mt", "sr", "uk", "uz", "yi"],
  "message": "Supported languages retrieved successfully"
}
```

## 11. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/subtitlesconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["SRT", "VTT", "CSV", "XLSX", "XLS", "TXT"],
    "output_formats": ["SRT", "VTT", "CSV", "XLSX", "XLS", "TXT"]
  },
  "message": "Supported formats retrieved successfully"
}
```

## 12. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/subtitlesconversiontools/download/converted_file.srt" \
  --output converted_file.srt
```

## Supported Languages

The translation system supports 70+ languages including:

### Major Languages
- **English** (en)
- **Spanish** (es)
- **French** (fr)
- **German** (de)
- **Italian** (it)
- **Portuguese** (pt)
- **Russian** (ru)
- **Japanese** (ja)
- **Korean** (ko)
- **Chinese** (zh)
- **Arabic** (ar)
- **Hindi** (hi)

### European Languages
- **Dutch** (nl)
- **Swedish** (sv)
- **Danish** (da)
- **Norwegian** (no)
- **Finnish** (fi)
- **Czech** (cs)
- **Hungarian** (hu)
- **Romanian** (ro)
- **Bulgarian** (bg)
- **Croatian** (hr)
- **Slovak** (sk)
- **Slovenian** (sl)
- **Estonian** (et)
- **Latvian** (lv)
- **Lithuanian** (lt)
- **Greek** (el)

### Asian Languages
- **Thai** (th)
- **Vietnamese** (vi)
- **Turkish** (tr)
- **Bengali** (bn)
- **Tamil** (ta)
- **Telugu** (te)
- **Malayalam** (ml)
- **Kannada** (kn)
- **Gujarati** (gu)
- **Punjabi** (pa)
- **Oriya** (or)
- **Assamese** (as)
- **Nepali** (ne)
- **Sinhala** (si)
- **Burmese** (my)
- **Khmer** (km)
- **Lao** (lo)
- **Georgian** (ka)
- **Armenian** (am)

### African Languages
- **Swahili** (sw)
- **Zulu** (zu)
- **Afrikaans** (af)

## File Format Specifications

### SRT Format
```
1
00:00:01,000 --> 00:00:04,000
This is the first subtitle

2
00:00:05,000 --> 00:00:08,000
This is the second subtitle
```

### VTT Format
```
WEBVTT

00:00:01.000 --> 00:00:04.000
This is the first subtitle

00:00:05.000 --> 00:00:08.000
This is the second subtitle
```

### CSV Format
```csv
Index,Start Time,End Time,Duration,Text
1,00:00:01,000,00:00:04,000,00:00:03,000,"This is the first subtitle"
2,00:00:05,000,00:00:08,000,00:00:03,000,"This is the second subtitle"
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

# Translate SRT file
with open('subtitles.srt', 'rb') as f:
    files = {'file': f}
    data = {'target_language': 'es', 'source_language': 'en'}
    response = requests.post(
        'http://localhost:8000/api/v1/subtitlesconversiontools/translate-srt',
        files=files, data=data
    )
    print(response.json())

# Convert SRT to CSV
with open('subtitles.srt', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/v1/subtitlesconversiontools/srt-to-csv',
        files=files
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Translate SRT file
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('target_language', 'es');
formData.append('source_language', 'en');

fetch('/api/v1/subtitlesconversiontools/translate-srt', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert SRT to VTT
const srtFormData = new FormData();
srtFormData.append('file', srtFileInput.files[0]);

fetch('/api/v1/subtitlesconversiontools/srt-to-vtt', {
    method: 'POST',
    body: srtFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The subtitle conversion functionality requires the following Python packages:

```
pysrt>=1.1.2
webvtt-py>=0.4.6
googletrans>=4.0.0rc1
deep-translator>=1.11.4
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

## Best Practices

1. **File Encoding**: Use UTF-8 encoding for subtitle files
2. **Time Format**: Ensure proper time format in source files
3. **Language Selection**: Choose the correct language codes for translation
4. **File Size**: Large subtitle files may take longer to process
5. **Format Validation**: Verify input file format before processing

## Notes

- Translation accuracy depends on source text quality
- Large files may take longer to process
- All temporary files are automatically cleaned up after processing
- Excel files require proper column headers (Start Time, End Time, Text)
- Time format conversion is handled automatically between SRT and VTT
