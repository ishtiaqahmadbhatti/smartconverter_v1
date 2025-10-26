import os
import json
import csv
import tempfile
from typing import List, Dict, Any, Optional, Union
from pathlib import Path
import fitz  # PyMuPDF
import pandas as pd
from PIL import Image
import markdown
from docx import Document
from pptx import Presentation
import openpyxl
from openpyxl import Workbook
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image as RLImage
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
try:
    from weasyprint import HTML, CSS
    from weasyprint.text.fonts import FontConfiguration
    WEASYPRINT_AVAILABLE = True
except (ImportError, OSError):
    WEASYPRINT_AVAILABLE = False
    HTML = None
    CSS = None
    FontConfiguration = None
try:
    import cairosvg
    CAIROSVG_AVAILABLE = True
except ImportError:
    CAIROSVG_AVAILABLE = False
from io import BytesIO
import base64
from app.core.exceptions import FileProcessingError


class PDFConversionService:
    """Service for comprehensive PDF conversion operations."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = [
        "PDF", "HTML", "DOCX", "PPTX", "OXPS", "JPG", "JPEG", "PNG", 
        "MD", "XLSX", "XLS", "ODS", "CSV", "TXT"
    ]
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = [
        "PDF", "JSON", "MD", "CSV", "XLSX", "XPS", "JPG", "PNG", 
        "TIFF", "SVG", "HTML", "TXT", "DOCX"
    ]
    
    @staticmethod
    def pdf_to_json(pdf_path: str, output_path: str) -> str:
        """Convert PDF to JSON format with structured data extraction."""
        try:
            doc = fitz.open(pdf_path)
            pages_data = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                
                # Extract text
                text = page.get_text()
                
                # Extract images
                images = []
                image_list = page.get_images()
                for img_index, img in enumerate(image_list):
                    xref = img[0]
                    pix = fitz.Pixmap(doc, xref)
                    if pix.n - pix.alpha < 4:  # GRAY or RGB
                        img_data = pix.tobytes("png")
                        images.append({
                            "index": img_index,
                            "format": "png",
                            "data": base64.b64encode(img_data).decode()
                        })
                    pix = None
                
                # Extract annotations
                annotations = []
                for annot in page.annots():
                    annotations.append({
                        "type": annot.type[1],
                        "content": annot.content,
                        "rect": list(annot.rect)
                    })
                
                # Extract tables (basic)
                tables = []
                # This is a simplified table extraction
                # In production, you'd want to use more sophisticated table detection
                
                page_data = {
                    "page_number": page_num + 1,
                    "text": text,
                    "images": images,
                    "annotations": annotations,
                    "tables": tables,
                    "dimensions": {
                        "width": page.rect.width,
                        "height": page.rect.height
                    }
                }
                pages_data.append(page_data)
            
            doc.close()
            
            # Create structured JSON
            pdf_data = {
                "document_info": {
                    "total_pages": len(pages_data),
                    "title": doc.metadata.get("title", ""),
                    "author": doc.metadata.get("author", ""),
                    "subject": doc.metadata.get("subject", ""),
                    "creator": doc.metadata.get("creator", ""),
                    "producer": doc.metadata.get("producer", ""),
                    "creation_date": doc.metadata.get("creationDate", ""),
                    "modification_date": doc.metadata.get("modDate", "")
                },
                "pages": pages_data
            }
            
            # Save JSON
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(pdf_data, f, indent=2, ensure_ascii=False)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to JSON: {str(e)}")
    
    @staticmethod
    def pdf_to_markdown(pdf_path: str, output_path: str) -> str:
        """Convert PDF to Markdown format."""
        try:
            doc = fitz.open(pdf_path)
            markdown_content = []
            
            # Add document metadata
            metadata = doc.metadata
            if metadata.get("title"):
                markdown_content.append(f"# {metadata['title']}\n")
            if metadata.get("author"):
                markdown_content.append(f"**Author:** {metadata['author']}\n")
            if metadata.get("subject"):
                markdown_content.append(f"**Subject:** {metadata['subject']}\n")
            markdown_content.append("---\n")
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                text = page.get_text()
                
                if text.strip():
                    markdown_content.append(f"## Page {page_num + 1}\n")
                    markdown_content.append(text)
                    markdown_content.append("\n---\n")
            
            doc.close()
            
            # Save markdown
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(markdown_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to Markdown: {str(e)}")
    
    @staticmethod
    def pdf_to_csv(pdf_path: str, output_path: str) -> str:
        """Convert PDF to CSV format (extract tabular data)."""
        try:
            doc = fitz.open(pdf_path)
            all_tables = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                
                # Extract tables using PyMuPDF's table detection
                tables = page.find_tables()
                for table in tables:
                    table_data = table.extract()
                    if table_data:
                        all_tables.extend(table_data)
            
            doc.close()
            
            # Save as CSV
            if all_tables:
                with open(output_path, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerows(all_tables)
            else:
                # If no tables found, create a simple text-based CSV
                with open(output_path, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(['Page', 'Content'])
                    doc = fitz.open(pdf_path)
                    for page_num in range(len(doc)):
                        page = doc.load_page(page_num)
                        text = page.get_text()
                        if text.strip():
                            writer.writerow([page_num + 1, text.strip()])
                    doc.close()
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to CSV: {str(e)}")
    
    @staticmethod
    def pdf_to_excel(pdf_path: str, output_path: str) -> str:
        """Convert PDF to Excel format."""
        try:
            doc = fitz.open(pdf_path)
            workbook = Workbook()
            workbook.remove(workbook.active)  # Remove default sheet
            
            sheet_num = 1
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                
                # Create a new sheet for each page
                ws = workbook.create_sheet(title=f"Page_{page_num + 1}")
                
                # Extract tables
                tables = page.find_tables()
                row_offset = 1
                
                for table in tables:
                    table_data = table.extract()
                    if table_data:
                        for row_idx, row in enumerate(table_data):
                            for col_idx, cell in enumerate(row):
                                ws.cell(row=row_offset + row_idx, column=col_idx + 1, value=cell)
                        row_offset += len(table_data) + 1  # Add spacing between tables
                
                # If no tables, add text content
                if not tables:
                    text = page.get_text()
                    lines = text.split('\n')
                    for row_idx, line in enumerate(lines[:100]):  # Limit to 100 lines
                        ws.cell(row=row_idx + 1, column=1, value=line)
                
                sheet_num += 1
            
            doc.close()
            workbook.save(output_path)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to Excel: {str(e)}")
    
    @staticmethod
    def html_to_pdf(html_path: str, output_path: str) -> str:
        """Convert HTML to PDF."""
        try:
            with open(html_path, 'r', encoding='utf-8') as f:
                html_content = f.read()
            
            if not WEASYPRINT_AVAILABLE:
                # Fallback to reportlab for basic HTML to PDF conversion
                from reportlab.lib.styles import getSampleStyleSheet
                from reportlab.platypus import SimpleDocTemplate, Paragraph
                from reportlab.lib.pagesizes import letter
                
                # Simple HTML to text conversion for reportlab
                import re
                text_content = re.sub(r'<[^>]+>', '', html_content)
                
                doc = SimpleDocTemplate(output_path, pagesize=letter)
                styles = getSampleStyleSheet()
                story = []
                
                # Split content into paragraphs
                paragraphs = text_content.split('\n\n')
                for para in paragraphs:
                    if para.strip():
                        story.append(Paragraph(para.strip(), styles['Normal']))
                
                doc.build(story)
            else:
                # Use WeasyPrint for proper HTML to PDF conversion
                font_config = FontConfiguration()
                HTML(string=html_content).write_pdf(output_path, font_config=font_config)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting HTML to PDF: {str(e)}")
    
    @staticmethod
    def word_to_pdf(docx_path: str, output_path: str) -> str:
        """Convert Word document to PDF."""
        try:
            # This is a simplified conversion
            # In production, you might want to use python-docx2pdf or other libraries
            doc = Document(docx_path)
            
            # Create PDF using reportlab
            doc_pdf = SimpleDocTemplate(output_path, pagesize=A4)
            styles = getSampleStyleSheet()
            story = []
            
            for paragraph in doc.paragraphs:
                if paragraph.text.strip():
                    p = Paragraph(paragraph.text, styles['Normal'])
                    story.append(p)
                    story.append(Spacer(1, 12))
            
            doc_pdf.build(story)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting Word to PDF: {str(e)}")
    
    @staticmethod
    def powerpoint_to_pdf(pptx_path: str, output_path: str) -> str:
        """Convert PowerPoint to PDF."""
        try:
            prs = Presentation(pptx_path)
            
            # Create PDF using reportlab
            doc_pdf = SimpleDocTemplate(output_path, pagesize=A4)
            styles = getSampleStyleSheet()
            story = []
            
            for slide_num, slide in enumerate(prs.slides):
                story.append(Paragraph(f"Slide {slide_num + 1}", styles['Heading1']))
                story.append(Spacer(1, 12))
                
                for shape in slide.shapes:
                    if hasattr(shape, "text") and shape.text.strip():
                        story.append(Paragraph(shape.text, styles['Normal']))
                        story.append(Spacer(1, 6))
                
                story.append(Spacer(1, 20))
            
            doc_pdf.build(story)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PowerPoint to PDF: {str(e)}")
    
    @staticmethod
    def oxps_to_pdf(oxps_path: str, output_path: str) -> str:
        """Convert OXPS to PDF."""
        try:
            # OXPS is essentially XPS format
            # This is a simplified conversion - in production you'd need specialized libraries
            raise FileProcessingError("OXPS to PDF conversion requires specialized libraries not available in standard Python packages")
            
        except Exception as e:
            raise FileProcessingError(f"Error converting OXPS to PDF: {str(e)}")
    
    @staticmethod
    def image_to_pdf(image_path: str, output_path: str) -> str:
        """Convert image (JPG/PNG) to PDF."""
        try:
            img = Image.open(image_path)
            
            # Convert to RGB if necessary
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Save as PDF
            img.save(output_path, 'PDF', resolution=300.0)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting image to PDF: {str(e)}")
    
    @staticmethod
    def markdown_to_pdf(md_path: str, output_path: str) -> str:
        """Convert Markdown to PDF."""
        try:
            with open(md_path, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Convert markdown to HTML
            html_content = markdown.markdown(md_content)
            
            # Convert HTML to PDF
            font_config = FontConfiguration()
            HTML(string=html_content).write_pdf(output_path, font_config=font_config)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting Markdown to PDF: {str(e)}")
    
    @staticmethod
    def excel_to_pdf(xlsx_path: str, output_path: str) -> str:
        """Convert Excel to PDF."""
        try:
            workbook = openpyxl.load_workbook(xlsx_path)
            
            # Create PDF using reportlab
            doc_pdf = SimpleDocTemplate(output_path, pagesize=A4)
            styles = getSampleStyleSheet()
            story = []
            
            for sheet_name in workbook.sheetnames:
                ws = workbook[sheet_name]
                story.append(Paragraph(f"Sheet: {sheet_name}", styles['Heading1']))
                story.append(Spacer(1, 12))
                
                # Convert sheet data to table
                data = []
                for row in ws.iter_rows(values_only=True):
                    if any(cell is not None for cell in row):
                        data.append([str(cell) if cell is not None else "" for cell in row])
                
                if data:
                    from reportlab.platypus import Table
                    table = Table(data)
                    story.append(table)
                    story.append(Spacer(1, 20))
            
            doc_pdf.build(story)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting Excel to PDF: {str(e)}")
    
    @staticmethod
    def excel_to_xps(xlsx_path: str, output_path: str) -> str:
        """Convert Excel to XPS."""
        try:
            # XPS conversion is complex and requires specialized libraries
            # This is a placeholder implementation
            raise FileProcessingError("Excel to XPS conversion requires specialized libraries not available in standard Python packages")
            
        except Exception as e:
            raise FileProcessingError(f"Error converting Excel to XPS: {str(e)}")
    
    @staticmethod
    def ods_to_pdf(ods_path: str, output_path: str) -> str:
        """Convert OpenOffice Calc ODS to PDF."""
        try:
            # ODS conversion requires specialized libraries
            # This is a placeholder implementation
            raise FileProcessingError("ODS to PDF conversion requires specialized libraries not available in standard Python packages")
            
        except Exception as e:
            raise FileProcessingError(f"Error converting ODS to PDF: {str(e)}")
    
    @staticmethod
    def pdf_to_csv_extract(pdf_path: str, output_path: str) -> str:
        """Extract tabular data from PDF to CSV."""
        return PDFConversionService.pdf_to_csv(pdf_path, output_path)
    
    @staticmethod
    def pdf_to_excel_extract(pdf_path: str, output_path: str) -> str:
        """Extract tabular data from PDF to Excel."""
        return PDFConversionService.pdf_to_excel(pdf_path, output_path)
    
    @staticmethod
    def pdf_to_word_extract(pdf_path: str, output_path: str) -> str:
        """Convert PDF to Word document."""
        try:
            doc = fitz.open(pdf_path)
            word_doc = Document()
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                text = page.get_text()
                
                if text.strip():
                    # Add page heading
                    word_doc.add_heading(f'Page {page_num + 1}', level=2)
                    
                    # Add text content
                    paragraphs = text.split('\n')
                    for para in paragraphs:
                        if para.strip():
                            word_doc.add_paragraph(para.strip())
                    
                    # Add page break (except for last page)
                    if page_num < len(doc) - 1:
                        word_doc.add_page_break()
            
            doc.close()
            word_doc.save(output_path)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to Word: {str(e)}")
    
    @staticmethod
    def pdf_to_image(pdf_path: str, output_dir: str, format: str = "jpg") -> List[str]:
        """Convert PDF pages to images."""
        try:
            doc = fitz.open(pdf_path)
            output_files = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                pix = page.get_pixmap()
                
                output_file = os.path.join(output_dir, f"page_{page_num + 1}.{format}")
                pix.save(output_file)
                output_files.append(output_file)
            
            doc.close()
            return output_files
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to images: {str(e)}")
    
    @staticmethod
    def pdf_to_tiff(pdf_path: str, output_dir: str) -> List[str]:
        """Convert PDF pages to TIFF images."""
        return PDFConversionService.pdf_to_image(pdf_path, output_dir, "tiff")
    
    @staticmethod
    def pdf_to_svg(pdf_path: str, output_dir: str) -> List[str]:
        """Convert PDF pages to SVG."""
        try:
            doc = fitz.open(pdf_path)
            output_files = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                svg_string = page.get_svg_image()
                
                output_file = os.path.join(output_dir, f"page_{page_num + 1}.svg")
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(svg_string)
                output_files.append(output_file)
            
            doc.close()
            return output_files
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to SVG: {str(e)}")
    
    @staticmethod
    def pdf_to_html(pdf_path: str, output_path: str) -> str:
        """Convert PDF to HTML."""
        try:
            doc = fitz.open(pdf_path)
            html_content = []
            
            # Add HTML header
            html_content.append("<!DOCTYPE html>")
            html_content.append("<html><head><title>PDF Content</title></head><body>")
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                text = page.get_text()
                
                if text.strip():
                    html_content.append(f"<div class='page' id='page-{page_num + 1}'>")
                    html_content.append(f"<h2>Page {page_num + 1}</h2>")
                    html_content.append(f"<p>{text.replace(chr(10), '<br>')}</p>")
                    html_content.append("</div>")
            
            html_content.append("</body></html>")
            
            doc.close()
            
            # Save HTML
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(html_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to HTML: {str(e)}")
    
    @staticmethod
    def pdf_to_text(pdf_path: str, output_path: str) -> str:
        """Convert PDF to plain text."""
        try:
            doc = fitz.open(pdf_path)
            text_content = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                text = page.get_text()
                
                if text.strip():
                    text_content.append(f"--- Page {page_num + 1} ---")
                    text_content.append(text)
                    text_content.append("")
            
            doc.close()
            
            # Save text
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('\n'.join(text_content))
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Error converting PDF to text: {str(e)}")
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get supported input and output formats."""
        return {
            "input_formats": PDFConversionService.SUPPORTED_INPUT_FORMATS,
            "output_formats": PDFConversionService.SUPPORTED_OUTPUT_FORMATS
        }
    
    @staticmethod
    def cleanup_temp_files(file_path: str):
        """Clean up temporary files."""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
        except Exception:
            pass  # Ignore cleanup errors
