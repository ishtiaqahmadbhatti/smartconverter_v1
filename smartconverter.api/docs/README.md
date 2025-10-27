# SmartConverter FastAPI - Documentation

This directory contains all documentation for the SmartConverter FastAPI application, organized by category for easy navigation and maintenance.

## 📁 Documentation Structure

```
docs/
├── api_documentation/          # API endpoint documentation
│   ├── AUDIO_CONVERSION_API_DOCUMENTATION.md
│   ├── AUTH_API_DOCUMENTATION.md
│   ├── CONVERSION_API_DOCUMENTATION.md
│   ├── CSV_CONVERSION_API_DOCUMENTATION.md
│   ├── EBOOK_CONVERSION_API_DOCUMENTATION.md
│   ├── FILE_FORMATTER_API_DOCUMENTATION.md
│   ├── HEALTH_API_DOCUMENTATION.md
│   ├── IMAGE_CONVERSION_API_DOCUMENTATION.md
│   ├── JSON_CONVERSION_API_DOCUMENTATION.md
│   ├── OCR_CONVERSION_API_DOCUMENTATION.md
│   ├── PDF_CONVERSION_API_DOCUMENTATION.md
│   ├── PERSONS_API_DOCUMENTATION.md
│   ├── SUBTITLE_CONVERSION_API_DOCUMENTATION.md
│   ├── TEXT_CONVERSION_API_DOCUMENTATION.md
│   ├── USERS_API_DOCUMENTATION.md
│   ├── VIDEO_CONVERSION_API_DOCUMENTATION.md
│   ├── WEBSITE_CONVERSION_API_DOCUMENTATION.md
│   └── XML_CONVERSION_API_DOCUMENTATION.md
├── conversion_docs/            # Conversion-specific documentation
│   └── OFFICE_DOCUMENTS_CONVERSION_SUMMARY.md
├── guides/                     # Setup and usage guides
│   ├── AUTHENTICATION_GUIDE.md
│   ├── POSTGRESQL_CONNECTION_GUIDE.md
│   └── USER_REGISTRATION.md
└── README.md                   # This file
```

## 📚 Documentation Categories

### 🔌 **API Documentation** (`api_documentation/`)
Complete API endpoint documentation for all services:

#### **Conversion APIs**
- **Audio Conversion**: MP3, WAV, FLAC, AAC, OGG format conversions
- **Video Conversion**: MP4, AVI, MOV, MKV format conversions
- **PDF Conversion**: PDF manipulation, conversion, and advanced tools
- **Image Conversion**: JPG, PNG, GIF, BMP, TIFF, WebP conversions
- **OCR Conversion**: Text extraction from images and scanned documents
- **Text Conversion**: TXT, RTF, Markdown conversions
- **Subtitle Conversion**: SRT, VTT, ASS, SSA subtitle conversions
- **eBook Conversion**: EPUB, MOBI, AZW conversions
- **File Formatter**: Code formatting and data validation
- **CSV Conversion**: CSV ↔ Excel, JSON conversions
- **XML Conversion**: XML ↔ JSON, CSV conversions
- **Website Conversion**: HTML to PDF, URL processing

#### **Core APIs**
- **Health**: API health check and status endpoints
- **Authentication**: Login, logout, token management
- **Users**: User management and profile operations
- **Persons**: Person data management
- **General Conversion**: Batch processing and queue management

### 🔄 **Conversion Documentation** (`conversion_docs/`)
Specialized documentation for complex conversion processes:
- **Office Documents**: Word, Excel, PowerPoint conversion workflows
- **Advanced Features**: Batch processing, quality settings, format specifications

### 📖 **Guides** (`guides/`)
Setup, configuration, and usage guides:
- **Authentication Guide**: JWT, OAuth setup and usage
- **PostgreSQL Connection**: Database setup and configuration
- **User Registration**: Account creation and management workflows

## 🚀 Quick Start

### For Developers
1. Start with `guides/AUTHENTICATION_GUIDE.md` for API access
2. Review `api_documentation/HEALTH_API_DOCUMENTATION.md` for basic endpoints
3. Explore specific conversion APIs based on your needs

### For API Integration
1. Check `api_documentation/CONVERSION_API_DOCUMENTATION.md` for general conversion
2. Review specific conversion APIs (PDF, Image, Audio, etc.)
3. Follow `guides/USER_REGISTRATION.md` for user management

### For System Administration
1. Start with `guides/POSTGRESQL_CONNECTION_GUIDE.md`
2. Review authentication setup in `guides/AUTHENTICATION_GUIDE.md`
3. Check conversion documentation for system requirements

## 📋 API Endpoint Categories

### 🔄 **Primary Conversion Tools**
1. **Health** - System status and health checks
2. **JSON Conversion** - JSON processing and validation
3. **XML Conversion** - XML processing and transformation
4. **CSV Conversion** - CSV data manipulation
5. **Office Documents** - Word, Excel, PowerPoint conversions
6. **PDF Conversion** - PDF manipulation and conversion
7. **Image Conversion** - Image format conversions
8. **OCR Conversion** - Text extraction from images
9. **Website Conversion** - HTML to PDF, URL processing
10. **Video Conversion** - Video format conversions
11. **Audio Conversion** - Audio format conversions
12. **Subtitle Conversion** - Subtitle format conversions
13. **Text Conversion** - Text format conversions
14. **File Formatter** - Code and data formatting
15. **eBook Conversion** - E-book format conversions
16. **General Conversion** - Batch processing and queue management

### 🔧 **Supporting APIs**
17. **Authentication** - Login, logout, token management
18. **Users** - User management and profiles
19. **Persons** - Person data management

## 🛠️ Documentation Standards

### File Naming Convention
- **API Documentation**: `[SERVICE]_API_DOCUMENTATION.md`
- **Conversion Docs**: `[SERVICE]_CONVERSION_SUMMARY.md`
- **Guides**: `[TOPIC]_GUIDE.md`

### Content Structure
Each API documentation file includes:
- **Overview**: Service description and capabilities
- **Endpoints**: Complete endpoint listing with parameters
- **Request/Response Examples**: JSON examples for all endpoints
- **Error Handling**: Common error codes and messages
- **Rate Limits**: Usage limits and restrictions
- **Authentication**: Required authentication methods

## 🔍 Finding Documentation

### By Service Type
- **Audio/Video**: `api_documentation/AUDIO_CONVERSION_API_DOCUMENTATION.md`
- **Documents**: `api_documentation/PDF_CONVERSION_API_DOCUMENTATION.md`
- **Data Formats**: `api_documentation/JSON_CONVERSION_API_DOCUMENTATION.md`
- **Authentication**: `api_documentation/AUTH_API_DOCUMENTATION.md`

### By Use Case
- **File Conversion**: Check specific conversion API docs
- **User Management**: `api_documentation/USERS_API_DOCUMENTATION.md`
- **System Setup**: Review `guides/` folder
- **Database Setup**: `guides/POSTGRESQL_CONNECTION_GUIDE.md`

## 📈 Maintenance

### Adding New Documentation
1. **API Documentation**: Add to `api_documentation/` with `[SERVICE]_API_DOCUMENTATION.md` naming
2. **Conversion Docs**: Add to `conversion_docs/` for specialized conversion processes
3. **Guides**: Add to `guides/` for setup and usage instructions

### Updating Existing Documentation
- Keep examples current with API changes
- Update endpoint URLs if they change
- Maintain consistent formatting across all files
- Update this README when adding new categories

## 🔗 Related Resources

- **Main README**: `../README.md` - Project overview and quick start
- **Test Suite**: `../tests/README.md` - Testing documentation
- **API Server**: `http://localhost:8000/docs` - Interactive API documentation
- **ReDoc**: `http://localhost:8000/redoc` - Alternative API documentation

---

**Note**: This documentation structure is designed to be comprehensive yet easy to navigate. Each file is self-contained with complete information for its specific service or topic.
