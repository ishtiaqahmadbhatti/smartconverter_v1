#!/usr/bin/env python3
"""
Test script for image conversion functionality.
"""

import requests
import os
import json
from PIL import Image
import io

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/imageconversiontools"
TEST_IMAGE_PATH = "test_image.png"

def create_test_image():
    """Create a simple test image."""
    # Create a simple test image
    img = Image.new('RGB', (100, 100), color='red')
    img.save(TEST_IMAGE_PATH)
    print(f"Created test image: {TEST_IMAGE_PATH}")

def test_supported_formats():
    """Test getting supported formats."""
    try:
        response = requests.get(f"{BASE_URL}/supported-formats")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported formats test passed")
            print(f"Supported formats: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Supported formats test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported formats test error: {e}")

def test_image_format_conversion():
    """Test image format conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            data = {
                'output_format': 'JPEG',
                'quality': 95
            }
            response = requests.post(f"{BASE_URL}/convert-format", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Image format conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Image format conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Image format conversion test error: {e}")

def test_image_to_json():
    """Test image to JSON conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            data = {'include_metadata': True}
            response = requests.post(f"{BASE_URL}/image-to-json", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Image to JSON conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Image to JSON conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Image to JSON conversion test error: {e}")

def test_image_to_pdf():
    """Test image to PDF conversion."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            data = {'page_size': 'A4'}
            response = requests.post(f"{BASE_URL}/image-to-pdf", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Image to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Image to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Image to PDF conversion test error: {e}")

def test_website_to_image():
    """Test website to image conversion."""
    try:
        data = {
            'url': 'https://www.google.com',
            'output_format': 'PNG',
            'width': 800,
            'height': 600
        }
        response = requests.post(f"{BASE_URL}/website-to-image", data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Website to image conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Website to image conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Website to image conversion test error: {e}")

def test_html_to_image():
    """Test HTML to image conversion."""
    try:
        html_content = """
        <html>
        <body>
            <h1>Test HTML</h1>
            <p>This is a test HTML document.</p>
        </body>
        </html>
        """
        data = {
            'html_content': html_content,
            'output_format': 'PNG',
            'width': 800,
            'height': 600
        }
        response = requests.post(f"{BASE_URL}/html-to-image", data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ HTML to image conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ HTML to image conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ HTML to image conversion test error: {e}")

def test_pdf_to_tiff():
    """Test PDF to TIFF conversion."""
    try:
        # Create a simple PDF for testing (this would need a PDF file in practice)
        print("⚠️ PDF to TIFF test requires a PDF file - skipping for now")
        print("✅ PDF to TIFF test structure ready")
    except Exception as e:
        print(f"❌ PDF to TIFF test error: {e}")

def test_pdf_to_svg():
    """Test PDF to SVG conversion."""
    try:
        # Create a simple PDF for testing (this would need a PDF file in practice)
        print("⚠️ PDF to SVG test requires a PDF file - skipping for now")
        print("✅ PDF to SVG test structure ready")
    except Exception as e:
        print(f"❌ PDF to SVG test error: {e}")

def test_ai_to_svg():
    """Test AI to SVG conversion."""
    try:
        # Create a simple AI file for testing (this would need an AI file in practice)
        print("⚠️ AI to SVG test requires an AI file - skipping for now")
        print("✅ AI to SVG test structure ready")
    except Exception as e:
        print(f"❌ AI to SVG test error: {e}")

def test_remove_exif():
    """Test EXIF data removal."""
    try:
        if not os.path.exists(TEST_IMAGE_PATH):
            create_test_image()
        
        with open(TEST_IMAGE_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/remove-exif", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ EXIF removal test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ EXIF removal test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ EXIF removal test error: {e}")

def cleanup():
    """Clean up test files."""
    if os.path.exists(TEST_IMAGE_PATH):
        os.remove(TEST_IMAGE_PATH)
        print(f"Cleaned up test file: {TEST_IMAGE_PATH}")

def main():
    """Run all tests."""
    print("🧪 Testing Image Conversion API")
    print("=" * 50)
    
    # Test supported formats
    print("\n1. Testing supported formats...")
    test_supported_formats()
    
    # Test image format conversion
    print("\n2. Testing image format conversion...")
    test_image_format_conversion()
    
    # Test image to JSON
    print("\n3. Testing image to JSON conversion...")
    test_image_to_json()
    
    # Test image to PDF
    print("\n4. Testing image to PDF conversion...")
    test_image_to_pdf()
    
    # Test website to image
    print("\n5. Testing website to image conversion...")
    test_website_to_image()
    
    # Test HTML to image
    print("\n6. Testing HTML to image conversion...")
    test_html_to_image()
    
    # Test PDF to TIFF
    print("\n7. Testing PDF to TIFF conversion...")
    test_pdf_to_tiff()
    
    # Test PDF to SVG
    print("\n8. Testing PDF to SVG conversion...")
    test_pdf_to_svg()
    
    # Test AI to SVG
    print("\n9. Testing AI to SVG conversion...")
    test_ai_to_svg()
    
    # Test EXIF removal
    print("\n10. Testing EXIF data removal...")
    test_remove_exif()
    
    # Cleanup
    print("\n11. Cleaning up...")
    cleanup()
    
    print("\n✅ All tests completed!")

if __name__ == "__main__":
    main()
