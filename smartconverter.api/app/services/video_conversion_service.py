import os
import tempfile
from typing import Optional, Dict, Any, List, Tuple
try:
    import moviepy.editor as mp
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False
    mp = None
import ffmpeg
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService


class VideoConversionService:
    """Service for handling video conversions between various formats."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = {
        'MOV', 'MKV', 'AVI', 'MP4', 'WMV', 'FLV', 'WEBM', 'M4V', '3GP', 'OGV'
    }
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = {
        'MP4', 'MP3', 'AVI', 'MOV', 'MKV', 'WMV', 'FLV', 'WEBM', 'M4V', '3GP', 'OGV'
    }
    
    @staticmethod
    def mov_to_mp4(input_path: str, quality: str = "medium") -> str:
        """Convert MOV file to MP4 format."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MOV file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp4")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Set quality parameters
            quality_settings = VideoConversionService._get_quality_settings(quality)
            
            # Write MP4 file
            video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate=quality_settings['bitrate'],
                fps=quality_settings['fps'],
                preset=quality_settings['preset']
            )
            
            # Close video to free memory
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MOV to MP4 conversion failed: {str(e)}")
    
    @staticmethod
    def mkv_to_mp4(input_path: str, quality: str = "medium") -> str:
        """Convert MKV file to MP4 format."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MKV file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp4")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Set quality parameters
            quality_settings = VideoConversionService._get_quality_settings(quality)
            
            # Write MP4 file
            video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate=quality_settings['bitrate'],
                fps=quality_settings['fps'],
                preset=quality_settings['preset']
            )
            
            # Close video to free memory
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MKV to MP4 conversion failed: {str(e)}")
    
    @staticmethod
    def avi_to_mp4(input_path: str, quality: str = "medium") -> str:
        """Convert AVI file to MP4 format."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AVI file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp4")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Set quality parameters
            quality_settings = VideoConversionService._get_quality_settings(quality)
            
            # Write MP4 file
            video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate=quality_settings['bitrate'],
                fps=quality_settings['fps'],
                preset=quality_settings['preset']
            )
            
            # Close video to free memory
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"AVI to MP4 conversion failed: {str(e)}")
    
    @staticmethod
    def mp4_to_mp3(input_path: str, bitrate: str = "192k") -> str:
        """Convert MP4 file to MP3 audio format."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MP4 file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp3")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Extract audio
            audio = video.audio
            
            if audio is None:
                raise FileProcessingError("No audio track found in the video file")
            
            # Write MP3 file
            audio.write_audiofile(
                output_path,
                bitrate=bitrate,
                verbose=False,
                logger=None
            )
            
            # Close video and audio to free memory
            audio.close()
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MP4 to MP3 conversion failed: {str(e)}")
    
    @staticmethod
    def convert_video_format(input_path: str, output_format: str, quality: str = "medium") -> str:
        """Convert video to any supported format."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f".{output_format.lower()}")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Set quality parameters
            quality_settings = VideoConversionService._get_quality_settings(quality)
            
            # Determine codec based on output format
            codec_settings = VideoConversionService._get_codec_settings(output_format)
            
            # Write video file
            video.write_videofile(
                output_path,
                codec=codec_settings['video_codec'],
                audio_codec=codec_settings['audio_codec'],
                bitrate=quality_settings['bitrate'],
                fps=quality_settings['fps'],
                preset=quality_settings['preset']
            )
            
            # Close video to free memory
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Video format conversion failed: {str(e)}")
    
    @staticmethod
    def extract_audio(input_path: str, output_format: str = "mp3", bitrate: str = "192k") -> str:
        """Extract audio from video file."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f".{output_format.lower()}")
            
            # Load video using moviepy.editor (matches user's code pattern)
            video = mp.VideoFileClip(input_path)
            
            # Extract audio (matches user's code: audio = video.audio)
            audio = video.audio
            
            if audio is None:
                raise FileProcessingError("No audio track found in the video file")
            
            # Write audio file (matches user's code: audio.write_audiofile())
            audio.write_audiofile(
                output_path,
                bitrate=bitrate,
                verbose=False,
                logger=None
            )
            
            # Close video and audio to free memory
            audio.close()
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio extraction failed: {str(e)}")
    
    @staticmethod
    def video_to_audio(input_path: str, output_format: str = "mp3") -> str:
        """
        Convert video to audio using moviepy (simple approach matching user's code).
        This is a simplified wrapper around extract_audio that uses default settings.
        """
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f".{output_format.lower()}")
            
            # Load video (matching user's code: video = moviepy.editor.VideoFileClip(vid))
            video = mp.VideoFileClip(input_path)
            
            # Extract audio (matching user's code: audio = video.audio)
            audio = video.audio
            
            if audio is None:
                raise FileProcessingError("No audio track found in the video file")
            
            # Write audio file (matching user's code: audio.write_audiofile("audio.mp3"))
            audio.write_audiofile(output_path)
            
            # Close video and audio to free memory
            audio.close()
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Video to audio conversion failed: {str(e)}")
    
    @staticmethod
    def get_video_info(input_path: str) -> Dict[str, Any]:
        """Get video file information."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Get video information
            info = {
                "duration": video.duration,
                "fps": video.fps,
                "size": video.size,
                "width": video.w,
                "height": video.h,
                "has_audio": video.audio is not None,
                "audio_fps": video.audio.fps if video.audio else None,
                "audio_duration": video.audio.duration if video.audio else None
            }
            
            # Close video to free memory
            video.close()
            
            return info
            
        except Exception as e:
            raise FileProcessingError(f"Failed to get video info: {str(e)}")
    
    @staticmethod
    def resize_video(input_path: str, width: int, height: int, quality: str = "medium") -> str:
        """Resize video to specified dimensions."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, "_resized.mp4")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Resize video
            resized_video = video.resize((width, height))
            
            # Set quality parameters
            quality_settings = VideoConversionService._get_quality_settings(quality)
            
            # Write resized video
            resized_video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate=quality_settings['bitrate'],
                fps=quality_settings['fps'],
                preset=quality_settings['preset']
            )
            
            # Close videos to free memory
            resized_video.close()
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Video resize failed: {str(e)}")
    
    @staticmethod
    def compress_video(input_path: str, compression_level: str = "medium") -> str:
        """Compress video file to reduce size."""
        try:
            if not MOVIEPY_AVAILABLE:
                raise FileProcessingError("MoviePy is not available. Please install moviepy package.")
            
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input video file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, "_compressed.mp4")
            
            # Load video
            video = mp.VideoFileClip(input_path)
            
            # Set compression parameters
            compression_settings = VideoConversionService._get_compression_settings(compression_level)
            
            # Write compressed video
            video.write_videofile(
                output_path,
                codec='libx264',
                audio_codec='aac',
                bitrate=compression_settings['bitrate'],
                fps=compression_settings['fps'],
                preset=compression_settings['preset']
            )
            
            # Close video to free memory
            video.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Video compression failed: {str(e)}")
    
    @staticmethod
    def _get_quality_settings(quality: str) -> Dict[str, Any]:
        """Get quality settings based on quality level."""
        quality_presets = {
            "low": {
                "bitrate": "500k",
                "fps": 24,
                "preset": "ultrafast"
            },
            "medium": {
                "bitrate": "1000k",
                "fps": 30,
                "preset": "medium"
            },
            "high": {
                "bitrate": "2000k",
                "fps": 60,
                "preset": "slow"
            },
            "ultra": {
                "bitrate": "4000k",
                "fps": 60,
                "preset": "veryslow"
            }
        }
        
        return quality_presets.get(quality, quality_presets["medium"])
    
    @staticmethod
    def _get_codec_settings(output_format: str) -> Dict[str, str]:
        """Get codec settings based on output format."""
        codec_presets = {
            "mp4": {"video_codec": "libx264", "audio_codec": "aac"},
            "avi": {"video_codec": "libx264", "audio_codec": "mp3"},
            "mov": {"video_codec": "libx264", "audio_codec": "aac"},
            "mkv": {"video_codec": "libx264", "audio_codec": "aac"},
            "wmv": {"video_codec": "wmv2", "audio_codec": "wmav2"},
            "flv": {"video_codec": "flv", "audio_codec": "mp3"},
            "webm": {"video_codec": "libvpx", "audio_codec": "libvorbis"},
            "m4v": {"video_codec": "libx264", "audio_codec": "aac"},
            "3gp": {"video_codec": "libx264", "audio_codec": "aac"},
            "ogv": {"video_codec": "libtheora", "audio_codec": "libvorbis"}
        }
        
        return codec_presets.get(output_format.lower(), codec_presets["mp4"])
    
    @staticmethod
    def _get_compression_settings(compression_level: str) -> Dict[str, Any]:
        """Get compression settings based on compression level."""
        compression_presets = {
            "low": {
                "bitrate": "800k",
                "fps": 24,
                "preset": "fast"
            },
            "medium": {
                "bitrate": "500k",
                "fps": 24,
                "preset": "medium"
            },
            "high": {
                "bitrate": "300k",
                "fps": 24,
                "preset": "slow"
            },
            "ultra": {
                "bitrate": "200k",
                "fps": 24,
                "preset": "veryslow"
            }
        }
        
        return compression_presets.get(compression_level, compression_presets["medium"])
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get list of supported input and output formats."""
        return {
            "input_formats": list(VideoConversionService.SUPPORTED_INPUT_FORMATS),
            "output_formats": list(VideoConversionService.SUPPORTED_OUTPUT_FORMATS)
        }
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
