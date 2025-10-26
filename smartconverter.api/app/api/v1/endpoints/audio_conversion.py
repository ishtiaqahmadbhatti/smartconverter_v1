import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional, List
from app.models.schemas import ConversionResponse
from app.services.audio_conversion_service import AudioConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService

router = APIRouter()


@router.post("/mp4-to-mp3", response_model=ConversionResponse)
async def convert_mp4_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium")
):
    """Convert MP4 file to MP3 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MP4 to MP3
        output_path = AudioConversionService.mp4_to_mp3(input_path, bitrate, quality)
        
        return ConversionResponse(
            success=True,
            message="MP4 file converted to MP3 successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/wav-to-mp3", response_model=ConversionResponse)
async def convert_wav_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium")
):
    """Convert WAV file to MP3 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert WAV to MP3
        output_path = AudioConversionService.wav_to_mp3(input_path, bitrate, quality)
        
        return ConversionResponse(
            success=True,
            message="WAV file converted to MP3 successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/flac-to-mp3", response_model=ConversionResponse)
async def convert_flac_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium")
):
    """Convert FLAC file to MP3 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert FLAC to MP3
        output_path = AudioConversionService.flac_to_mp3(input_path, bitrate, quality)
        
        return ConversionResponse(
            success=True,
            message="FLAC file converted to MP3 successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/mp3-to-wav", response_model=ConversionResponse)
async def convert_mp3_to_wav(
    file: UploadFile = File(...),
    sample_rate: int = Form(44100),
    channels: int = Form(2)
):
    """Convert MP3 file to WAV format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MP3 to WAV
        output_path = AudioConversionService.mp3_to_wav(input_path, sample_rate, channels)
        
        return ConversionResponse(
            success=True,
            message="MP3 file converted to WAV successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/flac-to-wav", response_model=ConversionResponse)
async def convert_flac_to_wav(
    file: UploadFile = File(...),
    sample_rate: int = Form(44100),
    channels: int = Form(2)
):
    """Convert FLAC file to WAV format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert FLAC to WAV
        output_path = AudioConversionService.flac_to_wav(input_path, sample_rate, channels)
        
        return ConversionResponse(
            success=True,
            message="FLAC file converted to WAV successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/wav-to-flac", response_model=ConversionResponse)
async def convert_wav_to_flac(
    file: UploadFile = File(...),
    compression_level: int = Form(5)
):
    """Convert WAV file to FLAC format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert WAV to FLAC
        output_path = AudioConversionService.wav_to_flac(input_path, compression_level)
        
        return ConversionResponse(
            success=True,
            message="WAV file converted to FLAC successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/convert-audio-format", response_model=ConversionResponse)
async def convert_audio_format(
    file: UploadFile = File(...),
    output_format: str = Form(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium")
):
    """Convert audio to any supported format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert audio format
        output_path = AudioConversionService.convert_audio_format(input_path, output_format, bitrate, quality)
        
        return ConversionResponse(
            success=True,
            message=f"Audio converted to {output_format.upper()} successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/normalize-audio", response_model=ConversionResponse)
async def normalize_audio(
    file: UploadFile = File(...),
    target_dBFS: float = Form(-20.0)
):
    """Normalize audio to target dBFS level."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Normalize audio
        output_path = AudioConversionService.normalize_audio(input_path, target_dBFS)
        
        return ConversionResponse(
            success=True,
            message="Audio normalized successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/trim-audio", response_model=ConversionResponse)
async def trim_audio(
    file: UploadFile = File(...),
    start_time: float = Form(...),
    end_time: float = Form(...)
):
    """Trim audio to specified time range."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Trim audio
        output_path = AudioConversionService.trim_audio(input_path, start_time, end_time)
        
        return ConversionResponse(
            success=True,
            message="Audio trimmed successfully",
            output_filename=os.path.basename(output_path),
            download_url=f"/download/{os.path.basename(output_path)}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/audio-info")
async def get_audio_info(file: UploadFile = File(...)):
    """Get audio file information."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file)
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Get audio info
        audio_info = AudioConversionService.get_audio_info(input_path)
        
        return {
            "success": True,
            "message": "Audio information retrieved successfully",
            "audio_info": audio_info
        }
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input and output formats."""
    try:
        formats = AudioConversionService.get_supported_formats()
        return {
            "success": True,
            "formats": formats,
            "message": "Supported formats retrieved successfully"
        }
    except Exception as e:
        raise create_error_response(
            error_type="InternalServerError",
            message="Failed to retrieve supported formats",
            details={"error": str(e)},
            status_code=500
        )


@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    from app.core.config import settings
    import os
    
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
