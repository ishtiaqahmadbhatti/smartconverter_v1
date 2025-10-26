import os
import json
import base64
import io
from typing import Optional, Dict, Any, List, Tuple
from PIL import Image, ImageOps
import cv2
import numpy as np
from pdf2image import convert_from_path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import cairosvg
try:
    from wand.image import Image as WandImage
    from wand.color import Color
    WAND_AVAILABLE = True
except ImportError:
    WAND_AVAILABLE = False
    WandImage = None
    Color = None
import requests
from bs4 import BeautifulSoup
import pandas as pd
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService


class ImageConversionService:
    """Service for handling image conversions and transformations."""
    
    # Supported input formats
    SUPPORTED_INPUT_FORMATS = {
        'AVIF', 'WEBP', 'PNG', 'JPG', 'JPEG', 'TIFF', 'SVG', 'HEIC', 'PGM', 'PPM', 
        'GIF', 'BMP', 'YUV', 'PAM', 'AI', 'PDF'
    }
    
    # Supported output formats
    SUPPORTED_OUTPUT_FORMATS = {
        'AVIF', 'WEBP', 'PNG', 'JPG', 'JPEG', 'TIFF', 'SVG', 'HEIC', 'PGM', 'PPM',
        'GIF', 'BMP', 'YUV', 'PAM'
    }
    
    @staticmethod
    def convert_image_format(input_path: str, output_format: str, quality: int = 95) -> str:
        """Convert image from one format to another."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input image file not found: {input_path}")
            
            # Get file extension without dot
            output_format = output_format.upper().replace('.', '')
            if output_format not in ImageConversionService.SUPPORTED_OUTPUT_FORMATS:
                raise FileProcessingError(f"Unsupported output format: {output_format}")
            
            # Generate output path
            base_name = os.path.splitext(os.path.basename(input_path))[0]
            output_path = FileService.get_output_path(input_path, f".{output_format.lower()}")
            
            # Handle special formats
            if output_format == 'HEIC':
                return ImageConversionService._convert_to_heic(input_path, output_path)
            elif output_format == 'SVG':
                return ImageConversionService._convert_to_svg(input_path, output_path)
            elif output_format in ['PGM', 'PPM']:
                return ImageConversionService._convert_to_netpbm(input_path, output_path, output_format)
            else:
                # Standard PIL conversion
                with Image.open(input_path) as img:
                    # Convert to RGB if necessary for JPEG
                    if output_format in ['JPG', 'JPEG'] and img.mode in ['RGBA', 'LA', 'P']:
                        img = img.convert('RGB')
                    
                    # Save with appropriate format and quality
                    save_kwargs = {}
                    if output_format in ['JPG', 'JPEG', 'WEBP']:
                        save_kwargs['quality'] = quality
                        save_kwargs['optimize'] = True
                    elif output_format == 'PNG':
                        save_kwargs['optimize'] = True
                    
                    img.save(output_path, format=output_format, **save_kwargs)
            
            if not os.path.exists(output_path):
                raise FileProcessingError("Conversion completed but output file was not created")
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Image format conversion failed: {str(e)}")
    
    @staticmethod
    def image_to_json(input_path: str, include_metadata: bool = True) -> str:
        """Convert image to JSON format with metadata and base64 encoding."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input image file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".json")
            
            with Image.open(input_path) as img:
                # Get image metadata
                metadata = {
                    "filename": os.path.basename(input_path),
                    "format": img.format,
                    "mode": img.mode,
                    "size": img.size,
                    "width": img.width,
                    "height": img.height
                }
                
                if include_metadata:
                    # Add EXIF data if available
                    if hasattr(img, '_getexif') and img._getexif():
                        exif_data = img._getexif()
                        metadata["exif"] = {str(k): str(v) for k, v in exif_data.items()}
                    
                    # Add additional metadata
                    metadata.update({
                        "has_transparency": img.mode in ['RGBA', 'LA', 'P'],
                        "color_count": len(img.getcolors(maxcolors=256*256*256)) if img.mode == 'P' else None
                    })
                
                # Convert image to base64
                img_buffer = io.BytesIO()
                img.save(img_buffer, format=img.format or 'PNG')
                img_base64 = base64.b64encode(img_buffer.getvalue()).decode('utf-8')
                
                # Create JSON structure
                json_data = {
                    "image_data": {
                        "base64": img_base64,
                        "format": img.format or 'PNG',
                        "mime_type": f"image/{img.format.lower() if img.format else 'png'}"
                    },
                    "metadata": metadata if include_metadata else None,
                    "conversion_info": {
                        "converted_at": str(pd.Timestamp.now()),
                        "original_size": os.path.getsize(input_path),
                        "base64_size": len(img_base64)
                    }
                }
            
            # Save JSON file
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(json_data, f, indent=2, ensure_ascii=False)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Image to JSON conversion failed: {str(e)}")
    
    @staticmethod
    def image_to_pdf(input_path: str, page_size: str = 'A4') -> str:
        """Convert image to PDF."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input image file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".pdf")
            
            # Convert image to PDF using img2pdf
            import img2pdf
            
            with open(input_path, "rb") as f:
                img_data = f.read()
            
            # Convert to PDF
            pdf_data = img2pdf.convert(img_data)
            
            # Save PDF
            with open(output_path, "wb") as f:
                f.write(pdf_data)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"Image to PDF conversion failed: {str(e)}")
    
    @staticmethod
    def website_to_image(url: str, output_format: str = 'PNG', width: int = 1920, height: int = 1080) -> str:
        """Convert website to image using Selenium."""
        try:
            # Setup Chrome options
            chrome_options = Options()
            chrome_options.add_argument('--headless')
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument(f'--window-size={width},{height}')
            
            # Setup Chrome driver
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            
            try:
                # Navigate to URL
                driver.get(url)
                
                # Wait for page to load
                driver.implicitly_wait(10)
                
                # Take screenshot
                screenshot = driver.get_screenshot_as_png()
                
                # Generate output path
                safe_url = url.replace('://', '_').replace('/', '_').replace('.', '_')
                output_path = FileService.get_output_path(f"website_{safe_url}", f".{output_format.lower()}")
                
                # Save image
                with Image.open(io.BytesIO(screenshot)) as img:
                    img.save(output_path, format=output_format.upper())
                
                return output_path
                
            finally:
                driver.quit()
                
        except Exception as e:
            raise FileProcessingError(f"Website to image conversion failed: {str(e)}")
    
    @staticmethod
    def html_to_image(html_content: str, output_format: str = 'PNG', width: int = 1920, height: int = 1080) -> str:
        """Convert HTML content to image."""
        try:
            # Setup Chrome options
            chrome_options = Options()
            chrome_options.add_argument('--headless')
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument(f'--window-size={width},{height}')
            
            # Setup Chrome driver
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            
            try:
                # Load HTML content
                driver.get(f"data:text/html;charset=utf-8,{html_content}")
                
                # Wait for content to load
                driver.implicitly_wait(5)
                
                # Take screenshot
                screenshot = driver.get_screenshot_as_png()
                
                # Generate output path
                output_path = FileService.get_output_path("html_content", f".{output_format.lower()}")
                
                # Save image
                with Image.open(io.BytesIO(screenshot)) as img:
                    img.save(output_path, format=output_format.upper())
                
                return output_path
                
            finally:
                driver.quit()
                
        except Exception as e:
            raise FileProcessingError(f"HTML to image conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_image(input_path: str, output_format: str = 'PNG', dpi: int = 300, page_number: int = 1) -> str:
        """Convert PDF page to image."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Convert PDF to images
            images = convert_from_path(input_path, dpi=dpi, first_page=page_number, last_page=page_number)
            
            if not images:
                raise FileProcessingError("No pages found in PDF")
            
            # Get the first (and only) page
            image = images[0]
            
            # Generate output path
            base_name = os.path.splitext(os.path.basename(input_path))[0]
            output_path = FileService.get_output_path(f"{base_name}_page_{page_number}", f".{output_format.lower()}")
            
            # Save image
            image.save(output_path, format=output_format.upper())
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"PDF to image conversion failed: {str(e)}")
    
    @staticmethod
    def pdf_to_tiff(input_path: str, dpi: int = 300, page_number: int = 1) -> str:
        """Convert PDF page to TIFF."""
        return ImageConversionService.pdf_to_image(input_path, 'TIFF', dpi, page_number)
    
    @staticmethod
    def pdf_to_svg(input_path: str, dpi: int = 300, page_number: int = 1) -> str:
        """Convert PDF page to SVG."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input PDF file not found: {input_path}")
            
            # Convert PDF to images first
            images = convert_from_path(input_path, dpi=dpi, first_page=page_number, last_page=page_number)
            
            if not images:
                raise FileProcessingError("No pages found in PDF")
            
            # Get the first (and only) page
            image = images[0]
            
            # Generate output path
            base_name = os.path.splitext(os.path.basename(input_path))[0]
            output_path = FileService.get_output_path(f"{base_name}_page_{page_number}", ".svg")
            
            # Convert to SVG
            return ImageConversionService._convert_to_svg_from_pil(image, output_path)
            
        except Exception as e:
            raise FileProcessingError(f"PDF to SVG conversion failed: {str(e)}")
    
    @staticmethod
    def ai_to_svg(input_path: str) -> str:
        """Convert AI (Adobe Illustrator) file to SVG."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input AI file not found: {input_path}")
            
            # Generate output path
            output_path = FileService.get_output_path(input_path, ".svg")
            
            # For AI files, we'll try to open with PIL first, then convert
            with Image.open(input_path) as img:
                return ImageConversionService._convert_to_svg_from_pil(img, output_path)
            
        except Exception as e:
            raise FileProcessingError(f"AI to SVG conversion failed: {str(e)}")
    
    @staticmethod
    def remove_exif_data(input_path: str) -> str:
        """Remove EXIF data from image."""
        try:
            if not os.path.exists(input_path):
                raise FileProcessingError(f"Input image file not found: {input_path}")
            
            # Generate output path
            base_name = os.path.splitext(os.path.basename(input_path))[0]
            output_path = FileService.get_output_path(f"{base_name}_no_exif", os.path.splitext(input_path)[1])
            
            with Image.open(input_path) as img:
                # Create a new image without EXIF data
                data = list(img.getdata())
                image_without_exif = Image.new(img.mode, img.size)
                image_without_exif.putdata(data)
                
                # Save without EXIF
                image_without_exif.save(output_path, format=img.format)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"EXIF data removal failed: {str(e)}")
    
    @staticmethod
    def _convert_to_svg_from_pil(pil_image, output_path: str) -> str:
        """Convert PIL image to SVG format."""
        try:
            # Convert to RGB if necessary
            if pil_image.mode in ['RGBA', 'LA', 'P']:
                pil_image = pil_image.convert('RGB')
            
            # Create SVG content
            width, height = pil_image.size
            
            # Convert image to base64
            img_buffer = io.BytesIO()
            pil_image.save(img_buffer, format='PNG')
            img_base64 = base64.b64encode(img_buffer.getvalue()).decode('utf-8')
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{width}" height="{height}" xmlns="http://www.w3.org/2000/svg">
    <image href="data:image/png;base64,{img_base64}" 
           width="{width}" height="{height}"/>
</svg>'''
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(svg_content)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SVG conversion failed: {str(e)}")
    
    @staticmethod
    def _convert_to_heic(input_path: str, output_path: str) -> str:
        """Convert image to HEIC format."""
        try:
            with Image.open(input_path) as img:
                # Convert to RGB if necessary
                if img.mode in ['RGBA', 'LA', 'P']:
                    img = img.convert('RGB')
                
                # Save as HEIC
                img.save(output_path, format='HEIF', quality=95)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"HEIC conversion failed: {str(e)}")
    
    @staticmethod
    def _convert_to_svg(input_path: str, output_path: str) -> str:
        """Convert image to SVG format."""
        try:
            with Image.open(input_path) as img:
                # Convert to RGB if necessary
                if img.mode in ['RGBA', 'LA', 'P']:
                    img = img.convert('RGB')
                
                # Create SVG content
                width, height = img.size
                svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{width}" height="{height}" xmlns="http://www.w3.org/2000/svg">
    <image href="data:image/png;base64,{base64.b64encode(io.BytesIO(img.tobytes()).getvalue()).decode()}" 
           width="{width}" height="{height}"/>
</svg>'''
                
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(svg_content)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"SVG conversion failed: {str(e)}")
    
    @staticmethod
    def _convert_to_netpbm(input_path: str, output_path: str, format_type: str) -> str:
        """Convert image to PGM or PPM format."""
        try:
            with Image.open(input_path) as img:
                # Convert to grayscale for PGM, RGB for PPM
                if format_type == 'PGM':
                    if img.mode != 'L':
                        img = img.convert('L')
                elif format_type == 'PPM':
                    if img.mode not in ['RGB', 'L']:
                        img = img.convert('RGB')
                
                # Save in NetPBM format
                img.save(output_path, format=format_type)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"NetPBM conversion failed: {str(e)}")
    
    @staticmethod
    def get_supported_formats() -> Dict[str, List[str]]:
        """Get list of supported input and output formats."""
        return {
            "input_formats": list(ImageConversionService.SUPPORTED_INPUT_FORMATS),
            "output_formats": list(ImageConversionService.SUPPORTED_OUTPUT_FORMATS)
        }
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
