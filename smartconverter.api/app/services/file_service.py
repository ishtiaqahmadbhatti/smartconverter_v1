import os
import re
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
        
        # if file_size > settings.max_file_size:

        if settings.max_file_size > 0 and file_size > settings.max_file_size:
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
        elif file_type == "jpg":
            allowed_types = [".jpg", ".jpeg"]
        elif file_type == "png":
            allowed_types = [".png"]
        elif file_type == "pdf":
            allowed_types = [".pdf"]
        elif file_type == "document":
            allowed_types = [
                ".pdf", ".docx", ".doc", ".txt", ".rtf", ".odt",
                ".html", ".htm"
            ]
        elif file_type == "xml":
            allowed_types = [".xml"]
        elif file_type == "markdown":
            allowed_types = [".md", ".markdown"]
        elif file_type == "office":
            allowed_types = [
                ".docx", ".doc", ".xlsx", ".xls", ".pptx", ".ppt", 
                ".odt", ".ods", ".odp"
            ]
        elif file_type == "subtitle":
            allowed_types = [
                ".srt", ".vtt"
            ]
        elif file_type == "epub":
            allowed_types = [".epub"]
        elif file_type == "mobi":
            allowed_types = [".mobi"]
        elif file_type == "azw":
            allowed_types = [".azw"]
        elif file_type == "azw3":
            allowed_types = [".azw3"]
        elif file_type == "fb2":
            allowed_types = [".fb2"]
        elif file_type == "fbz":
            allowed_types = [".fbz"]
        elif file_type == "mov":
            allowed_types = [".mov"]
        elif file_type == "mkv":
            allowed_types = [".mkv"]
        elif file_type == "avi":
            allowed_types = [".avi"]
        elif file_type == "mp4":
            allowed_types = [".mp4"]
        elif file_type == "oxps":
            allowed_types = [".oxps"]
        elif file_type == "ai":
            allowed_types = [".ai"]
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

    @staticmethod
    def generate_output_path_with_filename(
        filename: str,
        default_extension: str = ".pdf",
        max_base_length: int = 100
    ) -> Tuple[str, str]:
        """Generate a sanitized, unique output path for a given filename."""
        base_name, ext = os.path.splitext(filename or "")

        if not base_name:
            base_name = "merged_document"

        sanitized_base = re.sub(r"[^A-Za-z0-9._-]+", "_", base_name).strip("._")
        if not sanitized_base:
            sanitized_base = "merged_document"

        sanitized_base = sanitized_base[:max_base_length]

        extension = default_extension
        if ext and ext.lower() == default_extension.lower():
            extension = ext.lower()

        if not extension.startswith("."):
            extension = f".{extension}"

        output_dir = settings.output_dir
        os.makedirs(output_dir, exist_ok=True)

        candidate = f"{sanitized_base}{extension}"
        counter = 1
        while os.path.exists(os.path.join(output_dir, candidate)):
            candidate = f"{sanitized_base}_{counter}{extension}"
            counter += 1

        output_path = os.path.join(output_dir, candidate)
        return output_path, candidate
