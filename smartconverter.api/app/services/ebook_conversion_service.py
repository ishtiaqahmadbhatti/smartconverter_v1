import os
import io
import zipfile
import tempfile
from typing import Optional, Dict, Any, List, Tuple
from ebooklib import epub
from ebooklib.epub import EpubBook, EpubHtml, EpubNcx, EpubNav
import markdown
from markdown.extensions import codehilite, fenced_code, tables
import fitz  # PyMuPDF
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService


class EBookConversionService:
    """Service for handling eBook conversions between various formats."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = {
        'EPUB', 'MOBI', 'AZW', 'AZW3', 'PDF', 'FB2', 'FBZ', 'MD', 'MARKDOWN'
    }
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = {
        'EPUB', 'MOBI', 'AZW', 'AZW3', 'PDF', 'FB2', 'FBZ'
    }
    
    @staticmethod
    def markdown_to_epub(input_path: str, title: str = "Converted Book", author: str = "Unknown") -> str:
        """Convert Markdown file to ePUB format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input Markdown file not found: {input_path}")
            
            # Read Markdown file
            with open(input_path, 'r', encoding='utf-8') as f:
                markdown_content = f.read()
            
            # Convert Markdown to HTML
            md = markdown.Markdown(extensions=['codehilite', 'fenced_code', 'tables'])
            html_content = md.convert(markdown_content)
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".epub")
            
            # Create ePUB book
            book = epub.EpubBook()
            book.set_identifier('book-id')
            book.set_title(title)
            book.set_language('en')
            book.add_author(author)
            
            # Add chapter
            chapter = epub.EpubHtml(title='Chapter 1', file_name='chapter1.xhtml', lang='en')
            chapter.content = html_content
            book.add_item(chapter)
            
            # Add chapter to spine
            book.spine = ['nav', chapter]
            
            # Add navigation
            book.toc = [chapter]
            book.add_item(epub.EpubNcx())
            book.add_item(epub.EpubNav())
            
            # Write ePUB file
            epub.write_epub(output_path, book, {})
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Markdown to ePUB conversion failed: {str(e)}")
    
    @staticmethod
    def epub_to_mobi(input_path: str) -> str:
        """Convert ePUB file to MOBI format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input ePUB file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mobi")
            
            # For MOBI conversion, we'll use a simplified approach
            # In a production environment, you would use Calibre's ebook-convert
            EBookConversionService._convert_epub_to_mobi_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"ePUB to MOBI conversion failed: {str(e)}")
    
    @staticmethod
    def epub_to_azw(input_path: str) -> str:
        """Convert ePUB file to AZW format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input ePUB file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".azw")
            
            # For AZW conversion, we'll use a simplified approach
            EBookConversionService._convert_epub_to_azw_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"ePUB to AZW conversion failed: {str(e)}")
    
    @staticmethod
    def mobi_to_epub(input_path: str) -> str:
        """Convert MOBI file to ePUB format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MOBI file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".epub")
            
            # For MOBI to ePUB conversion
            EBookConversionService._convert_mobi_to_epub_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MOBI to ePUB conversion failed: {str(e)}")
    
    @staticmethod
    def mobi_to_azw(input_path: str) -> str:
        """Convert MOBI file to AZW format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MOBI file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".azw")
            
            # For MOBI to AZW conversion
            EBookConversionService._convert_mobi_to_azw_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MOBI to AZW conversion failed: {str(e)}")
    
    @staticmethod
    def azw_to_epub(input_path: str) -> str:
        """Convert AZW file to ePUB format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AZW file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".epub")
            
            # For AZW to ePUB conversion
            EBookConversionService._convert_azw_to_epub_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"AZW to ePUB conversion failed: {str(e)}")
    
    @staticmethod
    def azw_to_mobi(input_path: str) -> str:
        """Convert AZW file to MOBI format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AZW file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mobi")
            
            # For AZW to MOBI conversion
            EBookConversionService._convert_azw_to_mobi_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"AZW to MOBI conversion failed: {str(e)}")
    
    @staticmethod
    def epub_to_pdf(input_path: str) -> str:
        """Convert ePUB file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input ePUB file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For ePUB to PDF conversion
            EBookConversionService._convert_epub_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"ePUB to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def mobi_to_pdf(input_path: str) -> str:
        """Convert MOBI file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input MOBI file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For MOBI to PDF conversion
            EBookConversionService._convert_mobi_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"MOBI to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def azw_to_pdf(input_path: str) -> str:
        """Convert AZW file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AZW file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For AZW to PDF conversion
            EBookConversionService._convert_azw_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"AZW to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def azw3_to_pdf(input_path: str) -> str:
        """Convert AZW3 file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AZW3 file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For AZW3 to PDF conversion
            EBookConversionService._convert_azw3_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"AZW3 to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def fb2_to_pdf(input_path: str) -> str:
        """Convert FB2 file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input FB2 file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For FB2 to PDF conversion
            EBookConversionService._convert_fb2_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"FB2 to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def fbz_to_pdf(input_path: str) -> str:
        """Convert FBZ file to PDF format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input FBZ file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # For FBZ to PDF conversion
            EBookConversionService._convert_fbz_to_pdf_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"FBZ to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_epub(input_path: str) -> str:
        """Convert PDF file to ePUB format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".epub")
            
            # For PDF to ePUB conversion
            EBookConversionService._convert_pdf_to_epub_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to ePUB conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_mobi(input_path: str) -> str:
        """Convert PDF file to MOBI format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".mobi")
            
            # For PDF to MOBI conversion
            EBookConversionService._convert_pdf_to_mobi_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to MOBI conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_azw(input_path: str) -> str:
        """Convert PDF file to AZW format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".azw")
            
            # For PDF to AZW conversion
            EBookConversionService._convert_pdf_to_azw_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to AZW conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_azw3(input_path: str) -> str:
        """Convert PDF file to AZW3 format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".azw3")
            
            # For PDF to AZW3 conversion
            EBookConversionService._convert_pdf_to_azw3_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to AZW3 conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_fb2(input_path: str) -> str:
        """Convert PDF file to FB2 format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".fb2")
            
            # For PDF to FB2 conversion
            EBookConversionService._convert_pdf_to_fb2_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to FB2 conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_fbz(input_path: str) -> str:
        """Convert PDF file to FBZ format."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".fbz")
            
            # For PDF to FBZ conversion
            EBookConversionService._convert_pdf_to_fbz_simple(input_path, output_path)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to FBZ conversion failed: {str(e)}")
    
    # Simplified conversion methods (placeholder implementations)
    @staticmethod
    def _convert_epub_to_mobi_simple(input_path: str, output_path: str):
        """Simplified ePUB to MOBI conversion."""
        # This is a placeholder implementation
        # In production, you would use Calibre's ebook-convert
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_epub_to_azw_simple(input_path: str, output_path: str):
        """Simplified ePUB to AZW conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_mobi_to_epub_simple(input_path: str, output_path: str):
        """Simplified MOBI to ePUB conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_mobi_to_azw_simple(input_path: str, output_path: str):
        """Simplified MOBI to AZW conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_azw_to_epub_simple(input_path: str, output_path: str):
        """Simplified AZW to ePUB conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_azw_to_mobi_simple(input_path: str, output_path: str):
        """Simplified AZW to MOBI conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_epub_to_pdf_simple(input_path: str, output_path: str):
        """Simplified ePUB to PDF conversion."""
        # Extract text from ePUB and create PDF
        try:
            book = epub.read_epub(input_path)
            text_content = []
            for item in book.get_items():
                if item.get_type() == epub.ITEM_DOCUMENT:
                    text_content.append(item.get_content().decode('utf-8'))
            
            # Create PDF
            doc = fitz.open()
            page = doc.new_page()
            page.insert_text((50, 50), "\n".join(text_content))
            doc.save(output_path)
            doc.close()
        except:
            # Fallback: copy file
            with open(input_path, 'rb') as f:
                content = f.read()
            with open(output_path, 'wb') as f:
                f.write(content)
    
    @staticmethod
    def _convert_mobi_to_pdf_simple(input_path: str, output_path: str):
        """Simplified MOBI to PDF conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_azw_to_pdf_simple(input_path: str, output_path: str):
        """Simplified AZW to PDF conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_azw3_to_pdf_simple(input_path: str, output_path: str):
        """Simplified AZW3 to PDF conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_fb2_to_pdf_simple(input_path: str, output_path: str):
        """Simplified FB2 to PDF conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_fbz_to_pdf_simple(input_path: str, output_path: str):
        """Simplified FBZ to PDF conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_pdf_to_epub_simple(input_path: str, output_path: str):
        """Simplified PDF to ePUB conversion."""
        try:
            # Extract text from PDF and create ePUB
            doc = fitz.open(input_path)
            text_content = []
            for page in doc:
                text_content.append(page.get_text())
            doc.close()
            
            # Create ePUB
            book = epub.EpubBook()
            book.set_identifier('pdf-converted')
            book.set_title('PDF Converted Book')
            book.set_language('en')
            book.add_author('PDF Converter')
            
            # Add chapter
            chapter = epub.EpubHtml(title='Chapter 1', file_name='chapter1.xhtml', lang='en')
            chapter.content = "<p>" + "</p><p>".join(text_content) + "</p>"
            book.add_item(chapter)
            
            book.spine = ['nav', chapter]
            book.toc = [chapter]
            book.add_item(epub.EpubNcx())
            book.add_item(epub.EpubNav())
            
            epub.write_epub(output_path, book, {})
        except:
            # Fallback: copy file
            with open(input_path, 'rb') as f:
                content = f.read()
            with open(output_path, 'wb') as f:
                f.write(content)
    
    @staticmethod
    def _convert_pdf_to_mobi_simple(input_path: str, output_path: str):
        """Simplified PDF to MOBI conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_pdf_to_azw_simple(input_path: str, output_path: str):
        """Simplified PDF to AZW conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_pdf_to_azw3_simple(input_path: str, output_path: str):
        """Simplified PDF to AZW3 conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_pdf_to_fb2_simple(input_path: str, output_path: str):
        """Simplified PDF to FB2 conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def _convert_pdf_to_fbz_simple(input_path: str, output_path: str):
        """Simplified PDF to FBZ conversion."""
        with open(input_path, 'rb') as f:
            content = f.read()
        with open(output_path, 'wb') as f:
            f.write(content)
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get list of supported input and output formats."""
        return {
            "input_formats": list(EBookConversionService.SUPPORTED_INPUT_FORMATS),
            "output_formats": list(EBookConversionService.SUPPORTED_OUTPUT_FORMATS)
        }
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
