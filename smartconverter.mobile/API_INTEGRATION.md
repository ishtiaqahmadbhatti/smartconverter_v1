# FastAPI Integration Guide

Your Flutter Smart Converter app is now connected to your FastAPI backend running on `http://127.0.0.1:8003`.

## 🚀 Quick Start

1. **Start your FastAPI server** on port 8003
2. **Run your Flutter app** - it will automatically test the connection
3. **Check the console** for connection status messages

## 📡 API Configuration

The app is configured to connect to:
- **Base URL**: `http://192.168.8.100:8003`
- **Health Check**: `GET /api/v1/health/health`
- **Connect Timeout**: 30 seconds
- **Receive Timeout**: 60 seconds

## 🛠️ Available Endpoints

Your FastAPI backend should implement these endpoints:

### Health Check
```
GET /api/v1/health/health
Response: {"status": "healthy"}
```

### File Conversion Endpoints
```
POST /convert/pdf-to-word
POST /convert/word-to-pdf
POST /convert/images-to-pdf
POST /convert/pdf-to-images
POST /convert/merge-pdf
POST /convert/split-pdf
POST /convert/compress-pdf
POST /convert/rotate-pdf
POST /convert/protect-pdf
POST /convert/unlock-pdf
```

### Request Format
All conversion endpoints expect:
- **Content-Type**: `multipart/form-data`
- **Field name**: `file` (single file) or `files` (multiple files)

### Response Format
```json
{
  "download_url": "http://127.0.0.1:8003/download/converted_file.pdf",
  "status": "completed",
  "message": "Conversion successful"
}
```

## 📁 File Handling

### Supported File Formats
- **Images**: JPG, JPEG, PNG, GIF, BMP
- **PDFs**: PDF
- **Word**: DOC, DOCX
- **Excel**: XLS, XLSX
- **PowerPoint**: PPT, PPTX
- **HTML**: HTML, HTM

### File Size Limits
- **Maximum file size**: 50MB per file

## 🔧 Testing the Connection

### Automatic Testing
When you run the Flutter app, it will:

1. **Display API configuration** in the console
2. **Test the connection** to your FastAPI backend
3. **Show success/failure messages** with troubleshooting tips

### Manual Testing via Drawer
You can also manually test the API connection using the drawer:

1. **Open the drawer** by tapping the hamburger menu
2. **Look for "API Health Check"** item in the drawer
3. **Tap the health check item** to test the connection
4. **View the results** in real-time with visual feedback

The health check will show:
- ✅ **API is Online** - Connection successful
- ❌ **API is Offline** - Connection failed
- ❌ **Connection Failed** - Network or server error

### Console Output Examples

**✅ Success:**
```
📡 API Configuration:
   Base URL: http://192.168.8.100:8003
   Connect Timeout: 30 seconds
   Receive Timeout: 60 seconds

🔍 Testing API connection...
✅ Successfully connected to FastAPI backend at http://192.168.8.100:8003
🚀 API is ready for file conversions!
```

**❌ Failure:**
```
❌ Failed to connect to FastAPI backend
📋 Please ensure your FastAPI server is running on http://192.168.8.100:8003
💡 You can test your API by visiting: http://192.168.8.100:8003/docs
```

## 🛠️ Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure FastAPI server is running on port 8003
   - Check if the port is not blocked by firewall
   - Verify the URL is correct: `http://127.0.0.1:8003`

2. **Health Endpoint Not Found**
   - Implement a `/health` endpoint in your FastAPI app
   - Return `{"status": "healthy"}` for successful health checks

3. **File Upload Issues**
   - Ensure your FastAPI endpoints accept `multipart/form-data`
   - Check file size limits (default: 50MB)
   - Verify the field name is `file` or `files`

4. **Download Issues**
   - Ensure your API returns a `download_url` in the response
   - The URL should be accessible from the Flutter app

### Testing Your API

You can test your FastAPI endpoints using:
- **Swagger UI**: Visit `http://127.0.0.1:8003/docs`
- **Postman**: Import your API and test endpoints
- **curl**: Test with command line tools

Example curl test:
```bash
# Test health endpoint
curl http://192.168.8.100:8003/api/v1/health/health

# Test file upload
curl -X POST "http://192.168.8.100:8003/convert/pdf-to-word" \
     -H "accept: application/json" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@test.pdf"
```

## 📝 Implementation Notes

- The app uses **Dio** for HTTP requests with proper error handling
- **File uploads** are handled using `multipart/form-data`
- **Automatic retries** and timeout handling are configured
- **Detailed logging** is enabled for debugging
- **Connection testing** happens on app startup

## 🔄 Next Steps

1. **Implement your FastAPI endpoints** according to the specifications above
2. **Test the endpoints** using the Swagger UI or Postman
3. **Run the Flutter app** and verify the connection
4. **Start converting files** through the app interface

Your Flutter app is now ready to work with your FastAPI backend! 🎉
