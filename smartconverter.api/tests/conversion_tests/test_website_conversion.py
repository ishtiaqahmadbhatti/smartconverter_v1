#!/usr/bin/env python3
"""
Test script for Website conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/websiteconversiontools"

def test_supported_formats():
    """Test getting supported formats."""
    try:
        response = requests.get(f"{BASE_URL}/supported-formats")
        if response.status_code == 200:
            print("✅ Supported formats endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Supported formats failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported formats error: {e}")

def test_html_to_pdf():
    """Test HTML to PDF conversion."""
    try:
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test HTML Document</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                h1 { color: #333; }
                p { line-height: 1.6; }
            </style>
        </head>
        <body>
            <h1>Test HTML Document</h1>
            <p>This is a test HTML document for conversion to PDF.</p>
            <p>It contains multiple paragraphs and basic styling.</p>
            <ul>
                <li>Item 1</li>
                <li>Item 2</li>
                <li>Item 3</li>
            </ul>
        </body>
        </html>
        """
        
        with open('test.html', 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        with open('test.html', 'rb') as f:
            files = {'file': ('test.html', f, 'text/html')}
            response = requests.post(f"{BASE_URL}/html-to-pdf", files=files)
        
        if response.status_code == 200:
            print("✅ HTML to PDF conversion successful")
            with open('output.pdf', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.pdf")
        else:
            print(f"❌ HTML to PDF failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ HTML to PDF error: {e}")

def test_url_to_pdf():
    """Test URL to PDF conversion."""
    try:
        url_data = {
            'url': 'https://example.com',
            'options': {
                'format': 'A4',
                'margin': '1in'
            }
        }
        
        response = requests.post(f"{BASE_URL}/url-to-pdf", json=url_data)
        
        if response.status_code == 200:
            print("✅ URL to PDF conversion successful")
            with open('output.pdf', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.pdf")
        else:
            print(f"❌ URL to PDF failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ URL to PDF error: {e}")

def test_url_to_image():
    """Test URL to Image conversion."""
    try:
        url_data = {
            'url': 'https://example.com',
            'options': {
                'format': 'png',
                'width': 1920,
                'height': 1080
            }
        }
        
        response = requests.post(f"{BASE_URL}/url-to-image", json=url_data)
        
        if response.status_code == 200:
            print("✅ URL to Image conversion successful")
            with open('output.png', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.png")
        else:
            print(f"❌ URL to Image failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ URL to Image error: {e}")

def test_html_to_image():
    """Test HTML to Image conversion."""
    try:
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test HTML Document</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
                h1 { color: #333; text-align: center; }
                .container { background: white; padding: 20px; border-radius: 10px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Test HTML Document</h1>
                <p>This HTML will be converted to an image.</p>
            </div>
        </body>
        </html>
        """
        
        html_data = {
            'html': html_content,
            'options': {
                'format': 'png',
                'width': 800,
                'height': 600
            }
        }
        
        response = requests.post(f"{BASE_URL}/html-to-image", json=html_data)
        
        if response.status_code == 200:
            print("✅ HTML to Image conversion successful")
            with open('output.png', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.png")
        else:
            print(f"❌ HTML to Image failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ HTML to Image error: {e}")

def test_website_screenshot():
    """Test Website Screenshot functionality."""
    try:
        screenshot_data = {
            'url': 'https://example.com',
            'options': {
                'full_page': True,
                'format': 'png',
                'width': 1920,
                'height': 1080
            }
        }
        
        response = requests.post(f"{BASE_URL}/website-screenshot", json=screenshot_data)
        
        if response.status_code == 200:
            print("✅ Website Screenshot successful")
            with open('screenshot.png', 'wb') as f:
                f.write(response.content)
            print("Saved screenshot as screenshot.png")
        else:
            print(f"❌ Website Screenshot failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Website Screenshot error: {e}")

def test_html_validation():
    """Test HTML validation."""
    try:
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Valid HTML</title>
        </head>
        <body>
            <h1>Valid HTML Document</h1>
            <p>This is a valid HTML document.</p>
        </body>
        </html>
        """
        
        validation_data = {'html': html_content}
        
        response = requests.post(f"{BASE_URL}/validate-html", json=validation_data)
        
        if response.status_code == 200:
            print("✅ HTML validation successful")
            result = response.json()
            print(f"Validation result: {result}")
        else:
            print(f"❌ HTML validation failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ HTML validation error: {e}")

def test_css_extraction():
    """Test CSS extraction from HTML."""
    try:
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>HTML with CSS</title>
            <style>
                body { font-family: Arial; }
                h1 { color: blue; }
            </style>
        </head>
        <body>
            <h1>Styled Heading</h1>
            <p>This paragraph has styling.</p>
        </body>
        </html>
        """
        
        with open('test.html', 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        with open('test.html', 'rb') as f:
            files = {'file': ('test.html', f, 'text/html')}
            response = requests.post(f"{BASE_URL}/extract-css", files=files)
        
        if response.status_code == 200:
            print("✅ CSS extraction successful")
            css_data = response.json()
            print(f"Extracted CSS: {css_data}")
        else:
            print(f"❌ CSS extraction failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ CSS extraction error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [
        'test.html', 'output.pdf', 'output.png', 'screenshot.png'
    ]
    
    for file in test_files:
        if os.path.exists(file):
            os.remove(file)
            print(f"Cleaned up: {file}")

def main():
    """Run all tests."""
    print("🧪 Testing Website Conversion API")
    print("=" * 50)
    
    test_supported_formats()
    print()
    
    test_html_to_pdf()
    print()
    
    test_url_to_pdf()
    print()
    
    test_url_to_image()
    print()
    
    test_html_to_image()
    print()
    
    test_website_screenshot()
    print()
    
    test_html_validation()
    print()
    
    test_css_extraction()
    print()
    
    cleanup()
    print("✅ Website conversion tests completed!")

if __name__ == "__main__":
    main()
