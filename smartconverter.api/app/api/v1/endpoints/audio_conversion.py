import os
import shutil
from typing import Optional
from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends, Request
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.services.conversion_log_service import ConversionLogService

from app.core.config import settings
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

def _determine_output_filename(original_filename: str, provided_filename: Optional[str], target_extension: str) -> str:
    """
    Determine the final output filename.
    If provided_filename is given, use it (ensuring extension).
    Otherwise, use the original filename with the new extension.
    """
    target_extension = target_extension.lstrip('.')
    
    if provided_filename and provided_filename.strip():
        filename = provided_filename.strip()
        if not filename.lower().endswith(f".{target_extension}"):
            filename += f".{target_extension}"
        return filename
    
    # Fallback to original filename with new extension
    base_name = os.path.splitext(original_filename)[0]
    return f"{base_name}.{target_extension}"


@router.post("/mp4-to-mp3", response_model=ConversionResponse)
async def convert_mp4_to_mp3(
    request: Request,
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert MP4 file to MP3 format."""
    input_path = None
    output_path = None
    
    # Init logs detail
    # Get size reliably
    file.file.seek(0, 2)
    input_size = file.file.tell()
    file.file.seek(0)
    
    # Get user_id
    user_id = await get_user_id(request, db)
    
    # Log start
    log = ConversionLogService.log_conversion(
        db=db,
        user_id=user_id,
        conversion_type="mp4-to-mp3",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="mp4",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # MP4 is video, but we allow it here for audio extraction
        FileService.validate_file(file, "video")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "mp3")
        temp_output_path = AudioConversionService.mp4_to_mp3(input_path, bitrate, quality)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="mp3"
        )
        
        # Move/Rename to final filename in output directory
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)

        return ConversionResponse(
            success=True,
            message="MP4 file converted to MP3 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
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
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/wav-to-mp3", response_model=ConversionResponse)
async def convert_wav_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert WAV file to MP3 format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "mp3")
        temp_output_path = AudioConversionService.wav_to_mp3(input_path, bitrate, quality)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="WAV file converted to MP3 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/flac-to-mp3", response_model=ConversionResponse)
async def convert_flac_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert FLAC file to MP3 format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "mp3")
        temp_output_path = AudioConversionService.flac_to_mp3(input_path, bitrate, quality)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="FLAC file converted to MP3 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/mp3-to-wav", response_model=ConversionResponse)
async def convert_mp3_to_wav(
    file: UploadFile = File(...),
    sample_rate: int = Form(44100),
    channels: int = Form(2),
    filename: Optional[str] = Form(None)
):
    """Convert MP3 file to WAV format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "wav")
        temp_output_path = AudioConversionService.mp3_to_wav(input_path, sample_rate, channels)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="MP3 file converted to WAV successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/flac-to-wav", response_model=ConversionResponse)
async def convert_flac_to_wav(
    file: UploadFile = File(...),
    sample_rate: int = Form(44100),
    channels: int = Form(2),
    filename: Optional[str] = Form(None)
):
    """Convert FLAC file to WAV format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "wav")
        temp_output_path = AudioConversionService.flac_to_wav(input_path, sample_rate, channels)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="FLAC file converted to WAV successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/wav-to-flac", response_model=ConversionResponse)
async def convert_wav_to_flac(
    file: UploadFile = File(...),
    compression_level: int = Form(5),
    filename: Optional[str] = Form(None)
):
    """Convert WAV file to FLAC format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, "flac")
        temp_output_path = AudioConversionService.wav_to_flac(input_path, compression_level)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="WAV file converted to FLAC successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/convert-audio-format", response_model=ConversionResponse)
async def convert_audio_format(
    file: UploadFile = File(...),
    output_format: str = Form(...),
    bitrate: str = Form("192k"),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert audio to any supported format."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        output_filename = _determine_output_filename(file.filename, filename, output_format)
        temp_output_path = AudioConversionService.convert_audio_format(input_path, output_format, bitrate, quality)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message=f"Audio converted to {output_format.upper()} successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/normalize-audio", response_model=ConversionResponse)
async def normalize_audio(
    file: UploadFile = File(...),
    target_dBFS: float = Form(-20.0),
    filename: Optional[str] = Form(None)
):
    """Normalize audio to target dBFS level."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        # Output format is WAV for normalize
        output_filename = _determine_output_filename(file.filename, filename, "wav")
        temp_output_path = AudioConversionService.normalize_audio(input_path, target_dBFS)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="Audio normalized successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/trim-audio", response_model=ConversionResponse)
async def trim_audio(
    file: UploadFile = File(...),
    start_time: float = Form(...),
    end_time: float = Form(...),
    filename: Optional[str] = Form(None)
):
    """Trim audio to specified time range."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        # Output format is WAV for trim
        output_filename = _determine_output_filename(file.filename, filename, "wav")
        temp_output_path = AudioConversionService.trim_audio(input_path, start_time, end_time)
        
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="Audio trimmed successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/audioconversiontools/download/{output_filename}"
        )
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
        if input_path:
            AudioConversionService.cleanup_temp_files(input_path)


@router.post("/audio-info")
async def get_audio_info(file: UploadFile = File(...)):
    """Get audio file information."""
    input_path = None
    
    try:
        FileService.validate_file(file, "audio")
        input_path = FileService.save_uploaded_file(file)
        
        audio_info = AudioConversionService.get_audio_info(input_path)
        
        return {
            "success": True,
            "message": "Audio information retrieved successfully",
            "audio_info": audio_info
        }
        
    except Exception as e:
        raise create_error_response("ProcessingError", str(e), 500)
    finally:
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
        raise create_error_response("InternalServerError", "Failed to retrieve supported formats", 500)


@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
