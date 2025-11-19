# 🎯 Complete Fix Guide - Download Issue

## 🔍 **Current Situation**
- ✅ Flutter app processes files successfully
- ✅ FastAPI server has download endpoints
- ❌ Files are not being saved correctly on server
- ❌ Download returns 404 (file not found)

## 🛠️ **Step-by-Step Fix**

### **Step 1: Check Your Server's Output Directory**

First, verify where your server is trying to save files. In your FastAPI server code, check:

```python
# In your settings or config
output_dir = "downloads"  # or whatever path you're using
```

**Create the directory if it doesn't exist:**
```bash
mkdir downloads
```

### **Step 2: Fix Your Server Code**

Your current server has conflicting endpoints. Here's the corrected version:

```python
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from app.core.config import settings
from app.core.exceptions import SmartConvertException
from app.core.database import init_db, test_connection
from app.api.v1.api import api_router
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
    description="TechMindsForge FastAPI - A professional file conversion API with PDF-to-Word and OCR capabilities",
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

# Add request timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

# Create downloads directory if it doesn't exist
os.makedirs(settings.output_dir, exist_ok=True)
logger.info(f"Output directory: {settings.output_dir}")

# Mount static files for downloads
app.mount("/download", StaticFiles(directory=settings.output_dir), name="downloads")

# Include API routes
app.include_router(api_router, prefix="/api/v1")

# REMOVE THE CONFLICTING ENDPOINT - DELETE THIS ENTIRE FUNCTION:
# @app.get("/download/{filename}")
# async def download_file(filename: str):
#     """Download processed files."""
#     file_path = os.path.join(settings.output_dir, filename)
#     
#     if not os.path.exists(file_path):
#         raise HTTPException(status_code=404, detail="File not found")
#     
#     return FileResponse(
#         file_path,
#         filename=filename,
#         media_type="application/pdf"
#     )

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": f"Welcome to {settings.app_name} 🚀",
        "version": settings.app_version,
        "docs": "/docs",
        "health": "/api/v1/health/health"
    }

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
```

### **Step 3: Update Your Processing Endpoint**

Make sure your `/api/v1/pdf/add-page-numbers` endpoint saves files correctly:

```python
@app.post("/api/v1/pdf/add-page-numbers")
async def add_page_numbers(
    file: UploadFile = File(...),
    position: str = "bottom-center",
    start_page: int = 1,
    format: str = "{page}",
    font_size: float = 12.0
):
    try:
        # Read the uploaded file
        file_content = await file.read()
        
        # Process the PDF (your existing processing logic)
        processed_content = your_pdf_processing_function(
            file_content, 
            position=position,
            start_page=start_page,
            format=format,
            font_size=font_size
        )
        
        # Generate unique filename
        filename = f"{uuid.uuid4()}_numbered.pdf"
        file_path = os.path.join(settings.output_dir, filename)
        
        # Ensure directory exists
        os.makedirs(settings.output_dir, exist_ok=True)
        
        # Save the processed file
        with open(file_path, "wb") as f:
            f.write(processed_content)
        
        logger.info(f"File saved successfully: {file_path}")
        
        # Return success response
        return {
            "success": True,
            "message": "Page numbers added successfully",
            "output_filename": filename,
            "download_url": f"/download/{filename}",
            "file_size": len(processed_content)
        }
        
    except Exception as e:
        logger.error(f"Error processing PDF: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Processing failed: {str(e)}")
```

### **Step 4: Test the Server**

1. **Restart your FastAPI server**
2. **Test the endpoint directly:**

```bash
# Test if the downloads directory is accessible
curl -X GET "http://192.168.8.103:8003/download/"

# Test with a real file (replace with actual filename from your logs)
curl -X GET "http://192.168.8.103:8003/download/7df6a93f-cda6-4982-8710-d9ab6d5d3140_numbered.pdf"
```

### **Step 5: Debug Your Server**

Add this debug endpoint to your server to check what's happening:

```python
@app.get("/debug/files")
async def debug_files():
    """Debug endpoint to check saved files."""
    try:
        files = os.listdir(settings.output_dir)
        return {
            "output_dir": settings.output_dir,
            "files": files,
            "file_count": len(files)
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/debug/check-file/{filename}")
async def debug_check_file(filename: str):
    """Debug endpoint to check specific file."""
    file_path = os.path.join(settings.output_dir, filename)
    exists = os.path.exists(file_path)
    size = os.path.getsize(file_path) if exists else 0
    
    return {
        "filename": filename,
        "file_path": file_path,
        "exists": exists,
        "size_bytes": size,
        "size_kb": round(size / 1024, 2) if exists else 0
    }
```

### **Step 6: Test the Debug Endpoints**

```bash
# Check what files exist
curl -X GET "http://192.168.8.103:8003/debug/files"

# Check specific file
curl -X GET "http://192.168.8.103:8003/debug/check-file/7df6a93f-cda6-4982-8710-d9ab6d5d3140_numbered.pdf"
```

## 🎯 **Most Likely Issues**

1. **Files not being saved**: Your processing endpoint isn't writing files to the output directory
2. **Wrong directory**: The output directory path is incorrect
3. **Permission issues**: Server doesn't have write permissions to the directory
4. **Filename mismatch**: The filename in the response doesn't match the saved file

## ✅ **After the Fix**

Once you implement these changes:
1. ✅ Files will be saved correctly
2. ✅ Download endpoint will work
3. ✅ Flutter app will download actual PDF files
4. ✅ PDF files will open properly

## 🆘 **Still Having Issues?**

If the problem persists:
1. Check the server logs for errors
2. Verify the output directory path
3. Check file permissions
4. Use the debug endpoints to see what's happening
5. Test with a simple file upload first

The key is to ensure your processing endpoint actually saves the files to the correct directory! 🎯
