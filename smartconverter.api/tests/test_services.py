import pytest
import os
import tempfile
from unittest.mock import patch, MagicMock
from app.services.file_service import FileService

from app.core.exceptions import FileSizeExceededError, UnsupportedFileTypeError


class TestFileService:
    """Test cases for FileService."""
    
    def test_validate_file_size_exceeded(self):
        """Test file size validation."""
        # Mock file with size exceeding limit
        mock_file = MagicMock()
        mock_file.file.seek = MagicMock()
        mock_file.file.tell = MagicMock(return_value=100 * 1024 * 1024)  # 100MB
        mock_file.filename = "test.pdf"
        
        with pytest.raises(FileSizeExceededError):
            FileService.validate_file(mock_file)
    
    def test_validate_file_unsupported_type(self):
        """Test file type validation."""
        mock_file = MagicMock()
        mock_file.file.seek = MagicMock()
        mock_file.file.tell = MagicMock(return_value=1024)  # 1KB
        mock_file.filename = "test.txt"  # Unsupported type
        
        with pytest.raises(UnsupportedFileTypeError):
            FileService.validate_file(mock_file)
    
    def test_get_output_path(self):
        """Test output path generation."""
        input_path = "/path/to/input.pdf"
        output_path = FileService.get_output_path(input_path, ".docx")
        assert output_path.endswith(".docx")
        assert "input" in output_path



