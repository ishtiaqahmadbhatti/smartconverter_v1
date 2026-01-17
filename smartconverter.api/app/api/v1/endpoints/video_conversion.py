import os
import shutil
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query, Request
from fastapi.responses import FileResponse
from typing import Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.v1.dependencies import get_user_id
from app.services.conversion_log_service import ConversionLogService

from app.models.schemas import ConversionResponse
from app.services.video_conversion_service import VideoConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService
from app.core.config import settings



router = APIRouter()

def _determine_output_filename(original_filename: str, provided_filename: Optional[str], target_extension: str) -> str:
    """
    Determine the final output filename.
    If provided_filename is set, use it (appending extension if needed).
    Otherwise, use the original_filename with the new extension.
    """
    # Normalize extension (remove leading dot if present)
    target_extension = target_extension.lstrip('.')
    
    if provided_filename and provided_filename.strip():
        filename = provided_filename.strip()
        # Ensure correct extension
        if not filename.lower().endswith(f".{target_extension}"):
            filename += f".{target_extension}"
        return filename
    
    # Fallback to original filename
    base_name = os.path.splitext(original_filename)[0]
    return f"{base_name}.{target_extension}"


@router.post("/mov-to-mp4", response_model=ConversionResponse)
async def convert_mov_to_mp4(
    request: Request,
    file: UploadFile = File(...),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Convert MOV file to MP4 format."""
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
        conversion_type="mov-to-mp4",
        input_filename=file.filename,
        input_file_size=input_size,
        input_file_type="mov",
        ip_address=request.client.host,
        user_agent=request.headers.get("user-agent"),
        api_endpoint=request.url.path
    )
    
    try:
        # Validate file
        FileService.validate_file(file, "mov")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, "mp4")
        
        # Convert
        temp_output_path = VideoConversionService.mov_to_mp4(input_path, quality)
        
        # Update log on success
        ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename=output_filename,
            output_file_type="mp4"
        )
        
        # Move to final location with correct filename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
             
        return ConversionResponse(
            success=True,
            message="MOV file converted to MP4 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
        )
        
    except (FileProcessingError, UnsupportedFileTypeError, FileSizeExceededError) as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type=type(e).__name__,
            message=str(e),
            status_code=400
        )
    except Exception as e:
        ConversionLogService.update_log_status(db=db, log_id=log.id, status="failed", error_message=str(e))
        raise create_error_response(
            error_type="InternalServerError",
            message="An unexpected error occurred",
            details={"error": str(e)},
            status_code=500
        )
    finally:
        # Cleanup temporary files
        if input_path:
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/mkv-to-mp4", response_model=ConversionResponse)
async def convert_mkv_to_mp4(
    file: UploadFile = File(...),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert MKV file to MP4 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "mkv")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, "mp4")
        
        # Convert MKV to MP4
        temp_output_path = VideoConversionService.mkv_to_mp4(input_path, quality)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="MKV file converted to MP4 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/avi-to-mp4", response_model=ConversionResponse)
async def convert_avi_to_mp4(
    file: UploadFile = File(...),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert AVI file to MP4 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "avi")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, "mp4")
        
        # Convert AVI to MP4
        temp_output_path = VideoConversionService.avi_to_mp4(input_path, quality)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="AVI file converted to MP4 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/mp4-to-mp3", response_model=ConversionResponse)
async def convert_mp4_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k"),
    filename: Optional[str] = Form(None)
):
    """Convert MP4 file to MP3 audio format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "mp4")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, "mp3")
        
        # Convert MP4 to MP3
        temp_output_path = VideoConversionService.mp4_to_mp3(input_path, bitrate)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="MP4 file converted to MP3 successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/convert-video-format", response_model=ConversionResponse)
async def convert_video_format(
    file: UploadFile = File(...),
    output_format: str = Form(...),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Convert video to any supported format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, output_format)
        
        # Convert video format
        temp_output_path = VideoConversionService.convert_video_format(input_path, output_format, quality)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message=f"Video converted to {output_format.upper()} successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/video-to-audio", response_model=ConversionResponse)
async def video_to_audio(
    file: UploadFile = File(...),
    output_format: str = Form("mp3"),
    filename: Optional[str] = Form(None)
):
    """Convert video to audio using moviepy (simple approach)."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, output_format)
        
        # Convert video to audio
        temp_output_path = VideoConversionService.video_to_audio(input_path, output_format)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message=f"Video converted to {output_format.upper()} audio successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/extract-audio", response_model=ConversionResponse)
async def extract_audio(
    file: UploadFile = File(...),
    output_format: str = Form("mp3"),
    bitrate: str = Form("192k"),
    filename: Optional[str] = Form(None)
):
    """Extract audio from video file with customizable bitrate."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename
        output_filename = _determine_output_filename(file.filename, filename, output_format)
        
        # Extract audio
        temp_output_path = VideoConversionService.extract_audio(input_path, output_format, bitrate)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message=f"Audio extracted to {output_format.upper()} successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/resize-video", response_model=ConversionResponse)
async def resize_video(
    file: UploadFile = File(...),
    width: int = Form(...),
    height: int = Form(...),
    quality: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Resize video to specified dimensions."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename. Standard is _resized.mp4 if no filename provided.
        # If user provides valid filename, use it.
        # If not, fall back to base + _resized.mp4
        
        if filename and filename.strip():
             output_filename = _determine_output_filename(file.filename, filename, "mp4")
        else:
             base_name = os.path.splitext(file.filename)[0]
             output_filename = f"{base_name}_resized.mp4"

        # Resize video
        temp_output_path = VideoConversionService.resize_video(input_path, width, height, quality)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message=f"Video resized to {width}x{height} successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/compress-video", response_model=ConversionResponse)
async def compress_video(
    file: UploadFile = File(...),
    compression_level: str = Form("medium"),
    filename: Optional[str] = Form(None)
):
    """Compress video file to reduce size."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Determine output filename. Standard is _compressed.mp4
        if filename and filename.strip():
            output_filename = _determine_output_filename(file.filename, filename, "mp4")
        else:
            base_name = os.path.splitext(file.filename)[0]
            output_filename = f"{base_name}_compressed.mp4"
            
        # Compress video
        temp_output_path = VideoConversionService.compress_video(input_path, compression_level)
        
        # Move/Rename
        final_output_path = os.path.join(settings.output_dir, output_filename)
        if os.path.abspath(temp_output_path) != os.path.abspath(final_output_path):
             if os.path.exists(final_output_path):
                 os.remove(final_output_path)
             shutil.move(temp_output_path, final_output_path)
        
        return ConversionResponse(
            success=True,
            message="Video compressed successfully",
            output_filename=output_filename,
            download_url=f"/api/v1/videoconversiontools/download/{output_filename}"
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/video-info")
async def get_video_info(file: UploadFile = File(...)):
    """Get video file information."""
    input_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Get video info
        video_info = VideoConversionService.get_video_info(input_path)
        
        return {
            "success": True,
            "message": "Video information retrieved successfully",
            "video_info": video_info
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
        if input_path:
            VideoConversionService.cleanup_temp_files(input_path)


@router.get("/supported-formats")
async def get_supported_formats():
    """Get list of supported input and output formats."""
    try:
        formats = VideoConversionService.get_supported_formats()
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
    
    file_path = os.path.join(settings.output_dir, filename)
    
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=file_path,
        filename=filename,
        media_type='application/octet-stream'
    )
