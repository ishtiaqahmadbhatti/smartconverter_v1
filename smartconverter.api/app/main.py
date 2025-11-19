from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.exception_handlers import request_validation_exception_handler as fastapi_validation_handler
from app.core.config import settings
from app.core.exceptions import SmartConvertException
from app.core.database import init_db, test_connection, SessionLocal
from app.core.middleware import SecurityHeadersMiddleware, LoggingMiddleware
from app.api.v1.api import api_router
from app.models.request_log import RequestLog
from app.services.request_logging_service import (
    ensure_client_id_cookie,
    extract_ip,
    detect_source,
    parse_device_info,
)
import time
import logging
import os
import uuid

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="""
# SmartConverter FastAPI - Enterprise File Conversion & Processing Platform

A comprehensive, enterprise-grade file conversion and manipulation platform supporting **20+ conversion types** and **50+ file formats** with advanced processing capabilities.

<details>
<summary><b>🔄 Core Conversion Features</b></summary>

### **PDF Processing & Tools**
- **PDF Conversions**: PDF ↔ Word, Excel, PowerPoint, Images (JPG/PNG), HTML, TXT
- **PDF Manipulation**: Merge, Split, Compress, Rotate, Crop, Watermark, Page Numbers
- **PDF Security**: Password Protection, Unlock, Digital Signing, Redaction
- **PDF Analysis**: OCR Text Extraction, Metadata Extraction, Repair, Compare
- **Advanced PDF**: PDF/A Conversion, Page Extraction, Batch Processing

### **Document Processing**
- **Office Documents**: Word ↔ PDF, Excel ↔ PDF, PowerPoint ↔ PDF
- **Text Formats**: TXT, RTF, Markdown conversions
- **E-book Formats**: EPUB, MOBI, AZW conversions
- **Web Formats**: HTML ↔ PDF, Website Screenshots

### **Media Conversion**
- **Image Processing**: JPG, PNG, GIF, BMP, TIFF, WebP conversions
- **Image Enhancement**: Resize, Compress, Format Conversion, Quality Optimization
- **Video Processing**: MP4, AVI, MOV, MKV format conversions
- **Audio Processing**: MP3, WAV, FLAC, AAC, OGG format conversions

### **Data & Format Conversion**
- **JSON Tools**: JSON ↔ XML, JSON ↔ CSV, JSON Validation, Formatting
- **XML Processing**: XML ↔ JSON, XML ↔ CSV, XML Validation, Transformation
- **CSV Tools**: CSV ↔ Excel, CSV ↔ JSON, CSV Validation, Data Cleaning
- **Subtitle Formats**: SRT, VTT, ASS, SSA subtitle conversions

### **Advanced Processing**
- **OCR Technology**: Text extraction from images and scanned documents
- **File Formatting**: Code formatting, Data validation, Structure optimization
- **Batch Processing**: Multiple file processing, Bulk conversions
- **Website Conversion**: HTML to PDF, Website screenshots, URL processing

</details>

<details>
<summary><b>🛡️ Enterprise Features</b></summary>

### **Security & Authentication**
- **JWT Authentication**: Secure token-based authentication
- **OAuth Integration**: Google, GitHub, Microsoft OAuth support
- **User Management**: Registration, Login, Profile management
- **API Security**: Rate limiting, Request validation, Secure headers

### **Performance & Scalability**
- **High Performance**: Async processing, Optimized algorithms
- **Database Integration**: PostgreSQL with connection pooling
- **File Management**: Secure upload/download, Temporary file cleanup
- **Error Handling**: Comprehensive error management, Detailed logging

### **API & Integration**
- **RESTful API**: Complete REST API with OpenAPI documentation
- **Mobile Support**: Optimized for mobile applications
- **Web Integration**: Angular web application support
- **Developer Tools**: Interactive API docs, ReDoc documentation

</details>

<details>
<summary><b>📊 Technical Specifications</b></summary>

- **Supported Formats**: 50+ file formats across all categories
- **Processing Speed**: Optimized for enterprise workloads
- **File Size Limits**: Configurable size limits for different operations
- **Concurrent Processing**: Multi-threaded file processing
- **Cross-Platform**: Windows, Linux, macOS support

</details>

<details>
<summary><b>🚀 Use Cases</b></summary>

- **Business Document Processing**: Contract conversion, Report generation
- **Media Production**: Video/audio format optimization
- **Data Migration**: Format conversion for system integration
- **Content Management**: Website content processing
- **Educational**: E-book format conversions
- **Development**: Code formatting, Data validation

</details>

---

Built with **FastAPI**, **Python 3.9+**, and modern web technologies for maximum performance and reliability.
""",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    """Initialize database on application startup."""
    try:
        # Test database connection
        if test_connection():
            logger.info("Database connection successful")
            # Initialize database tables
            init_db()
            logger.info("Database initialized successfully")
        else:
            logger.error("Database connection failed")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")


# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add session middleware for OAuth state/nonce handling
app.add_middleware(SessionMiddleware, secret_key="CHANGE_ME_SUPER_SECRET")

# Add security middleware
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(LoggingMiddleware)

# Request logging and timing middleware
@app.middleware("http")
async def request_logging_middleware(request: Request, call_next):
    # Prepare a temporary response to set cookies if needed
    temp_response = JSONResponse({"status": "ok"})
    client_id = ensure_client_id_cookie(request, temp_response)

    request_id = uuid.uuid4().hex
    request.state.client_id = client_id
    request.state.request_id = request_id
    request.state.source = detect_source(request)

    start = time.time()
    try:
        response = await call_next(request)
    finally:
        duration_ms = int((time.time() - start) * 1000)

        ip, xff = extract_ip(request)
        ua = request.headers.get("user-agent")
        origin = request.headers.get("origin")
        referer = request.headers.get("referer")

        device_type, os_name, browser = parse_device_info(ua or "")
        app_platform = request.headers.get("x-app-platform")
        app_version = request.headers.get("x-app-version")
        device_id = request.headers.get("x-device-id")

        is_docs = request.url.path.startswith("/docs") or request.url.path.startswith("/redoc")
        is_download = request.url.path.startswith("/download/")

        db = SessionLocal()
        try:
            log = RequestLog(
                client_id=client_id,
                session_id=request.cookies.get("session_id"),
                request_id=request_id,
                method=request.method,
                path=request.url.path,
                query_string=str(request.url.query) if request.url.query else None,
                status_code=getattr(response, "status_code", None),
                latency_ms=duration_ms,
                source=request.state.source,
                ip=ip,
                x_forwarded_for=xff,
                user_agent=ua,
                origin=origin,
                referer=referer,
                device_type=device_type,
                os=os_name,
                browser=browser,
                app_platform=app_platform,
                app_version=app_version,
                device_id=device_id,
                is_docs=is_docs,
                is_download=is_download,
            )
            db.add(log)
            db.commit()
        except Exception as e:
            logger.error(f"Failed to write RequestLog: {e}")
            db.rollback()
        finally:
            db.close()

    # propagate any Set-Cookie from temp_response to the real response
    for k, v in temp_response.raw_headers:
        if k.decode("latin1").lower() == "set-cookie":
            response.raw_headers.append((k, v))

    response.headers["X-Process-Time"] = str(duration_ms / 1000.0)
    response.headers["X-Request-Id"] = request_id
    return response

# Mount static files for downloads
app.mount("/download", StaticFiles(directory=settings.output_dir), name="downloads")

# Include API routes
app.include_router(api_router, prefix="/api/v1")

# Download endpoint for processed files
@app.get("/download/{filename}")
async def download_file(filename: str):
    """Download processed files."""
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        file_path,
        filename=filename,
        media_type="application/pdf"
    )

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": f"Welcome to {settings.app_name} 🚀",
        "version": settings.app_version,
        "docs": "/docs",
        "health": "/api/v1/health/"
    }

@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(request: Request, exc: RequestValidationError):
    """Provide friendly validation errors for specific endpoints."""
    if request.url.path == "/api/v1/pdfconversiontools/merge":
        return JSONResponse(
            status_code=400,
            content={
                "error_type": "ValidationError",
                "message": "Please select at least 2 PDF files before merging.",
                "details": {"errors": exc.errors()}
            },
        )

    return await fastapi_validation_handler(request, exc)

# Global exception handler
@app.exception_handler(SmartConvertException)
async def smart_convert_exception_handler(request: Request, exc: SmartConvertException):
    """Handle custom application exceptions."""
    return JSONResponse(
        status_code=400,
        content={
            "error_type": type(exc).__name__,
            "message": str(exc),
            "details": {}
        }
    )

# Global exception handler for unhandled exceptions
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle unhandled exceptions."""
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "error_type": "InternalServerError",
            "message": "An unexpected error occurred",
            "details": {}
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )
