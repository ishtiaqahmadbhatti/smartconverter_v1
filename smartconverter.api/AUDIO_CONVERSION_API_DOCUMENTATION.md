# Audio Conversion API Documentation

## Overview
The Audio Conversion API provides comprehensive conversion capabilities between various audio formats including MP4, WAV, FLAC, and MP3.

## Features
- **Format Conversion**: Convert between MP4, WAV, FLAC, MP3 formats
- **Quality Control**: Configurable quality settings for conversions
- **Audio Processing**: Normalize, trim, and analyze audio files
- **Multi-format Support**: Support for all major audio formats
- **Advanced Features**: Audio normalization, trimming, and information extraction

## Supported Formats

### Input Formats
- **MP4** - MPEG-4 Part 14 format (audio track)
- **WAV** - Waveform Audio File Format
- **FLAC** - Free Lossless Audio Codec
- **MP3** - MPEG Audio Layer III
- **AAC** - Advanced Audio Coding
- **OGG** - Ogg Vorbis format
- **M4A** - iTunes Audio format
- **WMA** - Windows Media Audio
- **AIFF** - Audio Interchange File Format
- **AU** - Audio file format

### Output Formats
- **MP3** - MPEG Audio Layer III
- **WAV** - Waveform Audio File Format
- **FLAC** - Free Lossless Audio Codec
- **AAC** - Advanced Audio Coding
- **OGG** - Ogg Vorbis format
- **M4A** - iTunes Audio format
- **WMA** - Windows Media Audio
- **AIFF** - Audio Interchange File Format
- **AU** - Audio file format

## API Endpoints

### Base URL
```
/api/v1/audioconversiontools
```

## 1. Convert MP4 to MP3

**Endpoint:** `POST /mp4-to-mp3`

Convert MP4 file to MP3 format.

**Parameters:**
- `file` (multipart/form-data): MP4 file to convert
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/mp4-to-mp3" \
  -F "file=@audio.mp4" \
  -F "bitrate=256k" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "MP4 file converted to MP3 successfully",
  "output_filename": "audio.mp3",
  "download_url": "/download/audio.mp3"
}
```

## 2. Convert WAV to MP3

**Endpoint:** `POST /wav-to-mp3`

Convert WAV file to MP3 format.

**Parameters:**
- `file` (multipart/form-data): WAV file to convert
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/wav-to-mp3" \
  -F "file=@audio.wav" \
  -F "bitrate=256k" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "WAV file converted to MP3 successfully",
  "output_filename": "audio.mp3",
  "download_url": "/download/audio.mp3"
}
```

## 3. Convert FLAC to MP3

**Endpoint:** `POST /flac-to-mp3`

Convert FLAC file to MP3 format.

**Parameters:**
- `file` (multipart/form-data): FLAC file to convert
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/flac-to-mp3" \
  -F "file=@audio.flac" \
  -F "bitrate=256k" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "FLAC file converted to MP3 successfully",
  "output_filename": "audio.mp3",
  "download_url": "/download/audio.mp3"
}
```

## 4. Convert MP3 to WAV

**Endpoint:** `POST /mp3-to-wav`

Convert MP3 file to WAV format.

**Parameters:**
- `file` (multipart/form-data): MP3 file to convert
- `sample_rate` (form data, optional): Sample rate in Hz (default: 44100)
- `channels` (form data, optional): Number of channels - 1 (mono) or 2 (stereo) (default: 2)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/mp3-to-wav" \
  -F "file=@audio.mp3" \
  -F "sample_rate=48000" \
  -F "channels=2"
```

**Response:**
```json
{
  "success": true,
  "message": "MP3 file converted to WAV successfully",
  "output_filename": "audio.wav",
  "download_url": "/download/audio.wav"
}
```

## 5. Convert FLAC to WAV

**Endpoint:** `POST /flac-to-wav`

Convert FLAC file to WAV format.

**Parameters:**
- `file` (multipart/form-data): FLAC file to convert
- `sample_rate` (form data, optional): Sample rate in Hz (default: 44100)
- `channels` (form data, optional): Number of channels - 1 (mono) or 2 (stereo) (default: 2)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/flac-to-wav" \
  -F "file=@audio.flac" \
  -F "sample_rate=48000" \
  -F "channels=2"
```

**Response:**
```json
{
  "success": true,
  "message": "FLAC file converted to WAV successfully",
  "output_filename": "audio.wav",
  "download_url": "/download/audio.wav"
}
```

## 6. Convert WAV to FLAC

**Endpoint:** `POST /wav-to-flac`

Convert WAV file to FLAC format.

**Parameters:**
- `file` (multipart/form-data): WAV file to convert
- `compression_level` (form data, optional): FLAC compression level 0-8 (default: 5)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/wav-to-flac" \
  -F "file=@audio.wav" \
  -F "compression_level=6"
```

**Response:**
```json
{
  "success": true,
  "message": "WAV file converted to FLAC successfully",
  "output_filename": "audio.flac",
  "download_url": "/download/audio.flac"
}
```

## 7. Convert Audio Format

**Endpoint:** `POST /convert-audio-format`

Convert audio to any supported format.

**Parameters:**
- `file` (multipart/form-data): Audio file to convert
- `output_format` (form data, required): Target format (e.g., "mp3", "wav", "flac", "aac")
- `bitrate` (form data, optional): Audio bitrate - "128k", "192k", "256k", "320k" (default: "192k")
- `quality` (form data, optional): Quality level - "low", "medium", "high", "ultra" (default: "medium")

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/convert-audio-format" \
  -F "file=@audio.mp3" \
  -F "output_format=wav" \
  -F "bitrate=256k" \
  -F "quality=high"
```

**Response:**
```json
{
  "success": true,
  "message": "Audio converted to WAV successfully",
  "output_filename": "audio.wav",
  "download_url": "/download/audio.wav"
}
```

## 8. Normalize Audio

**Endpoint:** `POST /normalize-audio`

Normalize audio to target dBFS level.

**Parameters:**
- `file` (multipart/form-data): Audio file to normalize
- `target_dBFS` (form data, optional): Target dBFS level (default: -20.0)

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/normalize-audio" \
  -F "file=@audio.wav" \
  -F "target_dBFS=-18.0"
```

**Response:**
```json
{
  "success": true,
  "message": "Audio normalized successfully",
  "output_filename": "audio_normalized.wav",
  "download_url": "/download/audio_normalized.wav"
}
```

## 9. Trim Audio

**Endpoint:** `POST /trim-audio`

Trim audio to specified time range.

**Parameters:**
- `file` (multipart/form-data): Audio file to trim
- `start_time` (form data, required): Start time in seconds
- `end_time` (form data, required): End time in seconds

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/trim-audio" \
  -F "file=@audio.wav" \
  -F "start_time=10.5" \
  -F "end_time=30.0"
```

**Response:**
```json
{
  "success": true,
  "message": "Audio trimmed successfully",
  "output_filename": "audio_trimmed.wav",
  "download_url": "/download/audio_trimmed.wav"
}
```

## 10. Get Audio Information

**Endpoint:** `POST /audio-info`

Get detailed information about an audio file.

**Parameters:**
- `file` (multipart/form-data): Audio file to analyze

**Example Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/audioconversiontools/audio-info" \
  -F "file=@audio.wav"
```

**Response:**
```json
{
  "success": true,
  "message": "Audio information retrieved successfully",
  "audio_info": {
    "duration": 120.5,
    "sample_rate": 44100,
    "channels": 2,
    "bit_depth": 16,
    "bitrate": 1411200,
    "dBFS": -12.3,
    "max_dBFS": -6.7,
    "format": "WAV"
  }
}
```

## 11. Get Supported Formats

**Endpoint:** `GET /supported-formats`

Get list of supported input and output formats.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/audioconversiontools/supported-formats"
```

**Response:**
```json
{
  "success": true,
  "formats": {
    "input_formats": ["MP4", "WAV", "FLAC", "MP3", "AAC", "OGG", "M4A", "WMA", "AIFF", "AU"],
    "output_formats": ["MP3", "WAV", "FLAC", "AAC", "OGG", "M4A", "WMA", "AIFF", "AU"]
  },
  "message": "Supported formats retrieved successfully"
}
```

## 12. Download Converted File

**Endpoint:** `GET /download/{filename}`

Download a converted audio file.

**Example Request:**
```bash
curl -X GET "http://localhost:8000/api/v1/audioconversiontools/download/converted_audio.mp3" \
  --output converted_audio.mp3
```

## Audio Quality Settings

### Bitrate Options
- **128k**: Standard quality, smaller file size
- **192k**: Good quality (default)
- **256k**: High quality
- **320k**: Maximum quality

### Quality Levels
- **Low**: Fast encoding, lower quality
- **Medium**: Balanced quality and speed (default)
- **High**: Better quality, slower encoding
- **Ultra**: Best quality, slowest encoding

### FLAC Compression Levels
- **0**: Fastest compression, larger file size
- **5**: Default compression (balanced)
- **8**: Maximum compression, smallest file size

### Sample Rates
- **44100 Hz**: CD quality (default)
- **48000 Hz**: Professional audio
- **96000 Hz**: High-resolution audio
- **192000 Hz**: Ultra high-resolution audio

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

# Convert MP4 to MP3
with open('audio.mp4', 'rb') as f:
    files = {'file': f}
    data = {'bitrate': '256k', 'quality': 'high'}
    response = requests.post(
        'http://localhost:8000/api/v1/audioconversiontools/mp4-to-mp3',
        files=files, data=data
    )
    print(response.json())

# Convert WAV to FLAC
with open('audio.wav', 'rb') as f:
    files = {'file': f}
    data = {'compression_level': '6'}
    response = requests.post(
        'http://localhost:8000/api/v1/audioconversiontools/wav-to-flac',
        files=files, data=data
    )
    print(response.json())

# Normalize audio
with open('audio.wav', 'rb') as f:
    files = {'file': f}
    data = {'target_dBFS': '-18.0'}
    response = requests.post(
        'http://localhost:8000/api/v1/audioconversiontools/normalize-audio',
        files=files, data=data
    )
    print(response.json())
```

### JavaScript Example
```javascript
// Convert MP4 to MP3
const formData = new FormData();
formData.append('file', mp4FileInput.files[0]);
formData.append('bitrate', '256k');
formData.append('quality', 'high');

fetch('/api/v1/audioconversiontools/mp4-to-mp3', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// Convert WAV to FLAC
const flacFormData = new FormData();
flacFormData.append('file', wavFileInput.files[0]);
flacFormData.append('compression_level', '6');

fetch('/api/v1/audioconversiontools/wav-to-flac', {
    method: 'POST',
    body: flacFormData
})
.then(response => response.json())
.then(data => console.log(data));

// Normalize audio
const normalizeFormData = new FormData();
normalizeFormData.append('file', audioFileInput.files[0]);
normalizeFormData.append('target_dBFS', '-18.0');

fetch('/api/v1/audioconversiontools/normalize-audio', {
    method: 'POST',
    body: normalizeFormData
})
.then(response => response.json())
.then(data => console.log(data));
```

## Dependencies

The audio conversion functionality requires the following Python packages:

```
pydub>=0.25.1
librosa>=0.10.0
soundfile>=0.12.1
```

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Install FFmpeg (required for audio processing):
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

## Audio Conversion Quality

### Format Support
- **MP3**: Universal compatibility, good compression
- **WAV**: Uncompressed, highest quality
- **FLAC**: Lossless compression, smaller than WAV
- **AAC**: Modern codec, better compression than MP3
- **OGG**: Open source, good compression

### Audio Processing Features
- **Quality Control**: Multiple quality presets
- **Bitrate Control**: Configurable audio bitrates
- **Sample Rate**: Configurable sample rates
- **Channel Support**: Mono and stereo support
- **Normalization**: Audio level normalization
- **Trimming**: Audio segment extraction

## Best Practices

1. **File Size**: Large audio files may take longer to process
2. **Quality Settings**: Choose appropriate quality for your use case
3. **Format Selection**: Use MP3 for maximum compatibility
4. **Audio Quality**: Use 192k or 256k bitrate for good quality
5. **Processing Time**: Higher quality settings take longer to process

## Notes

- All audio conversions preserve original quality when possible
- FLAC provides lossless compression for archival purposes
- MP3 provides good compression with quality loss
- WAV provides uncompressed audio for professional use
- Audio normalization helps maintain consistent volume levels
- All temporary files are automatically cleaned up after processing
- Audio files are processed with full format support
- Conversion quality depends on source file quality and format compatibility