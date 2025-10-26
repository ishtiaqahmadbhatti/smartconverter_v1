# 🚀 Quick Server Fix - 5 Minutes!

## 🎯 **The Problem**
Your Flutter app downloads a text file instead of the PDF because your FastAPI server doesn't have a download endpoint.

## ⚡ **Quick Fix (5 minutes)**

### **Step 1: Create Downloads Folder**
```bash
mkdir downloads
```

### **Step 2: Add This to Your FastAPI Server**
Add this code to your main FastAPI file:

```python
from fastapi.responses import FileResponse
import os

@app.get("/download/{filename}")
async def download_file(filename: str):
    file_path = f"downloads/{filename}"
    if os.path.exists(file_path):
        return FileResponse(file_path, filename=filename)
    else:
        raise HTTPException(status_code=404, detail="File not found")
```

### **Step 3: Update Your Processing Endpoint**
Make sure your `add-page-numbers` endpoint saves files to the downloads folder:

```python
@app.post("/api/v1/pdf/add-page-numbers")
async def add_page_numbers(file: UploadFile, ...):
    # Your existing processing code...
    
    # Save the processed file
    filename = f"{uuid.uuid4()}_numbered.pdf"
    file_path = f"downloads/{filename}"
    
    os.makedirs("downloads", exist_ok=True)
    with open(file_path, "wb") as f:
        f.write(processed_content)
    
    return {
        "success": True,
        "message": "Page numbers added successfully",
        "output_filename": filename,
        "download_url": f"/download/{filename}"
    }
```

### **Step 4: Restart Your Server**
```bash
# Stop your current server (Ctrl+C)
# Then restart it
uvicorn main:app --host 0.0.0.0 --port 8003
```

### **Step 5: Test**
1. Open your Flutter app
2. Try the "Add page numbers" feature
3. Now you should get the actual PDF file!

## ✅ **That's It!**

After these changes:
- ✅ Your Flutter app will download the actual PDF
- ✅ Files will save to Downloads folder properly
- ✅ PDF will open correctly in any PDF viewer

## 🔍 **Verify It's Working**

Test the endpoint directly:
```bash
curl -X GET "http://192.168.8.100:8003/download/test.pdf"
```

Should return the file or 404 (which is expected if file doesn't exist).

## 🆘 **Need Help?**

If you're still having issues:
1. Check that the `downloads` folder exists
2. Verify your processing endpoint saves files there
3. Make sure the download endpoint is added to your FastAPI app
4. Restart the server after making changes

The Flutter app is already perfect - it just needs the server to have the download endpoint! 🎉
