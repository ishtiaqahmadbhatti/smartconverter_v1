import os
import tempfile
from typing import Optional, Dict, Any, List, Tuple
from pydub import AudioSegment
from pydub.utils import which
import soundfile as sf
import numpy as np
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService

# Configure ffmpeg path
ffmpeg_path = None
try:
    import imageio_ffmpeg
    ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()
    print(f"AudioConversionService: configured ffmpeg from imageio-ffmpeg at {ffmpeg_path}")
    
    # Configure pydub to use this ffmpeg
    if ffmpeg_path:
        AudioSegment.converter = ffmpeg_path
        
except ImportError:
    print("AudioConversionService: imageio-ffmpeg not found. Will rely on system PATH.")

# Helper to run ffmpeg command
import subprocess
def run_ffmpeg(args):
    """Run ffmpeg command with error handling."""
    exe = ffmpeg_path if ffmpeg_path else "ffmpeg"
    cmd = [exe] + args
    try:
        # Check if executable exists or is in path
        if not ffmpeg_path and not which("ffmpeg"):
             raise FileProcessingError("FFmpeg executable not found. Please install ffmpeg or imageio-ffmpeg.")
             
        process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if process.returncode != 0:
            raise FileProcessingError(f"FFmpeg command failed: {process.stderr}")
    except FileNotFoundError:
         raise FileProcessingError("FFmpeg executable not found (FileNotFound).")
    except Exception as e:
         raise FileProcessingError(f"FFmpeg execution error: {str(e)}")

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
            
            # Map quality/bitrate to ffmpeg args
            # ffmpeg -i input.wav -b:a 192k output.mp3
            args = [
                '-y',
                '-i', input_path,
                '-b:a', bitrate,
                output_path
            ]
            run_ffmpeg(args)
            
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
            
            # ffmpeg -i input.flac -b:a 192k output.mp3
            args = [
                '-y',
                '-i', input_path,
                '-b:a', bitrate,
                output_path
            ]
            run_ffmpeg(args)
            
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
            
            # Use subprocess to call ffmpeg directly
            # ffmpeg -i input.mp3 -ar 44100 -ac 2 output.wav
            args = [
                '-y', # Overwrite output
                '-i', input_path,
                '-ar', str(sample_rate),
                '-ac', str(channels),
                output_path
            ]
            
            run_ffmpeg(args)
            
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
            
            # Use subprocess to call ffmpeg directly
            args = [
                '-y',
                '-i', input_path,
                '-ar', str(sample_rate),
                '-ac', str(channels),
                output_path
            ]
            run_ffmpeg(args)
            
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
            
            # ffmpeg -i input.wav -compression_level 5 output.flac
            args = [
                '-y',
                '-i', input_path,
                '-compression_level', str(compression_level),
                output_path
            ]
            run_ffmpeg(args)
            
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
            
            # Build ffmpeg args
            # ffmpeg -y -i input ... output
            args = ['-y', '-i', input_path]
            
            # Format specific parameters
            fmt = output_format.lower()
            if fmt == "mp3":
                args.extend(['-b:a', bitrate])
            elif fmt == "flac":
                 args.extend(['-compression_level', '5'])
            elif fmt in ["aac", "m4a"]:
                 args.extend(['-c:a', 'aac', '-b:a', bitrate])
            elif fmt == "ogg":
                 args.extend(['-c:a', 'libvorbis', '-q:a', '5'])
            elif fmt == "wav":
                 # Default pcm_s16le is usually fine, or just verify format
                 pass
                 
            args.append(output_path)
            
            run_ffmpeg(args)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio format conversion failed: {str(e)}")
    
    @staticmethod
    def normalize_audio(input_path: str, target_dBFS: float = -20.0) -> str:
        """Normalize audio using ffmpeg loudnorm filter."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, "_normalized.wav")
            
            # Use ffmpeg loudnorm filter
            # ffmpeg -y -i input -af loudnorm=I=-20 output.wav
            args = [
                '-y',
                '-i', input_path,
                '-af', f'loudnorm=I={target_dBFS}',
                output_path
            ]
            run_ffmpeg(args)
            
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
            
            # ffmpeg -y -i input -ss start -to end output.wav
            args = [
                '-y',
                '-i', input_path,
                '-ss', str(start_time),
                '-to', str(end_time),
                output_path
            ]
            run_ffmpeg(args)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Audio trimming failed: {str(e)}")
    
    @staticmethod
    def get_audio_info(input_path: str) -> Dict[str, Any]:
        """Get audio file information using ffmpeg/ffprobe."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Try parsing ffmpeg output as fallback since we might lack ffprobe
            # ffmpeg -i input
            exe = ffmpeg_path if ffmpeg_path else "ffmpeg"
            cmd = [exe, '-i', input_path]
            
            # ffmpeg prints info to stderr
            try:
                 result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                 stderr = result.stderr
            except Exception as e:
                 raise FileProcessingError(f"Failed to run ffmpeg for info: {e}")

            # Simple regex parsing for basic info
            import re
            
            # Duration: 00:00:30.50, start: ...
            duration_match = re.search(r"Duration:\s+(\d+):(\d+):(\d+\.\d+)", stderr)
            duration_sec = 0.0
            if duration_match:
                h, m, s = map(float, duration_match.groups())
                duration_sec = h*3600 + m*60 + s
            
            # Stream #0:0: Audio: mp3, 44100 Hz, stereo, fltp, 128 kb/s
            audio_match = re.search(r"Stream.*Audio:\s+([^,]+),\s+(\d+)\s+Hz,\s+([^,]+),.*,\s+(\d+)\s+kb/s", stderr)
            
            if not duration_match and not audio_match:
                 # Fallback to pydub if we happen to have ffprobe or simple wav/raw reading
                 audio = AudioSegment.from_file(input_path)
                 return {
                    "duration": len(audio) / 1000.0,
                    "sample_rate": audio.frame_rate,
                    "channels": audio.channels,
                    "bit_depth": audio.sample_width * 8,
                    "bitrate": audio.frame_rate * audio.sample_width * audio.channels, # approx
                    "dBFS": audio.dBFS,
                    "max_dBFS": audio.max_dBFS,
                    "format": input_path.split('.')[-1].upper()
                }

            # Construct info from regex
            fmt = audio_match.group(1) if audio_match else "unknown"
            sample_rate = int(audio_match.group(2)) if audio_match else 0
            channels_str = audio_match.group(3) if audio_match else "unknown"
            channels = 2 if "stereo" in channels_str else (1 if "mono" in channels_str else 0)
            bitrate_kbps = int(audio_match.group(4)) if audio_match else 0
            
            return {
                "duration": duration_sec,
                "sample_rate": sample_rate,
                "channels": channels,
                "bit_depth": 16, # approximation
                "bitrate": bitrate_kbps * 1000,
                "dBFS": -20.0, # dummy value as we can't calculate without processing
                "max_dBFS": 0.0, # dummy
                "format": fmt.upper()
            }
            
        except Exception as e:
            raise FileProcessingError(f"Failed to get audio info: {str(e)}")
    
    @staticmethod
    def merge_audio_files(input_paths: List[str], output_path: str) -> str:
        """Merge multiple audio files into one using ffmpeg concat demuxer."""
        try:
            if not input_paths:
                raise FileProcessingError("No input files provided")
            
            # Create a temporary file list for ffmpeg
            # file 'path1'
            # file 'path2'
            list_path = os.path.join(os.path.dirname(output_path), "concat_list.txt")
            try:
                with open(list_path, 'w', encoding='utf-8') as f:
                    for path in input_paths:
                        # Escape single quotes
                        safe_path = path.replace("'", "'\\''") 
                        f.write(f"file '{safe_path}'\n")
                
                # ffmpeg -f concat -safe 0 -i list.txt -c copy output.wav
                # Re-encoding is safer if formats differ, but copy is faster
                # Let's re-encode to be safe and consistent with previous pydub behavior (which re-encodes)
                args = [
                    '-y',
                    '-f', 'concat',
                    '-safe', '0',
                    '-i', list_path,
                    '-c:a', 'pcm_s16le', # Force generic WAV encoding
                    output_path
                ]
                run_ffmpeg(args)
                
                return output_path
            finally:
                if os.path.exists(list_path):
                    os.remove(list_path)
            
        except Exception as e:
            raise FileProcessingError(f"Audio merging failed: {str(e)}")
    
    @staticmethod
    def split_audio(input_path: str, segment_duration: float) -> List[str]:
        """Split audio into segments of specified duration."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input audio file not found: {input_path}")
            
            # Use ffmpeg segment muxer
            # ffmpeg -i input.wav -f segment -segment_time 30 -c copy output_%03d.wav
            output_pattern = FileService.get_output_path(input_path, "_segment_%03d.wav")
            # We need to return the list of created files.
            # It's hard to predict exactly what filenames ffmpeg will create without listing dir.
            # But the pattern is predictable.
            
            args = [
                '-y',
                '-i', input_path,
                '-f', 'segment',
                '-segment_time', str(segment_duration),
                '-c', 'copy', # Copy codec for speed if possible
                '-reset_timestamps', '1',
                output_pattern
            ]
            run_ffmpeg(args)
            
            # Collect generated files
            output_dir = os.path.dirname(output_pattern)
            base_name_pattern = os.path.basename(output_pattern).replace("%03d", r"\d{3}")
            generated_files = []
            
            import re
            for f in os.listdir(output_dir):
                if re.match(base_name_pattern, f):
                    generated_files.append(os.path.join(output_dir, f))
            
            return sorted(generated_files)
            
        except Exception as e:
            raise FileProcessingError(f"Audio splitting failed: {str(e)}")
            
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
