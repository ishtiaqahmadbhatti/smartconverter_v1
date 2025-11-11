import os
import uuid
from typing import Optional, Tuple
from fastapi import UploadFile
from app.core.config import settings
from app.core.exceptions import FileSizeExceededError, UnsupportedFileTypeError


class FileService:
    """Service for handling file operations."""
    
    @staticmethod
    def validate_file(file: UploadFile, file_type: str = "general") -> None:
        """Validate uploaded file based on file type."""
        # Check file size
        file.file.seek(0, 2)  # Seek to end
        file_size = file.file.tell()
        file.file.seek(0)  # Reset to beginning
        
        if file_size > settings.max_file_size:
            raise FileSizeExceededError(
                f"File size {file_size} exceeds maximum allowed size {settings.max_file_size}"
            )
        
        # Define allowed types based on file_type parameter
        if file_type == "video":
            allowed_types = [
                ".mp4", ".mov", ".mkv", ".avi", ".wmv", ".flv", 
                ".webm", ".m4v", ".3gp", ".ogv"
            ]
        elif file_type == "audio":
            allowed_types = [
                ".mp3", ".wav", ".aac", ".flac", ".ogg", ".wma", 
                ".m4a", ".aiff", ".au"
            ]
        elif file_type == "image":
            allowed_types = [
                ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff", 
                ".webp", ".svg", ".ico"
            ]
        elif file_type == "document":
            allowed_types = [
                ".pdf", ".docx", ".doc", ".txt", ".rtf", ".odt"
            ]
        elif file_type == "office":
            allowed_types = [
                ".docx", ".doc", ".xlsx", ".xls", ".pptx", ".ppt", 
                ".odt", ".ods", ".odp"
            ]
        else:  # general/default
            allowed_types = [
                ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".bmp", 
                ".tiff", ".docx", ".mp4", ".mov", ".mkv", ".avi", 
                ".mp3", ".wav", ".aac", ".txt", ".json", ".xml", 
                ".csv", ".xlsx", ".xls", ".pptx", ".ppt"
            ]
        
        if file.filename:
            file_ext = os.path.splitext(file.filename)[1].lower()
            if file_ext not in allowed_types:
                raise UnsupportedFileTypeError(
                    f"File type {file_ext} is not supported for {file_type} conversion. Allowed types: {allowed_types}"
                )
    
    @staticmethod
    def save_uploaded_file(file: UploadFile) -> str:
        """Save uploaded file and return the file path."""
        # Generate unique filename to avoid conflicts
        file_ext = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = os.path.join(settings.upload_dir, unique_filename)
        
        with open(file_path, "wb") as f:
            content = file.file.read()
            f.write(content)
        
        return file_path
    
    @staticmethod
    def get_output_path(input_path: str, output_extension: str) -> str:
        """Generate output file path."""
        input_filename = os.path.basename(input_path)
        output_filename = os.path.splitext(input_filename)[0] + output_extension
        return os.path.join(settings.output_dir, output_filename)
    
    @staticmethod
    def cleanup_file(file_path: str) -> None:
        """Remove temporary file."""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
        except Exception:
            pass  # Ignore cleanup errors
