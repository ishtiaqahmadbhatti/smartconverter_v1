import pytest
import os
import tempfile
from unittest.mock import patch, MagicMock
from app.services.file_service import FileService
from app.services.conversion_service import ConversionService
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


class TestConversionService:
    """Test cases for ConversionService."""
    
    def test_pdf_to_word_success(self, tmp_path):
        """Test successful PDF to Word conversion (placeholder implementation)."""
        # Use a real temporary path so the function can write the output
        input_path = str(tmp_path / "input.pdf")
        output_path = str(tmp_path / "output.docx")
        
        with open(input_path, "w", encoding="utf-8") as f:
            f.write("dummy")
        
        with patch.object(FileService, 'get_output_path', return_value=output_path):
            result = ConversionService.pdf_to_word(input_path)
            assert result == output_path
    
    @patch('app.services.conversion_service.pytesseract')
    @patch('app.services.conversion_service.Image')
    def test_image_to_text_success(self, mock_image, mock_pytesseract):
        """Test successful image to text conversion."""
        # Mock image and OCR
        mock_img = MagicMock()
        mock_image.open.return_value = mock_img
        mock_pytesseract.image_to_string.return_value = "Extracted text"
        
        result = ConversionService.image_to_text("/path/to/image.png")
        assert result == "Extracted text"
        mock_pytesseract.image_to_string.assert_called_once_with(mock_img)
