# Video Conversion API Documentation

## Overview
The Video Conversion API provides comprehensive conversion capabilities between various video formats including MOV, MKV, AVI, MP4, and audio extraction to MP3.

## Features
- **Format Conversion**: Convert between MOV, MKV, AVI, MP4 formats
- **Audio Extraction**: Extract audio from video files to MP3
- **Quality Control**: Configurable quality settings for conversions
- **Video Processing**: Resize, compress, and analyze video files
- **Multi-format Support**: Support for all major video formats

## Supported Formats

### Input Formats
- **MOV** - QuickTime Movie format
- **MKV** - Matroska Video format
- **AVI** - Audio Video Interleave format
- **MP4** - MPEG-4 Part 14 format
- **WMV** - Windows Media Video format
- **FLV** - Flash Video format
- **WEBM** - WebM format
- **M4V** - iTunes Video format
- **3GP** - 3GPP format
- **OGV** - Ogg Video format

### Output Formats
- **MP4** - MPEG-4 Part 14 format
- **MP3** - MPEG Audio Layer III format
- **AVI** - Audio Video Interleave format
- **MOV** - QuickTime Movie format
- **MKV** - Matroska Video format
- **WMV** - Windows Media Video format
- **FLV** - Flash Video format
- **WEBM** - WebM format
- **M4V** - iTunes Video format
- **3GP** - 3GPP format
- **OGV** - Ogg Video format

## API Endpoints

### Base URL
```
/api/v1/videoconversiontools
```

## 1. Convert MOV to MP4

**Endpoint:** `POST /mov-to-mp4`

Convert MOV file to MP4 format.

**Parameters:**
- `file` (multipart/form-data): MOV file to convert
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/mov-to-mp4" \
  -F "file=@video.mov" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "MOV file converted to MP4 successfully",
  "output_filename": "video.mp4",
  "download_url": "/download/video.mp4"
}
```

## 2. Convert MKV to MP4

**Endpoint:** `POST /mkv-to-mp4`

Convert MKV file to MP4 format.

**Parameters:**
- `file` (multipart/form-data): MKV file to convert
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/mkv-to-mp4" \
  -F "file=@video.mkv" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "MKV file converted to MP4 successfully",
  "output_filename": "video.mp4",
  "download_url": "/download/video.mp4"
}
```

## 3. Convert AVI to MP4

**Endpoint:** `POST /avi-to-mp4`

Convert AVI file to MP4 format.

**Parameters:**
- `file` (multipart/form-data): AVI file to convert
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/avi-to-mp4" \
  -F "file=@video.avi" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "AVI file converted to MP4 successfully",
  "output_filename": "video.mp4",
  "download_url": "/download/video.mp4"
}
```

## 4. Convert MP4 to MP3

**Endpoint:** `POST /mp4-to-mp3`

Convert MP4 file to MP3 audio format.

**Parameters:**
- `file` (multipart/form-data): MP4 file to convert
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/mp4-to-mp3" \
  -F "file=@video.mp4" \
  -F "bitrate=256k"
```

**Response:**
```json
{
  "success": true,
  "message": "MP4 file converted to MP3 successfully",
  "output_filename": "video.mp3",
  "download_url": "/download/video.mp3"
}
```

## 5. Convert Video Format

**Endpoint:** `POST /convert-video-format`

Convert video to any supported format.

**Parameters:**
- `file` (multipart/form-data): Video file to convert
- `output_format` (form data, required): Target format (e.g., "mp4", "avi", "mov", "mkv")
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/convert-video-format" \
  -F "file=@video.mp4" \
  -F "output_format=avi" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "Video converted to AVI successfully",
  "output_filename": "video.avi",
  "download_url": "/download/video.avi"
}
```

## 6. Extract Audio

**Endpoint:** `POST /extract-audio`

Extract audio from video file.

**Parameters:**
- `file` (multipart/form-data): Video file to extract audio from
- `output_format` (form data, optional): Audio format - "mp3", "wav", "aac", "ogg" (default: "mp3")
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/extract-audio" \
  -F "file=@video.mp4" \
  -F "output_format=wav" \
  -F "bitrate=256k"
```

**Response:**
```json
{
  "success": true,
  "message": "Audio extracted to WAV successfully",
  "output_filename": "video.wav",
  "download_url": "/download/video.wav"
}
```

## 7. Resize Video

**Endpoint:** `POST /resize-video`

Resize video to specified dimensions.

**Parameters:**
- `file` (multipart/form-data): Video file to resize
- `width` (form data, required): Target width in pixels
- `height` (form data, required): Target height in pixels
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/resize-video" \
  -F "file=@video.mp4" \
  -F "width=1280" \
  -F "height=720" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "Video resized to 1280x720 successfully",
  "output_filename": "video_resized.mp4",
  "download_url": "/download/video_resized.mp4"
}
```

## 8. Compress Video

**Endpoint:** `POST /compress-video`

Compress video file to reduce size.

**Parameters:**
- `file` (multipart/form-data): Video file to compress
- `compression_level` (form data, optional): Compression level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/compress-video" \
  -F "file=@video.mp4" \
  -F "compression_level=high"
```

**Response:**
```json
{
  "success": true,
  "message": "Video compressed successfully",
  "output_filename": "video_compressed.mp4",
  "download_url": "/download/video_compressed.mp4"
}
```

## 9. Get Video Information

**Endpoint:** `POST /video-info`

Get detailed information about a video file.

**Parameters:**
- `file` (multipart/form-data): Video file to analyze

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/videoconversiontools/video-info" \
  -F "file=@video.mp4"
```

**Response:**
```json
{
  "success": true,
  "message": "Video information retrieved successfully",
  "video_info": {
    "duration": 120.5,
    "fps": 30.0,
    "size": [1920, 1080],
    "width": 1920,
    "height": 1080,
    "has_audio": true,
    "audio_fps": 44100,
    "audio_duration": 120.5
  }
}
```

## 10. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/videoconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["MOV", "MKV", "AVI", "MP4", "WMV", "FLV", "WEBM", "M4V", "3GP", "OGV"],
    "output_formats": ["MP4", "MP3", "AVI", "MOV", "MKV", "WMV", "FLV", "WEBM", "M4V", "3GP", "OGV"]
  },
  "message": "Supported formats retrieved successfully"
}
```

## 11. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted video or audio file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/videoconversiontools/download/converted_video.mp4" \
  --output converted_video.mp4
```

## Quality Settings

### Video Quality Levels
- **Low**: 500k bitrate, 24fps, ultrafast preset
- **Medium**: 1000k bitrate, 30fps, medium preset
- **High**: 2000k bitrate, 60fps, slow preset
- **Ultra**: 4000k bitrate, 60fps, veryslow preset

### Audio Bitrates
- **128k**: Standard quality
- **192k**: Good quality (default)
- **256k**: High quality
- **320k**: Maximum quality

### Compression Levels
- **Low**: 800k bitrate, 24fps, fast preset
- **Medium**: 500k bitrate, 24fps, medium preset
- **High**: 300k bitrate, 24fps, slow preset
- **Ultra**: 200k bitrate, 24fps, veryslow preset

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

# Convert MOV to MP4
with open('video.mov', 'rb') as f:
    files = {'file': f}
    data = {'quality': 'high'}
    response = requests.post(
        'http://localhost:8000/api/v1/videoconversiontools/mov-to-mp4',
        files=files, data=data
    )
    print(response.json())

# Convert MP4 to MP3
with open('video.mp4', 'rb') as f:
    files = {'file': f}
    data = {'bitrate': '256k'}
    response = requests.post(
        'http://localhost:8000/api/v1/videoconversiontools/mp4-to-mp3',
        files=files, data=data
    )
    print(response.json())

# Resize video
with open('video.mp4', 'rb') as f:
    files = {'file': f}
    data = {'width': '1280', 'height': '720', 'quality': 'high'}
    response = requests.post(
        'http://localhost:8000/api/v1/videoconversiontools/resize-video',
        files=files, data=data
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert MOV to MP4
const formData = new FormData();
formData.append('file', movFileInput.files[0]);
formData.append('quality', 'high');

fetch('/api/v1/videoconversiontools/mov-to-mp4', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert MP4 to MP3
const mp3FormData = new FormData();
mp3FormData.append('file', mp4FileInput.files[0]);
mp3FormData.append('bitrate', '256k');

fetch('/api/v1/videoconversiontools/mp4-to-mp3', {
    method: 'POST',
    body: mp3FormData
})
.then(response => response.json())
.then(data => console.log(data));

// Resize video
const resizeFormData = new FormData();
resizeFormData.append('file', videoFileInput.files[0]);
resizeFormData.append('width', '1280');
resizeFormData.append('height', '720');
resizeFormData.append('quality', 'high');

fetch('/api/v1/videoconversiontools/resize-video', {
    method: 'POST',
    body: resizeFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The video conversion functionality requires the following Python packages:

```
moviepy>=1.0.3
ffmpeg-python>=0.2.0
opencv-python>=4.8.0
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Install FFmpeg (required for video processing):
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ffmpeg

# macOS
brew install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html
```

3. Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## Video Conversion Quality

### Format Support
- **MP4**: Industry standard, excellent compatibility
- **MOV**: Apple QuickTime format, high quality
- **MKV**: Open source, supports multiple audio/video tracks
- **AVI**: Legacy format, wide compatibility
- **WebM**: Web-optimized, open source

### Audio Extraction
- **MP3**: Universal compatibility, good compression
- **WAV**: Uncompressed, highest quality
- **AAC**: Modern codec, better compression than MP3
- **OGG**: Open source, good compression

### Processing Features
- **Quality Control**: Multiple quality presets
- **Resolution Scaling**: Maintain aspect ratio
- **Compression**: Reduce file size while maintaining quality
- **Audio Extraction**: High-quality audio extraction
- **Format Conversion**: Convert between all major formats

## Best Practices

1. **File Size**: Large video files may take longer to process
2. **Quality Settings**: Choose appropriate quality for your use case
3. **Format Selection**: Use MP4 for maximum compatibility
4. **Audio Quality**: Use 192k or 256k bitrate for good quality
5. **Processing Time**: Higher quality settings take longer to process

## Notes

- All video conversions preserve original quality when possible
- Audio extraction maintains original audio quality
- Large files may take longer to process
- All temporary files are automatically cleaned up after processing
- Video files are processed with full format support
- Conversion quality depends on source file quality and format compatibility
