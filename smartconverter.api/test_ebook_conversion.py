#!/usr/bin/env python3
"""
Test script for eBook conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/ebookconversiontools"
TEST_MARKDOWN_PATH = "test_book.md"
TEST_EPUB_PATH = "test_book.epub"
TEST_MOBI_PATH = "test_book.mobi"
TEST_AZW_PATH = "test_book.azw"
TEST_PDF_PATH = "test_book.pdf"
TEST_FB2_PATH = "test_book.fb2"

def create_test_markdown():
    """Create a test Markdown file."""
    markdown_content = """# My Test Book

## Chapter 1: Introduction

This is a test book created for eBook conversion testing.

### Features

- **Bold text** for emphasis
- *Italic text* for style
- `Code snippets` for examples

### Code Example

```python
def hello_world():
    print("Hello, World!")
```

## Chapter 2: Content

This chapter contains more content to test the conversion process.

### Lists

1. First item
2. Second item
3. Third item

### Tables

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |

## Conclusion

This is the end of our test book.
"""
    
    with open(TEST_MARKDOWN_PATH, 'w', encoding='utf-8') as f:
        f.write(markdown_content)
    
    print(f"Created test Markdown file: {TEST_MARKDOWN_PATH}")

def create_test_epub():
    """Create a test ePUB file."""
    try:
        from ebooklib import epub
        
        book = epub.EpubBook()
        book.set_identifier('test-book-id')
        book.set_title('Test Book')
        book.set_language('en')
        book.add_author('Test Author')
        
        # Add chapter
        chapter = epub.EpubHtml(title='Chapter 1', file_name='chapter1.xhtml', lang='en')
        chapter.content = '<h1>Chapter 1</h1><p>This is a test chapter.</p>'
        book.add_item(chapter)
        
        book.spine = ['nav', chapter]
        book.toc = [chapter]
        book.add_item(epub.EpubNcx())
        book.add_item(epub.EpubNav())
        
        epub.write_epub(TEST_EPUB_PATH, book, {})
        print(f"Created test ePUB file: {TEST_EPUB_PATH}")
    except ImportError:
        print("⚠️ ebooklib not available - creating dummy ePUB file")
        with open(TEST_EPUB_PATH, 'w') as f:
            f.write("dummy epub content")

def create_test_mobi():
    """Create a test MOBI file."""
    with open(TEST_MOBI_PATH, 'wb') as f:
        f.write(b"dummy mobi content")
    print(f"Created test MOBI file: {TEST_MOBI_PATH}")

def create_test_azw():
    """Create a test AZW file."""
    with open(TEST_AZW_PATH, 'wb') as f:
        f.write(b"dummy azw content")
    print(f"Created test AZW file: {TEST_AZW_PATH}")

def create_test_pdf():
    """Create a test PDF file."""
    try:
        from reportlab.pdfgen import canvas
        from reportlab.lib.pagesizes import letter
        
        c = canvas.Canvas(TEST_PDF_PATH, pagesize=letter)
        c.drawString(100, 750, "Test Book")
        c.drawString(100, 700, "This is a test PDF for eBook conversion.")
        c.drawString(100, 650, "Chapter 1: Introduction")
        c.drawString(100, 600, "This is the content of our test book.")
        c.save()
        
        print(f"Created test PDF file: {TEST_PDF_PATH}")
    except ImportError:
        print("⚠️ ReportLab not available - creating dummy PDF file")
        with open(TEST_PDF_PATH, 'wb') as f:
            f.write(b"dummy pdf content")

def create_test_fb2():
    """Create a test FB2 file."""
    fb2_content = """<?xml version="1.0" encoding="utf-8"?>
<FictionBook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0">
    <description>
        <title-info>
            <book-title>Test Book</book-title>
            <author>
                <first-name>Test</first-name>
                <last-name>Author</last-name>
            </author>
        </title-info>
    </description>
    <body>
        <title>
            <p>Test Book</p>
        </title>
        <section>
            <title>
                <p>Chapter 1</p>
            </title>
            <p>This is a test chapter.</p>
        </section>
    </body>
</FictionBook>"""
    
    with open(TEST_FB2_PATH, 'w', encoding='utf-8') as f:
        f.write(fb2_content)
    
    print(f"Created test FB2 file: {TEST_FB2_PATH}")

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

def test_markdown_to_epub():
    """Test Markdown to ePUB conversion."""
    try:
        if not os.path.exists(TEST_MARKDOWN_PATH):
            create_test_markdown()
        
        with open(TEST_MARKDOWN_PATH, 'rb') as f:
            files = {'file': f}
            data = {'title': 'Test Book', 'author': 'Test Author'}
            response = requests.post(f"{BASE_URL}/markdown-to-epub", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Markdown to ePUB conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Markdown to ePUB conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Markdown to ePUB conversion test error: {e}")

def test_epub_to_mobi():
    """Test ePUB to MOBI conversion."""
    try:
        if not os.path.exists(TEST_EPUB_PATH):
            create_test_epub()
        
        with open(TEST_EPUB_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/epub-to-mobi", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ ePUB to MOBI conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ ePUB to MOBI conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ ePUB to MOBI conversion test error: {e}")

def test_epub_to_azw():
    """Test ePUB to AZW conversion."""
    try:
        if not os.path.exists(TEST_EPUB_PATH):
            create_test_epub()
        
        with open(TEST_EPUB_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/epub-to-azw", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ ePUB to AZW conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ ePUB to AZW conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ ePUB to AZW conversion test error: {e}")

def test_mobi_to_epub():
    """Test MOBI to ePUB conversion."""
    try:
        if not os.path.exists(TEST_MOBI_PATH):
            create_test_mobi()
        
        with open(TEST_MOBI_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/mobi-to-epub", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MOBI to ePUB conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MOBI to ePUB conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MOBI to ePUB conversion test error: {e}")

def test_mobi_to_azw():
    """Test MOBI to AZW conversion."""
    try:
        if not os.path.exists(TEST_MOBI_PATH):
            create_test_mobi()
        
        with open(TEST_MOBI_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/mobi-to-azw", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MOBI to AZW conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MOBI to AZW conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MOBI to AZW conversion test error: {e}")

def test_azw_to_epub():
    """Test AZW to ePUB conversion."""
    try:
        if not os.path.exists(TEST_AZW_PATH):
            create_test_azw()
        
        with open(TEST_AZW_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/azw-to-epub", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ AZW to ePUB conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ AZW to ePUB conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ AZW to ePUB conversion test error: {e}")

def test_azw_to_mobi():
    """Test AZW to MOBI conversion."""
    try:
        if not os.path.exists(TEST_AZW_PATH):
            create_test_azw()
        
        with open(TEST_AZW_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/azw-to-mobi", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ AZW to MOBI conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ AZW to MOBI conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ AZW to MOBI conversion test error: {e}")

def test_epub_to_pdf():
    """Test ePUB to PDF conversion."""
    try:
        if not os.path.exists(TEST_EPUB_PATH):
            create_test_epub()
        
        with open(TEST_EPUB_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/epub-to-pdf", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ ePUB to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ ePUB to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ ePUB to PDF conversion test error: {e}")

def test_mobi_to_pdf():
    """Test MOBI to PDF conversion."""
    try:
        if not os.path.exists(TEST_MOBI_PATH):
            create_test_mobi()
        
        with open(TEST_MOBI_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/mobi-to-pdf", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MOBI to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MOBI to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MOBI to PDF conversion test error: {e}")

def test_azw_to_pdf():
    """Test AZW to PDF conversion."""
    try:
        if not os.path.exists(TEST_AZW_PATH):
            create_test_azw()
        
        with open(TEST_AZW_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/azw-to-pdf", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ AZW to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ AZW to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ AZW to PDF conversion test error: {e}")

def test_fb2_to_pdf():
    """Test FB2 to PDF conversion."""
    try:
        if not os.path.exists(TEST_FB2_PATH):
            create_test_fb2()
        
        with open(TEST_FB2_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/fb2-to-pdf", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ FB2 to PDF conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ FB2 to PDF conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ FB2 to PDF conversion test error: {e}")

def test_pdf_to_epub():
    """Test PDF to ePUB conversion."""
    try:
        if not os.path.exists(TEST_PDF_PATH):
            create_test_pdf()
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/pdf-to-epub", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF to ePUB conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PDF to ePUB conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF to ePUB conversion test error: {e}")

def test_pdf_to_mobi():
    """Test PDF to MOBI conversion."""
    try:
        if not os.path.exists(TEST_PDF_PATH):
            create_test_pdf()
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/pdf-to-mobi", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF to MOBI conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PDF to MOBI conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF to MOBI conversion test error: {e}")

def test_pdf_to_azw():
    """Test PDF to AZW conversion."""
    try:
        if not os.path.exists(TEST_PDF_PATH):
            create_test_pdf()
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/pdf-to-azw", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF to AZW conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PDF to AZW conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF to AZW conversion test error: {e}")

def test_pdf_to_fb2():
    """Test PDF to FB2 conversion."""
    try:
        if not os.path.exists(TEST_PDF_PATH):
            create_test_pdf()
        
        with open(TEST_PDF_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/pdf-to-fb2", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ PDF to FB2 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ PDF to FB2 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ PDF to FB2 conversion test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_MARKDOWN_PATH, TEST_EPUB_PATH, TEST_MOBI_PATH, TEST_AZW_PATH, TEST_PDF_PATH, TEST_FB2_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all eBook conversion tests."""
    print("🧪 Testing eBook Conversion API")
    print("=" * 50)
    
    # Test supported formats
    print("\n1. Testing supported formats...")
    test_supported_formats()
    
    # Test Markdown to ePUB
    print("\n2. Testing Markdown to ePUB conversion...")
    test_markdown_to_epub()
    
    # Test ePUB conversions
    print("\n3. Testing ePUB to MOBI conversion...")
    test_epub_to_mobi()
    
    print("\n4. Testing ePUB to AZW conversion...")
    test_epub_to_azw()
    
    print("\n5. Testing ePUB to PDF conversion...")
    test_epub_to_pdf()
    
    # Test MOBI conversions
    print("\n6. Testing MOBI to ePUB conversion...")
    test_mobi_to_epub()
    
    print("\n7. Testing MOBI to AZW conversion...")
    test_mobi_to_azw()
    
    print("\n8. Testing MOBI to PDF conversion...")
    test_mobi_to_pdf()
    
    # Test AZW conversions
    print("\n9. Testing AZW to ePUB conversion...")
    test_azw_to_epub()
    
    print("\n10. Testing AZW to MOBI conversion...")
    test_azw_to_mobi()
    
    print("\n11. Testing AZW to PDF conversion...")
    test_azw_to_pdf()
    
    # Test FB2 conversions
    print("\n12. Testing FB2 to PDF conversion...")
    test_fb2_to_pdf()
    
    # Test PDF conversions
    print("\n13. Testing PDF to ePUB conversion...")
    test_pdf_to_epub()
    
    print("\n14. Testing PDF to MOBI conversion...")
    test_pdf_to_mobi()
    
    print("\n15. Testing PDF to AZW conversion...")
    test_pdf_to_azw()
    
    print("\n16. Testing PDF to FB2 conversion...")
    test_pdf_to_fb2()
    
    # Cleanup
    print("\n17. Cleaning up...")
    cleanup()
    
    print("\n✅ All eBook conversion tests completed!")

if __name__ == "__main__":
    main()
