import os
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends, Form, Query
from fastapi.responses import FileResponse
from typing import Optional
from app.models.schemas import ConversionResponse
from app.services.video_conversion_service import VideoConversionService
from app.core.exceptions import (
    FileProcessingError, 
    UnsupportedFileTypeError, 
    FileSizeExceededError,
    create_error_response
)
from app.services.file_service import FileService
from app.api.v1.dependencies import get_current_active_user
from app.models.user import User

router = APIRouter()


@router.post("/mov-to-mp4", response_model=ConversionResponse)
async def convert_mov_to_mp4(
    file: UploadFile = File(...),
    quality: str = Form("medium"),
    current_user: User = Depends(get_current_active_user)
):
    """Convert MOV file to MP4 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MOV to MP4
        output_path = VideoConversionService.mov_to_mp4(input_path, quality)
        
        return ConversionResponse(
            success=True,
            message="MOV file converted to MP4 successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/mkv-to-mp4", response_model=ConversionResponse)
async def convert_mkv_to_mp4(
    file: UploadFile = File(...),
    quality: str = Form("medium")
):
    """Convert MKV file to MP4 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MKV to MP4
        output_path = VideoConversionService.mkv_to_mp4(input_path, quality)
        
        return ConversionResponse(
            success=True,
            message="MKV file converted to MP4 successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/avi-to-mp4", response_model=ConversionResponse)
async def convert_avi_to_mp4(
    file: UploadFile = File(...),
    quality: str = Form("medium")
):
    """Convert AVI file to MP4 format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert AVI to MP4
        output_path = VideoConversionService.avi_to_mp4(input_path, quality)
        
        return ConversionResponse(
            success=True,
            message="AVI file converted to MP4 successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/mp4-to-mp3", response_model=ConversionResponse)
async def convert_mp4_to_mp3(
    file: UploadFile = File(...),
    bitrate: str = Form("192k")
):
    """Convert MP4 file to MP3 audio format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert MP4 to MP3
        output_path = VideoConversionService.mp4_to_mp3(input_path, bitrate)
        
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/convert-video-format", response_model=ConversionResponse)
async def convert_video_format(
    file: UploadFile = File(...),
    output_format: str = Form(...),
    quality: str = Form("medium")
):
    """Convert video to any supported format."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert video format
        output_path = VideoConversionService.convert_video_format(input_path, output_format, quality)
        
        return ConversionResponse(
            success=True,
            message=f"Video converted to {output_format.upper()} successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/video-to-audio", response_model=ConversionResponse)
async def video_to_audio(
    file: UploadFile = File(...),
    output_format: str = Form("mp3")
):
    """Convert video to audio using moviepy (simple approach)."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Convert video to audio
        output_path = VideoConversionService.video_to_audio(input_path, output_format)
        
        return ConversionResponse(
            success=True,
            message=f"Video converted to {output_format.upper()} audio successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/extract-audio", response_model=ConversionResponse)
async def extract_audio(
    file: UploadFile = File(...),
    output_format: str = Form("mp3"),
    bitrate: str = Form("192k")
):
    """Extract audio from video file with customizable bitrate."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Extract audio
        output_path = VideoConversionService.extract_audio(input_path, output_format, bitrate)
        
        return ConversionResponse(
            success=True,
            message=f"Audio extracted to {output_format.upper()} successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/resize-video", response_model=ConversionResponse)
async def resize_video(
    file: UploadFile = File(...),
    width: int = Form(...),
    height: int = Form(...),
    quality: str = Form("medium")
):
    """Resize video to specified dimensions."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Resize video
        output_path = VideoConversionService.resize_video(input_path, width, height, quality)
        
        return ConversionResponse(
            success=True,
            message=f"Video resized to {width}x{height} successfully",
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
            VideoConversionService.cleanup_temp_files(input_path)


@router.post("/compress-video", response_model=ConversionResponse)
async def compress_video(
    file: UploadFile = File(...),
    compression_level: str = Form("medium")
):
    """Compress video file to reduce size."""
    input_path = None
    output_path = None
    
    try:
        # Validate file
        FileService.validate_file(file, "video")
        
        # Save uploaded file
        input_path = FileService.save_uploaded_file(file)
        
        # Compress video
        output_path = VideoConversionService.compress_video(input_path, compression_level)
        
        return ConversionResponse(
            success=True,
            message="Video compressed successfully",
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
        # Cleanup temporary files
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
