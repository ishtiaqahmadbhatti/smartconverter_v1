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
from PyPDF2 import PdfMerger


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
    def merge_pdfs(input_paths: List[str], output_path: str) -> str:
        """Merge multiple PDF files into a single PDF."""
        if not input_paths:
            raise FileProcessingError("No PDF files provided for merging.")

        try:
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            merger = PdfMerger()

            for path in input_paths:
                if not os.path.exists(path):
                    raise FileProcessingError(f"Input file not found: {path}")
                with open(path, "rb") as pdf_file:
                    merger.append(pdf_file)

            with open(output_path, "wb") as merged_file:
                merger.write(merged_file)
            merger.close()

            return output_path
        except FileProcessingError:
            raise
        except Exception as e:
            raise FileProcessingError(f"Error merging PDFs: {str(e)}")
    
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
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                
                # Create a new sheet for each page
                ws = workbook.create_sheet(title=f"Page_{page_num + 1}")
                
                # Extract tables
                tables = list(page.find_tables())  # Convert to list to check if empty
                row_offset = 1
                has_table_data = False
                
                # Extract and add table data
                for table in tables:
                    try:
                    table_data = table.extract()
                        if table_data and len(table_data) > 0:
                            has_table_data = True
                        for row_idx, row in enumerate(table_data):
                            for col_idx, cell in enumerate(row):
                                    if cell:  # Only add non-empty cells
                                        ws.cell(row=row_offset + row_idx, column=col_idx + 1, value=str(cell))
                            row_offset += len(table_data) + 2  # Add spacing between tables
                    except Exception as e:
                        # If table extraction fails, continue with text extraction
                        pass
                
                # Extract text content
                    text = page.get_text()
                if text and text.strip():
                    # If we have table data, add text after tables, otherwise start from row 1
                    if not has_table_data:
                        row_offset = 1
                    
                    lines = text.split('\n')
                    # Filter out empty lines and limit to reasonable number
                    non_empty_lines = [line.strip() for line in lines if line.strip()][:500]
                    
                    if non_empty_lines:
                        # Add header if we have both tables and text
                        if has_table_data:
                            ws.cell(row=row_offset, column=1, value="Text Content:")
                            row_offset += 1
                        
                        for row_idx, line in enumerate(non_empty_lines):
                            ws.cell(row=row_offset + row_idx, column=1, value=line)
            
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
        """Convert Markdown to PDF with proper handling of emojis, headings, and tables."""
        try:
            with open(md_path, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Convert markdown to HTML with extensions for tables and other features
            try:
                # Try to use markdown extensions if available
                import markdown.extensions.tables
                import markdown.extensions.fenced_code
                md_extensions = ['tables', 'fenced_code', 'nl2br']
                html_content = markdown.markdown(md_content, extensions=md_extensions)
            except:
                # Fallback to basic markdown if extensions not available
            html_content = markdown.markdown(md_content)
            
            if not WEASYPRINT_AVAILABLE:
                # Fallback to reportlab with proper HTML parsing using BeautifulSoup
                from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
                from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
                from reportlab.lib.pagesizes import A4
                from reportlab.lib import colors
                from reportlab.lib.units import inch
                from bs4 import BeautifulSoup
                import re
                
                # Parse HTML with BeautifulSoup for better handling of nested tags
                soup = BeautifulSoup(html_content, 'html.parser')
                story = []
                styles = getSampleStyleSheet()
                
                # Register Unicode fonts for emoji support
                unicode_font_name = 'Helvetica'  # Default fallback
                try:
                    from reportlab.pdfbase import pdfmetrics
                    from reportlab.pdfbase.ttfonts import TTFont
                    import sys
                    import os
                    
                    # Try to register fonts with better Unicode/Emoji support
                    # Try multiple font paths that might support emojis
                    try:
                        # Common system font paths (prioritize fonts with emoji support)
                        font_paths = [
                            # Windows fonts (better emoji support)
                            'C:/Windows/Fonts/seguiemj.ttf',  # Segoe UI Emoji
                            'C:/Windows/Fonts/segmdl2.ttf',   # Segoe MDL2 Assets
                            'C:/Windows/Fonts/arial.ttf',     # Arial (basic Unicode)
                            'C:/Windows/Fonts/calibri.ttf',  # Calibri
                            # Linux fonts
                            '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
                            '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
                            '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
                            # macOS fonts
                            '/System/Library/Fonts/Supplemental/Apple Color Emoji.ttc',
                            '/System/Library/Fonts/Helvetica.ttc',
                        ]
                        
                        # Try to find and register a Unicode font
                        for font_path in font_paths:
                            if os.path.exists(font_path):
                                try:
                                    pdfmetrics.registerFont(TTFont('UnicodeFont', font_path))
                                    unicode_font_name = 'UnicodeFont'
                                    break
                                except Exception as e:
                                    # Continue trying other fonts
                                    continue
                    except:
                        pass
                except:
                    pass  # Keep default Helvetica
                
                # Define heading styles with Unicode font support
                heading_styles = {
                    'h1': ParagraphStyle(
                        'CustomH1',
                        parent=styles['Heading1'],
                        fontSize=24,
                        spaceAfter=12,
                        textColor=colors.HexColor('#1a1a1a'),
                        fontName=unicode_font_name
                    ),
                    'h2': ParagraphStyle(
                        'CustomH2',
                        parent=styles['Heading2'],
                        fontSize=20,
                        spaceAfter=10,
                        textColor=colors.HexColor('#2a2a2a'),
                        fontName=unicode_font_name
                    ),
                    'h3': ParagraphStyle(
                        'CustomH3',
                        parent=styles['Heading3'],
                        fontSize=16,
                        spaceAfter=8,
                        textColor=colors.HexColor('#3a3a3a'),
                        fontName=unicode_font_name
                    ),
                    'h4': ParagraphStyle(
                        'CustomH4',
                        parent=styles['Heading4'],
                        fontSize=14,
                        spaceAfter=6,
                        fontName=unicode_font_name
                    ),
                    'h5': ParagraphStyle(
                        'CustomH5',
                        parent=styles['Heading5'],
                        fontSize=12,
                        spaceAfter=4,
                        fontName=unicode_font_name
                    ),
                    'h6': ParagraphStyle(
                        'CustomH6',
                        parent=styles['Heading6'],
                        fontSize=11,
                        spaceAfter=4,
                        fontName=unicode_font_name
                    ),
                }
                
                # Normal style with Unicode font
                normal_style = ParagraphStyle(
                    'UnicodeNormal',
                    parent=styles['Normal'],
                    fontName=unicode_font_name,
                    encoding='utf-8'
                )
                
                def get_text_with_emojis(element):
                    """Extract text from element preserving emojis and special characters."""
                    if element is None:
                        return ""
                    # Get all text including emojis - preserve Unicode characters
                    text = element.get_text(separator=' ', strip=False)
                    # Clean up extra whitespace but preserve structure and emojis
                    text = re.sub(r'\s+', ' ', text).strip()
                    # Ensure text is properly encoded as UTF-8
                    if isinstance(text, bytes):
                        text = text.decode('utf-8', errors='ignore')
                    return text
                
                def create_paragraph_with_emojis(text, style):
                    """Create a paragraph that properly handles emojis."""
                    if not text:
                        return None
                    try:
                        # Ensure text is UTF-8 encoded
                        if isinstance(text, bytes):
                            text = text.decode('utf-8', errors='ignore')
                        # Escape XML special characters but preserve emojis
                        from xml.sax.saxutils import escape
                        # Don't escape emojis - they should be preserved as-is
                        # Only escape XML special chars
                        text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                        # Create paragraph with UTF-8 encoding
                        return Paragraph(text, style)
                    except Exception as e:
                        # Fallback: try without escaping
                        try:
                            return Paragraph(str(text), style)
                        except:
                            # Last resort: remove problematic characters but keep emojis
                            safe_text = ''.join(c if ord(c) < 0x10000 or c.isprintable() else '?' for c in str(text))
                            return Paragraph(safe_text, style)
                
                def process_element(element):
                    """Recursively process HTML elements and add to story."""
                    if element is None:
                        return
                    
                    tag_name = element.name if hasattr(element, 'name') else None
                    
                    if tag_name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
                        text = get_text_with_emojis(element)
                        if text:
                            style = heading_styles.get(tag_name, styles['Heading1'])
                            para = create_paragraph_with_emojis(text, style)
                            if para:
                                story.append(para)
                                story.append(Spacer(1, 6))
                    
                    elif tag_name == 'p':
                        text = get_text_with_emojis(element)
                        if text:
                            para = create_paragraph_with_emojis(text, normal_style)
                            if para:
                                story.append(para)
                                story.append(Spacer(1, 8))
                    
                    elif tag_name in ['ul', 'ol']:
                        for li in element.find_all('li', recursive=False):
                            text = get_text_with_emojis(li)
                            if text:
                                bullet = "•" if tag_name == 'ul' else "1."
                                para = create_paragraph_with_emojis(f"{bullet} {text}", normal_style)
                                if para:
                                    story.append(para)
                                    story.append(Spacer(1, 4))
                        story.append(Spacer(1, 6))
                    
                    elif tag_name == 'table':
                        # Extract table data
                        table_data = []
                        rows = element.find_all('tr')
                        for row in rows:
                            cells = row.find_all(['td', 'th'])
                            row_data = [get_text_with_emojis(cell) for cell in cells]
                            if row_data:
                                table_data.append(row_data)
                        
                        if table_data:
                            # Convert table cells to Paragraphs to support emojis
                            formatted_table_data = []
                            for row_idx, row in enumerate(table_data):
                                formatted_row = []
                                for cell_text in row:
                                    if cell_text:
                                        # Create paragraph for each cell to support emojis
                                        cell_para = create_paragraph_with_emojis(
                                            cell_text, 
                                            normal_style if row_idx > 0 else heading_styles.get('h4', normal_style)
                                        )
                                        formatted_row.append(cell_para if cell_para else cell_text)
                                    else:
                                        formatted_row.append('')
                                formatted_table_data.append(formatted_row)
                            
                            # Create table with proper styling
                            pdf_table = Table(formatted_table_data)
                            pdf_table.setStyle(TableStyle([
                                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                                ('FONTNAME', (0, 0), (-1, 0), unicode_font_name),
                                ('FONTSIZE', (0, 0), (-1, 0), 11),
                                ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
                                ('TOPPADDING', (0, 0), (-1, 0), 10),
                                ('BACKGROUND', (0, 1), (-1, -1), colors.white),
                                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
                                ('FONTSIZE', (0, 1), (-1, -1), 10),
                                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
                                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                            ]))
                            story.append(pdf_table)
                            story.append(Spacer(1, 12))
                    
                    elif tag_name == 'hr':
                        story.append(Spacer(1, 12))
                        # Add a line separator
                        from reportlab.platypus import HRFlowable
                        story.append(HRFlowable(width="100%", thickness=1, lineCap='round', color=colors.grey))
                        story.append(Spacer(1, 12))
                    
                    elif tag_name == 'br':
                        story.append(Spacer(1, 6))
                    
                    elif tag_name == 'pre':
                        # Handle pre-formatted code blocks (from triple backticks)
                        # Extract all text preserving line breaks and formatting
                        code_text = ""
                        if element.find('code'):
                            # If there's a code tag inside pre, get its text
                            code_text = element.find('code').get_text(separator='\n', strip=False)
                        else:
                            # Otherwise get all text from pre tag
                            code_text = element.get_text(separator='\n', strip=False)
                        
                        if code_text:
                            # Preserve line breaks and formatting
                            code_text = code_text.rstrip()  # Remove trailing newlines
                            
                            # Create a code block style with monospace font
                            pre_code_style = ParagraphStyle(
                                'PreCode',
                                parent=styles['Normal'],
                                fontName='Courier',
                                fontSize=8,
                                leading=10,
                                encoding='utf-8',
                                leftIndent=0,
                                rightIndent=0
                            )
                            
                            # Split by lines and create paragraphs to preserve formatting
                            lines = code_text.split('\n')
                            code_paragraphs = []
                            for line in lines:
                                # Preserve all lines including empty ones for proper formatting
                                # Escape XML special chars but preserve structure
                                safe_line = line.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                                # Preserve spaces at the beginning (for indentation)
                                para = Paragraph(safe_line, pre_code_style)
                                code_paragraphs.append(para)
                            
                            # Wrap code block in a Table to create background and border effect
                            # Each line becomes a cell in a single-column table
                            code_table_data = [[para] for para in code_paragraphs]
                            code_table = Table(code_table_data, colWidths=[None])  # Auto width
                            
                            # Style the table to look like a code block
                            code_table.setStyle(TableStyle([
                                # Background color for all cells
                                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#f5f5f5')),
                                # Border around the entire block
                                ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#ddd')),
                                # Padding inside cells
                                ('LEFTPADDING', (0, 0), (-1, -1), 12),
                                ('RIGHTPADDING', (0, 0), (-1, -1), 12),
                                ('TOPPADDING', (0, 0), (-1, -1), 6),
                                ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
                                # Alignment
                                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                            ]))
                            
                            story.append(Spacer(1, 8))
                            story.append(code_table)
                            story.append(Spacer(1, 8))
                    
                    elif tag_name == 'code':
                        # Handle inline code (single backticks)
                        text = get_text_with_emojis(element)
                        if text:
                            code_style = ParagraphStyle(
                                'Code',
                                parent=styles['Normal'],
                                fontName='Courier',
                                fontSize=9,
                                backColor=colors.lightgrey,
                                leftIndent=12,
                                rightIndent=12,
                                spaceBefore=4,
                                spaceAfter=4,
                                encoding='utf-8'
                            )
                            para = create_paragraph_with_emojis(text, code_style)
                            if para:
                                story.append(para)
                                story.append(Spacer(1, 6))
                    
                    elif tag_name == 'blockquote':
                        text = get_text_with_emojis(element)
                        if text:
                            quote_style = ParagraphStyle(
                                'Quote',
                                parent=normal_style,
                                leftIndent=20,
                                rightIndent=20,
                                fontStyle='Italic',
                                textColor=colors.HexColor('#555555')
                            )
                            para = create_paragraph_with_emojis(f'"{text}"', quote_style)
                            if para:
                                story.append(para)
                                story.append(Spacer(1, 8))
                    
                    else:
                        # Process children recursively
                        if hasattr(element, 'children'):
                            for child in element.children:
                                if hasattr(child, 'name'):
                                    process_element(child)
                                elif isinstance(child, str) and child.strip():
                                    # Handle text nodes
                                    text = child.strip()
                                    if text:
                                        para = create_paragraph_with_emojis(text, normal_style)
                                        if para:
                                            story.append(para)
                                            story.append(Spacer(1, 6))
                
                # Process all top-level elements
                for element in soup.children:
                    if hasattr(element, 'name'):
                        process_element(element)
                
                # If no content was added, add body content
                if not story:
                    body = soup.find('body')
                    if body:
                        for element in body.children:
                            if hasattr(element, 'name'):
                                process_element(element)
                    else:
                        # Fallback: process all elements
                        for element in soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'ul', 'ol', 'table']):
                            process_element(element)
                
                # Create PDF
                doc = SimpleDocTemplate(
                    output_path,
                    pagesize=A4,
                    rightMargin=72,
                    leftMargin=72,
                    topMargin=72,
                    bottomMargin=72,
                    encoding='utf-8'
                )
                doc.build(story)
            else:
                # Use WeasyPrint for proper HTML to PDF conversion with CSS styling
                css_content = """
                @page {
                    size: A4;
                    margin: 2cm;
                }
                body {
                    font-family: 'DejaVu Sans', Arial, sans-serif;
                    font-size: 11pt;
                    line-height: 1.6;
                    color: #333;
                }
                h1 {
                    font-size: 24pt;
                    color: #1a1a1a;
                    margin-top: 20pt;
                    margin-bottom: 12pt;
                    border-bottom: 2px solid #ddd;
                    padding-bottom: 8pt;
                }
                h2 {
                    font-size: 20pt;
                    color: #2a2a2a;
                    margin-top: 16pt;
                    margin-bottom: 10pt;
                    border-bottom: 1px solid #eee;
                    padding-bottom: 6pt;
                }
                h3 {
                    font-size: 16pt;
                    color: #3a3a3a;
                    margin-top: 12pt;
                    margin-bottom: 8pt;
                }
                h4 {
                    font-size: 14pt;
                    color: #4a4a4a;
                    margin-top: 10pt;
                    margin-bottom: 6pt;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: 12pt 0;
                }
                th {
                    background-color: #f0f0f0;
                    color: #000;
                    font-weight: bold;
                    padding: 8pt;
                    border: 1px solid #ddd;
                }
                td {
                    padding: 6pt;
                    border: 1px solid #ddd;
                }
                tr:nth-child(even) {
                    background-color: #f9f9f9;
                }
                p {
                    margin: 8pt 0;
                }
                ul, ol {
                    margin: 8pt 0;
                    padding-left: 24pt;
                }
                li {
                    margin: 4pt 0;
                }
                code {
                    background-color: #f4f4f4;
                    padding: 2pt 4pt;
                    border-radius: 3pt;
                    font-family: 'Courier New', monospace;
                }
                pre {
                    background-color: #f5f5f5;
                    border: 1px solid #ddd;
                    border-radius: 4pt;
                    padding: 12pt;
                    margin: 12pt 0;
                    overflow-x: auto;
                    font-family: 'Courier New', 'Courier', monospace;
                    font-size: 8pt;
                    line-height: 1.4;
                    white-space: pre;
                    word-wrap: normal;
                }
                pre code {
                    background-color: transparent;
                    padding: 0;
                    border-radius: 0;
                    font-size: inherit;
                }
                """
                
            font_config = FontConfiguration()
            HTML(string=html_content).write_pdf(
                output_path,
                font_config=font_config,
                stylesheets=[CSS(string=css_content)]
            )
            
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
            target_format = (format or "jpg").lower()
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                pix = page.get_pixmap()
                
                output_file = os.path.join(output_dir, f"page_{page_num + 1}.{target_format}")
                
                if target_format in {"tiff", "tif"}:
                    mode = "RGBA" if pix.alpha else "RGB"
                    image = Image.frombytes(mode, [pix.width, pix.height], pix.samples)
                    image.save(output_file, format="TIFF")
                else:
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
