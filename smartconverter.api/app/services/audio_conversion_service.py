import os
import tempfile
from typing import Optional, Dict, Any, List, Tuple
from pydub import AudioSegment
from pydub.utils import which
import soundfile as sf
import numpy as np
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService


class AudioConversionService:
    """Service for handling audio conversions between various formats."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = {
        'MP4', 'WAV', 'FLAC', 'MP3', 'AAC', 'OGG', 'M4A', 'WMA', 'AIFF', 'AU'
    }
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = {
        'MP3', 'WAV', 'FLAC', 'AAC', 'OGG', 'M4A', 'WMA', 'AIFF', 'AU'
    }
    
    @staticmethod
    def mp4_to_mp3(input_path: str, bitrate: str = "192k", quality: str = "medium") -> str:
        """
        Convert MP4 file to MP3 format.
        
        Note: This method delegates to VideoConversionService.mp4_to_mp3() to avoid
        code duplication (DRY principle), as extracting audio from video files is
        better handled by MoviePy library.
        """
        try:
            # Import here to avoid circular dependency
            from app.services.video_conversion_service import VideoConversionService
            
            # Delegate to VideoConversionService which uses MoviePy (better for video files)
            # quality parameter is ignored here as VideoConversionService doesn't use it
            return VideoConversionService.mp4_to_mp3(input_path, bitrate)
            
        except Exception as e:
            raise FileProcessingError(f"MP4 to MP3 conversion failed: {str(e)}")
    
    @staticmethod
    def wav_to_mp3(input_path: str, bitrate: str = "192k", quality: str = "medium") -> str:
        """Convert WAV file to MP3 format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input WAV file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp3")
            
            # Load WAV file
            audio = AudioSegment.from_wav(input_path)
            
            # Set quality parameters
            quality_settings = AudioConversionService._get_quality_settings(quality)
            
            # Export to MP3
            audio.export(
                output_path,
                format="mp3",
                bitrate=bitrate,
                parameters=quality_settings['parameters']
            )
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"WAV to MP3 conversion failed: {str(e)}")
    
    @staticmethod
    def flac_to_mp3(input_path: str, bitrate: str = "192k", quality: str = "medium") -> str:
        """Convert FLAC file to MP3 format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input FLAC file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mp3")
            
            # Load FLAC file
            audio = AudioSegment.from_file(input_path, format="flac")
            
            # Set quality parameters
            quality_settings = AudioConversionService._get_quality_settings(quality)
            
            # Export to MP3
            audio.export(
                output_path,
                format="mp3",
                bitrate=bitrate,
                parameters=quality_settings['parameters']
            )
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"FLAC to MP3 conversion failed: {str(e)}")
    
    @staticmethod
    def mp3_to_wav(input_path: str, sample_rate: int = 44100, channels: int = 2) -> str:
        """Convert MP3 file to WAV format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MP3 file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".wav")
            
            # Load MP3 file
            audio = AudioSegment.from_mp3(input_path)
            
            # Set sample rate and channels
            audio = audio.set_frame_rate(sample_rate)
            if channels == 1:
                audio = audio.set_channels(1)
            elif channels == 2:
                audio = audio.set_channels(2)
            
            # Export to WAV
            audio.export(output_path, format="wav")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MP3 to WAV conversion failed: {str(e)}")
    
    @staticmethod
    def flac_to_wav(input_path: str, sample_rate: int = 44100, channels: int = 2) -> str:
        """Convert FLAC file to WAV format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input FLAC file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".wav")
            
            # Load FLAC file
            audio = AudioSegment.from_file(input_path, format="flac")
            
            # Set sample rate and channels
            audio = audio.set_frame_rate(sample_rate)
            if channels == 1:
                audio = audio.set_channels(1)
            elif channels == 2:
                audio = audio.set_channels(2)
            
            # Export to WAV
            audio.export(output_path, format="wav")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"FLAC to WAV conversion failed: {str(e)}")
    
    @staticmethod
    def wav_to_flac(input_path: str, compression_level: int = 5) -> str:
        """Convert WAV file to FLAC format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input WAV file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".flac")
            
            # Load WAV file
            audio = AudioSegment.from_wav(input_path)
            
            # Export to FLAC with compression level
            audio.export(
                output_path,
                format="flac",
                parameters=["-compression_level", str(compression_level)]
            )
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"WAV to FLAC conversion failed: {str(e)}")
    
    @staticmethod
    def convert_audio_format(input_path: str, output_format: str, bitrate: str = "192k", quality: str = "medium") -> str:
        """Convert audio to any supported format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f".{output_format.lower()}")
            
            # Load audio file
            audio = AudioSegment.from_file(input_path)
            
            # Set quality parameters
            quality_settings = AudioConversionService._get_quality_settings(quality)
            
            # Export to target format
            if output_format.lower() == "wav":
                audio.export(output_path, format="wav")
            elif output_format.lower() == "flac":
                audio.export(
                    output_path,
                    format="flac",
                    parameters=["-compression_level", "5"]
                )
            else:
                audio.export(
                    output_path,
                    format=output_format.lower(),
                    bitrate=bitrate,
                    parameters=quality_settings['parameters']
                )
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio format conversion failed: {str(e)}")
    
    @staticmethod
    def normalize_audio(input_path: str, target_dBFS: float = -20.0) -> str:
        """Normalize audio to target dBFS level."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, "_normalized.wav")
            
            # Load audio file
            audio = AudioSegment.from_file(input_path)
            
            # Normalize audio
            normalized_audio = audio.apply_gain(target_dBFS - audio.dBFS)
            
            # Export normalized audio
            normalized_audio.export(output_path, format="wav")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio normalization failed: {str(e)}")
    
    @staticmethod
    def trim_audio(input_path: str, start_time: float, end_time: float) -> str:
        """Trim audio to specified time range."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, "_trimmed.wav")
            
            # Load audio file
            audio = AudioSegment.from_file(input_path)
            
            # Convert time to milliseconds
            start_ms = int(start_time * 1000)
            end_ms = int(end_time * 1000)
            
            # Trim audio
            trimmed_audio = audio[start_ms:end_ms]
            
            # Export trimmed audio
            trimmed_audio.export(output_path, format="wav")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio trimming failed: {str(e)}")
    
    @staticmethod
    def get_audio_info(input_path: str) -> Dict[str, Any]:
        """Get audio file information."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Load audio file
            audio = AudioSegment.from_file(input_path)
            
            # Get audio information
            info = {
                "duration": len(audio) / 1000.0,  # Duration in seconds
                "sample_rate": audio.frame_rate,
                "channels": audio.channels,
                "bit_depth": audio.sample_width * 8,
                "bitrate": audio.frame_rate * audio.sample_width * audio.channels,
                "dBFS": audio.dBFS,
                "max_dBFS": audio.max_dBFS,
                "format": input_path.split('.')[-1].upper()
            }
            
            return info
            
        except Exception as e:
            raise FileProcessingError(f"Failed to get audio info: {str(e)}")
    
    @staticmethod
    def merge_audio_files(input_paths: List[str], output_path: str) -> str:
        """Merge multiple audio files into one."""
        try:
            if not input_paths:
                raise FileProcessingError("No input files provided")
            
            # Load first audio file
            merged_audio = AudioSegment.from_file(input_paths[0])
            
            # Merge with other files
            for path in input_paths[1:]:
                if os.path.exists(path):
                    audio = AudioSegment.from_file(path)
                    merged_audio += audio
            
            # Export merged audio
            merged_audio.export(output_path, format="wav")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio merging failed: {str(e)}")
    
    @staticmethod
    def split_audio(input_path: str, segment_duration: float) -> List[str]:
        """Split audio into segments of specified duration."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Load audio file
            audio = AudioSegment.from_file(input_path)
            
            # Calculate segment duration in milliseconds
            segment_ms = int(segment_duration * 1000)
            
            # Split audio into segments
            output_paths = []
            for i in range(0, len(audio), segment_ms):
                segment = audio[i:i + segment_ms]
                segment_path = FileService.get_output_path(input_path, f"_segment_{i//segment_ms + 1}.wav")
                segment.export(segment_path, format="wav")
                output_paths.append(segment_path)
            
            return output_paths
            
        except Exception as e:
            raise FileProcessingError(f"Audio splitting failed: {str(e)}")
    
    @staticmethod
    def _get_quality_settings(quality: str) -> Dict[str, Any]:
        """Get quality settings based on quality level."""
        quality_presets = {
            "low": {
                "parameters": ["-q:a", "9"]
            },
            "medium": {
                "parameters": ["-q:a", "5"]
            },
            "high": {
                "parameters": ["-q:a", "2"]
            },
            "ultra": {
                "parameters": ["-q:a", "0"]
            }
        }
        
        return quality_presets.get(quality, quality_presets["medium"])
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get list of supported input and output formats."""
        return {
            "input_formats": list(AudioConversionService.SUPPORTED_INPUT_FORMATS),
            "output_formats": list(AudioConversionService.SUPPORTED_OUTPUT_FORMATS)
        }
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
