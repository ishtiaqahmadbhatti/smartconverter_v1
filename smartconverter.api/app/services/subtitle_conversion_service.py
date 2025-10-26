import os
import io
import csv
import pandas as pd
from typing import Optional, Dict, Any, List, Tuple
from datetime import timedelta
import pysrt
import webvtt
from googletrans import Translator
from deep_translator import GoogleTranslator
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService


class SubtitleConversionService:
    """Service for handling subtitle conversions and translations."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = {
        'SRT', 'VTT', 'CSV', 'XLSX', 'XLS', 'TXT'
    }
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = {
        'SRT', 'VTT', 'CSV', 'XLSX', 'XLS', 'TXT'
    }
    
    @staticmethod
    def translate_srt(input_path: str, target_language: str = 'en', source_language: str = 'auto') -> str:
        """Translate SRT subtitle file using AI translation."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input SRT file not found: {input_path}")
            
            # Load SRT file
            subs = pysrt.open(input_path)
            
            # Initialize translator
            translator = GoogleTranslator(source=source_language, target=target_language)
            
            # Translate each subtitle
            for sub in subs:
                try:
                    translated_text = translator.translate(sub.text)
                    sub.text = translated_text
                except Exception as e:
                    print(f"Warning: Failed to translate subtitle {sub.index}: {str(e)}")
                    continue
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f"_translated_{target_language}.srt")
            
            # Save translated SRT
            subs.save(output_path, encoding='utf-8')
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SRT translation failed: {str(e)}")
    
    @staticmethod
    def srt_to_csv(input_path: str) -> str:
        """Convert SRT subtitle file to CSV format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input SRT file not found: {input_path}")
            
            # Load SRT file
            subs = pysrt.open(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".csv")
            
            # Convert to CSV
            with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(['Index', 'Start Time', 'End Time', 'Duration', 'Text'])
                
                for sub in subs:
                    start_time = SubtitleConversionService._format_time(sub.start)
                    end_time = SubtitleConversionService._format_time(sub.end)
                    duration = SubtitleConversionService._format_time(sub.duration)
                    
                    writer.writerow([
                        sub.index,
                        start_time,
                        end_time,
                        duration,
                        sub.text.replace('\n', ' ')
                    ])
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SRT to CSV conversion failed: {str(e)}")
    
    @staticmethod
    def srt_to_excel(input_path: str, format_type: str = 'xlsx') -> str:
        """Convert SRT subtitle file to Excel format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input SRT file not found: {input_path}")
            
            # Load SRT file
            subs = pysrt.open(input_path)
            
            # Prepare data
            data = []
            for sub in subs:
                data.append({
                    'Index': sub.index,
                    'Start Time': SubtitleConversionService._format_time(sub.start),
                    'End Time': SubtitleConversionService._format_time(sub.end),
                    'Duration': SubtitleConversionService._format_time(sub.duration),
                    'Text': sub.text.replace('\n', ' ')
                })
            
            # Create DataFrame
            df = pd.DataFrame(data)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, f".{format_type}")
            
            # Save to Excel
            if format_type.lower() == 'xlsx':
                df.to_excel(output_path, index=False, engine='openpyxl')
            elif format_type.lower() == 'xls':
                df.to_excel(output_path, index=False, engine='xlwt')
            else:
                df.to_excel(output_path, index=False)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SRT to Excel conversion failed: {str(e)}")
    
    @staticmethod
    def srt_to_text(input_path: str) -> str:
        """Convert SRT subtitle file to plain text."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input SRT file not found: {input_path}")
            
            # Load SRT file
            subs = pysrt.open(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".txt")
            
            # Extract text
            text_content = []
            for sub in subs:
                text_content.append(sub.text)
            
            # Save text file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(text_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SRT to text conversion failed: {str(e)}")
    
    @staticmethod
    def srt_to_vtt(input_path: str) -> str:
        """Convert SRT subtitle file to VTT format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input SRT file not found: {input_path}")
            
            # Load SRT file
            subs = pysrt.open(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".vtt")
            
            # Convert to VTT
            vtt_content = ["WEBVTT", ""]
            
            for sub in subs:
                start_time = SubtitleConversionService._srt_time_to_vtt(sub.start)
                end_time = SubtitleConversionService._srt_time_to_vtt(sub.end)
                
                vtt_content.append(f"{start_time} --> {end_time}")
                vtt_content.append(sub.text)
                vtt_content.append("")
            
            # Save VTT file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(vtt_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SRT to VTT conversion failed: {str(e)}")
    
    @staticmethod
    def vtt_to_text(input_path: str) -> str:
        """Convert VTT subtitle file to plain text."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input VTT file not found: {input_path}")
            
            # Load VTT file
            vtt = webvtt.read(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".txt")
            
            # Extract text
            text_content = []
            for caption in vtt:
                text_content.append(caption.text)
            
            # Save text file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(text_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"VTT to text conversion failed: {str(e)}")
    
    @staticmethod
    def vtt_to_srt(input_path: str) -> str:
        """Convert VTT subtitle file to SRT format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input VTT file not found: {input_path}")
            
            # Load VTT file
            vtt = webvtt.read(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".srt")
            
            # Convert to SRT
            srt_content = []
            
            for i, caption in enumerate(vtt, 1):
                start_time = SubtitleConversionService._vtt_time_to_srt(caption.start)
                end_time = SubtitleConversionService._vtt_time_to_srt(caption.end)
                
                srt_content.append(str(i))
                srt_content.append(f"{start_time} --> {end_time}")
                srt_content.append(caption.text)
                srt_content.append("")
            
            # Save SRT file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(srt_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"VTT to SRT conversion failed: {str(e)}")
    
    @staticmethod
    def csv_to_srt(input_path: str) -> str:
        """Convert CSV subtitle file to SRT format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input CSV file not found: {input_path}")
            
            # Read CSV file
            df = pd.read_csv(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".srt")
            
            # Convert to SRT
            srt_content = []
            
            for i, row in df.iterrows():
                index = i + 1
                start_time = row.get('Start Time', row.get('start_time', ''))
                end_time = row.get('End Time', row.get('end_time', ''))
                text = row.get('Text', row.get('text', ''))
                
                srt_content.append(str(index))
                srt_content.append(f"{start_time} --> {end_time}")
                srt_content.append(str(text))
                srt_content.append("")
            
            # Save SRT file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(srt_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"CSV to SRT conversion failed: {str(e)}")
    
    @staticmethod
    def excel_to_srt(input_path: str) -> str:
        """Convert Excel subtitle file to SRT format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input Excel file not found: {input_path}")
            
            # Read Excel file
            df = pd.read_excel(input_path)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".srt")
            
            # Convert to SRT
            srt_content = []
            
            for i, row in df.iterrows():
                index = i + 1
                start_time = row.get('Start Time', row.get('start_time', ''))
                end_time = row.get('End Time', row.get('end_time', ''))
                text = row.get('Text', row.get('text', ''))
                
                srt_content.append(str(index))
                srt_content.append(f"{start_time} --> {end_time}")
                srt_content.append(str(text))
                srt_content.append("")
            
            # Save SRT file
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(srt_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Excel to SRT conversion failed: {str(e)}")
    
    @staticmethod
    def _format_time(timedelta_obj) -> str:
        """Format timedelta object to HH:MM:SS,mmm format."""
        total_seconds = int(timedelta_obj.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60
        milliseconds = int(timedelta_obj.microseconds / 1000)
        
        return f"{hours:02d}:{minutes:02d}:{seconds:02d},{milliseconds:03d}"
    
    @staticmethod
    def _srt_time_to_vtt(srt_time) -> str:
        """Convert SRT time format to VTT time format."""
        return str(srt_time).replace(',', '.')
    
    @staticmethod
    def _vtt_time_to_srt(vtt_time) -> str:
        """Convert VTT time format to SRT time format."""
        return vtt_time.replace('.', ',')
    
    @staticmethod
    def get_supported_languages() -> List[str]:
        """Get list of supported translation languages."""
        return [
            'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh', 'ar', 'hi',
            'th', 'vi', 'tr', 'pl', 'nl', 'sv', 'da', 'no', 'fi', 'cs', 'hu', 'ro',
            'bg', 'hr', 'sk', 'sl', 'et', 'lv', 'lt', 'el', 'he', 'fa', 'ur', 'bn',
            'ta', 'te', 'ml', 'kn', 'gu', 'pa', 'or', 'as', 'ne', 'si', 'my', 'km',
            'lo', 'ka', 'am', 'sw', 'zu', 'af', 'sq', 'az', 'be', 'bs', 'ca', 'cy',
            'eu', 'gl', 'is', 'mk', 'mt', 'sr', 'uk', 'uz', 'yi'
        ]
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get list of supported input and output formats."""
        return {
            "input_formats": list(SubtitleConversionService.SUPPORTED_INPUT_FORMATS),
            "output_formats": list(SubtitleConversionService.SUPPORTED_OUTPUT_FORMATS)
        }
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
