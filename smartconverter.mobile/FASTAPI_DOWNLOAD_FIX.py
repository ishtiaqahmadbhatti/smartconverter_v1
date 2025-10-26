# Quick Fix for FastAPI Download Endpoint
# Add this to your FastAPI server to enable file downloads

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import os

app = FastAPI()

# Option 1: Simple download endpoint
@app.get("/download/{filename}")
async def download_file(filename: str):
    """Download processed files"""
    file_path = f"downloads/{filename}"
    
    if os.path.exists(file_path):
        return FileResponse(
            file_path, 
            filename=filename,
            media_type="application/pdf"
        )
    else:
        raise HTTPException(status_code=404, detail="File not found")

# Option 2: Alternative endpoint
@app.get("/api/v1/files/{filename}")
async def get_processed_file(filename: str):
    """Get processed files via API endpoint"""
    file_path = f"downloads/{filename}"
    
    if os.path.exists(file_path):
        return FileResponse(
            file_path, 
            filename=filename,
            media_type="application/pdf"
        )
    else:
        raise HTTPException(status_code=404, detail="File not found")

# Option 3: Static file serving (mount entire directory)
# Uncomment this if you want to serve all files in downloads folder
# app.mount("/download", StaticFiles(directory="downloads"), name="downloads")

# Make sure your processing endpoint saves files to downloads folder:
@app.post("/api/v1/pdf/add-page-numbers")
async def add_page_numbers(file: UploadFile, ...):
    # Your existing processing code here...
    
    # After processing, save the file:
    processed_content = your_processing_function(file_content)
    
    # Save to downloads directory
    filename = f"{uuid.uuid4()}_numbered.pdf"
    file_path = f"downloads/{filename}"
    
    # Create downloads directory if it doesn't exist
    os.makedirs("downloads", exist_ok=True)
    
    # Write the processed file
    with open(file_path, "wb") as f:
        f.write(processed_content)
    
    return {
        "success": True,
        "message": "Page numbers added successfully",
        "output_filename": filename,
        "download_url": f"/download/{filename}"
    }
