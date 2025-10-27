# SmartConverter FastAPI - Test Suite

This directory contains comprehensive test suites for the SmartConverter FastAPI application, organized by functionality.

## 📁 Test Structure

```
tests/
├── api_tests/              # API-level tests
│   ├── test_api_health.py
│   └── ...
├── conversion_tests/       # Conversion functionality tests
│   ├── test_audio_conversion.py
│   ├── test_video_conversion.py
│   ├── test_pdf_conversion.py
│   ├── test_image_conversion.py
│   ├── test_ocr_conversion.py
│   ├── test_text_conversion.py
│   ├── test_subtitle_conversion.py
│   ├── test_ebook_conversion.py
│   ├── test_file_formatter.py
│   ├── test_csv_conversion.py
│   ├── test_xml_conversion.py
│   ├── test_office_documents_conversion.py
│   ├── test_website_conversion.py
│   └── test_conversion.py
├── auth_tests/            # Authentication & user management tests
│   ├── test_auth.py
│   ├── test_users.py
│   └── test_persons.py
└── run_all_tests.py       # Comprehensive test runner
```

## 🧪 Test Categories

### 1. **API Tests** (`api_tests/`)
- **Health Check Tests**: API health and status endpoints
- **General API Tests**: Basic API functionality and responses

### 2. **Conversion Tests** (`conversion_tests/`)
- **Audio Conversion**: MP3, WAV, FLAC, AAC, OGG conversions
- **Video Conversion**: MP4, AVI, MOV, MKV format conversions
- **PDF Conversion**: PDF manipulation, conversion, and tools
- **Image Conversion**: JPG, PNG, GIF, BMP, TIFF, WebP conversions
- **OCR Conversion**: Text extraction from images and documents
- **Text Conversion**: TXT, RTF, Markdown conversions
- **Subtitle Conversion**: SRT, VTT, ASS, SSA subtitle conversions
- **eBook Conversion**: EPUB, MOBI, AZW conversions
- **File Formatter**: Code formatting and data validation
- **CSV Conversion**: CSV ↔ Excel, JSON conversions
- **XML Conversion**: XML ↔ JSON, CSV conversions
- **Office Documents**: Word, Excel, PowerPoint conversions
- **Website Conversion**: HTML to PDF, URL processing
- **General Conversion**: Batch processing, queue management

### 3. **Authentication Tests** (`auth_tests/`)
- **Authentication**: Login, logout, token management
- **User Management**: CRUD operations for users
- **Person Management**: CRUD operations for persons
- **OAuth Integration**: Google, GitHub, Microsoft OAuth

## 🚀 Running Tests

### Run All Tests
```bash
python run_all_tests.py
```

### Run Specific Test Suite
```bash
# Run conversion tests
python tests/conversion_tests/test_pdf_conversion.py

# Run auth tests
python tests/auth_tests/test_auth.py

# Run API tests
python tests/api_tests/test_api_health.py
```

### Run Individual Test Files
```bash
# Test specific conversion
python tests/conversion_tests/test_audio_conversion.py

# Test authentication
python tests/auth_tests/test_users.py
```

## 📋 Test Features

### ✅ **Comprehensive Coverage**
- All API endpoints tested
- All conversion formats covered
- Authentication flows tested
- Error handling validated

### 🔧 **Test Utilities**
- Automatic test file creation
- Cleanup after tests
- Detailed error reporting
- Progress tracking

### 📊 **Test Results**
- Pass/Fail status for each test
- Detailed error messages
- Performance metrics
- Summary statistics

## 🛠️ Test Configuration

### Prerequisites
- FastAPI server running on `http://localhost:8000`
- Required Python packages installed
- Test files created automatically

### Environment Setup
```bash
# Install test dependencies
pip install requests pandas python-docx python-pptx pydub

# Start the FastAPI server
python start_app.py

# Run tests
python run_all_tests.py
```

## 📝 Test File Structure

Each test file follows this structure:

```python
#!/usr/bin/env python3
"""
Test script for [Functionality] functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/[endpoint]"

def test_functionality():
    """Test specific functionality."""
    try:
        # Test implementation
        response = requests.post(f"{BASE_URL}/endpoint", data=data)
        
        if response.status_code == 200:
            print("✅ Test successful")
        else:
            print(f"❌ Test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Test error: {e}")

def main():
    """Run all tests."""
    print("🧪 Testing [Functionality] API")
    print("=" * 50)
    
    test_functionality()
    
    print("✅ Tests completed!")

if __name__ == "__main__":
    main()
```

## 🎯 Test Goals

1. **Functionality Verification**: Ensure all endpoints work correctly
2. **Error Handling**: Test error scenarios and edge cases
3. **Performance Testing**: Validate response times and resource usage
4. **Integration Testing**: Test end-to-end workflows
5. **Regression Testing**: Prevent breaking changes

## 📈 Continuous Integration

The test suite is designed to be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    python run_all_tests.py
```

## 🔍 Troubleshooting

### Common Issues
1. **Server Not Running**: Ensure FastAPI server is running on port 8000
2. **Missing Dependencies**: Install required packages
3. **File Permissions**: Check file creation permissions
4. **Network Issues**: Verify localhost connectivity

### Debug Mode
```bash
# Run with verbose output
python -u run_all_tests.py
```

## 📚 Additional Resources

- [FastAPI Testing Guide](https://fastapi.tiangolo.com/tutorial/testing/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Requests Library](https://requests.readthedocs.io/)

---

**Note**: This test suite is designed to be comprehensive and maintainable. Each test is independent and can be run individually or as part of the complete suite.
