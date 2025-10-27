#!/usr/bin/env python3
"""
Test script for OCR conversion functionality.
"""

import requests
import os
import json
from PIL import Image, ImageDraw, ImageFont
import io

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/ocrconversiontools"
TEST_IMAGE_PATH = "test_ocr_image.png"
TEST_PDF_PATH = "test_ocr_document.pdf"

def create_test_image():
    """Create a test image with text for OCR testing."""
    # Create a simple test image with text
    img = Image.new('RGB', (400, 200), color='white')
    draw = ImageDraw.Draw(img)
    
    # Try to use a default font, fallback to basic if not available
    try:
        font = ImageFont.truetype("arial.ttf", 24)
    except:
        font = ImageFont.load_default()
    
    # Draw some text
    text = "Hello World!\nThis is a test image\nfor OCR conversion."
    draw.text((20, 50), text, fill='black', font=font)
    
    img.save(TEST_IMAGE_PATH)
    print(f"Created test image: {TEST_IMAGE_PATH}")

def create_test_pdf():
    """Create a simple test PDF for OCR testing."""
    try:
        from reportlab.pdfgen import canvas
        from reportlab.lib.pagesizes import letter
        
        c = canvas.Canvas(TEST_PDF_PATH, pagesize=letter)
        c.drawString(100, 750, "This is a test PDF document")
        c.drawString(100, 700, "for OCR conversion testing.")
        c.drawString(100, 650, "It contains multiple lines of text.")
        c.save()
        print(f"Created test PDF: {TEST_PDF_PATH}")
    except ImportError:
        print("⚠️ ReportLab not available - skipping PDF creation")
        return False
    return True

def test_supported_languages():
    """Test getting supported languages."""
    try:
        response = requests.get(f"{BASE_URL}/supported-languages")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported languages test passed")
            print(f"Supported languages: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Supported languages test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported languages test error: {e}")

def test_supported_ocr_engines():
    """Test getting supported OCR engines."""
    try:
        response = requests.get(f"{BASE_URL}/supported-ocr-engines")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported OCR engines test passed")
            print(f"Supported engines: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Supported OCR engines test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported OCR engines test error: {e}")

def test_png_to_text():
    """Test PNG to text conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/png-to-text", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PNG to text conversion test passed")
            print(f"Extracted text: {result.get('extracted_text', 'No text extracted')}")
        else:
            print(f"❌ PNG to text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PNG to text conversion test error: {e}")

def test_jpg_to_text():
    """Test JPG to text conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        # Convert PNG to JPG for testing
        with Image.open(TEST_IMAGE_PATH) as img:
            jpg_path = TEST_IMAGE_PATH.replace('.png', '.jpg')
            img.convert('RGB').save(jpg_path, 'JPEG')
        
        with open(jpg_path, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/jpg-to-text", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JPG to text conversion test passed")
            print(f"Extracted text: {result.get('extracted_text', 'No text extracted')}")
        else:
            print(f"❌ JPG to text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
        
        # Clean up JPG file
        if os.path.exists(jpg_path):
            os.remove(jpg_path)
            
    except Exception as e:
        print(f"❌ JPG to text conversion test error: {e}")

def test_png_to_pdf():
    """Test PNG to PDF conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/png-to-pdf", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PNG to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PNG to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PNG to PDF conversion test error: {e}")

def test_jpg_to_pdf():
    """Test JPG to PDF conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        # Convert PNG to JPG for testing
        with Image.open(TEST_IMAGE_PATH) as img:
            jpg_path = TEST_IMAGE_PATH.replace('.png', '.jpg')
            img.convert('RGB').save(jpg_path, 'JPEG')
        
        with open(jpg_path, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/jpg-to-pdf", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JPG to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JPG to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
        
        # Clean up JPG file
        if os.path.exists(jpg_path):
            os.remove(jpg_path)
            
    except Exception as e:
        print(f"❌ JPG to PDF conversion test error: {e}")

def test_pdf_to_text():
    """Test PDF to text conversion."""
    try:
        if not create_test_pdf():
            print("⚠️ PDF to text test requires PDF creation - skipping")
            return
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/pdf-to-text", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF to text conversion test passed")
            print(f"Extracted text: {result.get('extracted_text', 'No text extracted')}")
        else:
            print(f"❌ PDF to text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF to text conversion test error: {e}")

def test_pdf_image_to_pdf_text():
    """Test PDF image to PDF text conversion."""
    try:
        if not create_test_pdf():
            print("⚠️ PDF image to PDF text test requires PDF creation - skipping")
            return
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            data = {'language': 'eng', 'ocr_engine': 'tesseract'}
            response = requests.post(f"{BASE_URL}/pdf-image-to-pdf-text", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF image to PDF text conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PDF image to PDF text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF image to PDF text conversion test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_IMAGE_PATH, TEST_PDF_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all OCR tests."""
    print("🧪 Testing OCR Conversion API")
    print("=" * 50)
    
    # Test supported languages
    print("\n1. Testing supported languages...")
    test_supported_languages()
    
    # Test supported OCR engines
    print("\n2. Testing supported OCR engines...")
    test_supported_ocr_engines()
    
    # Test PNG to text
    print("\n3. Testing PNG to text conversion...")
    test_png_to_text()
    
    # Test JPG to text
    print("\n4. Testing JPG to text conversion...")
    test_jpg_to_text()
    
    # Test PNG to PDF
    print("\n5. Testing PNG to PDF conversion...")
    test_png_to_pdf()
    
    # Test JPG to PDF
    print("\n6. Testing JPG to PDF conversion...")
    test_jpg_to_pdf()
    
    # Test PDF to text
    print("\n7. Testing PDF to text conversion...")
    test_pdf_to_text()
    
    # Test PDF image to PDF text
    print("\n8. Testing PDF image to PDF text conversion...")
    test_pdf_image_to_pdf_text()
    
    # Cleanup
    print("\n9. Cleaning up...")
    cleanup()
    
    print("\n✅ All OCR tests completed!")

if __name__ == "__main__":
    main()
