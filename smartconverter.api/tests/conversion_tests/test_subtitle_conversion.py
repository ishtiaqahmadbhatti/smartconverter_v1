#!/usr/bin/env python3
"""
Test script for subtitle conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/subtitlesconversiontools"
TEST_SRT_PATH = "test_subtitles.srt"
TEST_VTT_PATH = "test_subtitles.vtt"
TEST_CSV_PATH = "test_subtitles.csv"

def create_test_srt():
    """Create a test SRT file."""
    srt_content = """1
00:00:01,000 --> 00:00:04,000
Hello, this is a test subtitle.

2
00:00:05,000 --> 00:00:08,000
This is the second subtitle line.

3
00:00:10,000 --> 00:00:13,000
And this is the third subtitle.
"""
    
    with open(TEST_SRT_PATH, 'w', encoding='utf-8') as f:
        f.write(srt_content)
    
    print(f"Created test SRT file: {TEST_SRT_PATH}")

def create_test_vtt():
    """Create a test VTT file."""
    vtt_content = """WEBVTT

00:00:01.000 --> 00:00:04.000
Hello, this is a test subtitle.

00:00:05.000 --> 00:00:08.000
This is the second subtitle line.

00:00:10.000 --> 00:00:13.000
And this is the third subtitle.
"""
    
    with open(TEST_VTT_PATH, 'w', encoding='utf-8') as f:
        f.write(vtt_content)
    
    print(f"Created test VTT file: {TEST_VTT_PATH}")

def create_test_csv():
    """Create a test CSV file."""
    csv_content = """Index,Start Time,End Time,Duration,Text
1,00:00:01,000,00:00:04,000,00:00:03,000,"Hello, this is a test subtitle."
2,00:00:05,000,00:00:08,000,00:00:03,000,"This is the second subtitle line."
3,00:00:10,000,00:00:13,000,00:00:03,000,"And this is the third subtitle."
"""
    
    with open(TEST_CSV_PATH, 'w', encoding='utf-8') as f:
        f.write(csv_content)
    
    print(f"Created test CSV file: {TEST_CSV_PATH}")

def test_supported_languages():
    """Test getting supported languages."""
    try:
        response = requests.get(f"{BASE_URL}/supported-languages")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported languages test passed")
            print(f"Supported languages: {len(data.get('languages', []))} languages")
        else:
            print(f"❌ Supported languages test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported languages test error: {e}")

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

def test_translate_srt():
    """Test SRT translation."""
    try:
        if not os.path.exists(TEST_SRT_PATH):
            create_test_srt()
        
        with open(TEST_SRT_PATH, 'rb') as f:
            files = {'file': f}
            data = {'target_language': 'es', 'source_language': 'en'}
            response = requests.post(f"{BASE_URL}/translate-srt", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SRT translation test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ SRT translation test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ SRT translation test error: {e}")

def test_srt_to_csv():
    """Test SRT to CSV conversion."""
    try:
        if not os.path.exists(TEST_SRT_PATH):
            create_test_srt()
        
        with open(TEST_SRT_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/srt-to-csv", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SRT to CSV conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ SRT to CSV conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ SRT to CSV conversion test error: {e}")

def test_srt_to_excel():
    """Test SRT to Excel conversion."""
    try:
        if not os.path.exists(TEST_SRT_PATH):
            create_test_srt()
        
        with open(TEST_SRT_PATH, 'rb') as f:
            files = {'file': f}
            data = {'format_type': 'xlsx'}
            response = requests.post(f"{BASE_URL}/srt-to-excel", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SRT to Excel conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ SRT to Excel conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ SRT to Excel conversion test error: {e}")

def test_srt_to_text():
    """Test SRT to text conversion."""
    try:
        if not os.path.exists(TEST_SRT_PATH):
            create_test_srt()
        
        with open(TEST_SRT_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/srt-to-text", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SRT to text conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ SRT to text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ SRT to text conversion test error: {e}")

def test_srt_to_vtt():
    """Test SRT to VTT conversion."""
    try:
        if not os.path.exists(TEST_SRT_PATH):
            create_test_srt()
        
        with open(TEST_SRT_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/srt-to-vtt", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SRT to VTT conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ SRT to VTT conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ SRT to VTT conversion test error: {e}")

def test_vtt_to_text():
    """Test VTT to text conversion."""
    try:
        if not os.path.exists(TEST_VTT_PATH):
            create_test_vtt()
        
        with open(TEST_VTT_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/vtt-to-text", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ VTT to text conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ VTT to text conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ VTT to text conversion test error: {e}")

def test_vtt_to_srt():
    """Test VTT to SRT conversion."""
    try:
        if not os.path.exists(TEST_VTT_PATH):
            create_test_vtt()
        
        with open(TEST_VTT_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/vtt-to-srt", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ VTT to SRT conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ VTT to SRT conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ VTT to SRT conversion test error: {e}")

def test_csv_to_srt():
    """Test CSV to SRT conversion."""
    try:
        if not os.path.exists(TEST_CSV_PATH):
            create_test_csv()
        
        with open(TEST_CSV_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/csv-to-srt", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ CSV to SRT conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ CSV to SRT conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ CSV to SRT conversion test error: {e}")

def test_excel_to_srt():
    """Test Excel to SRT conversion."""
    try:
        # Create a simple Excel file for testing
        import pandas as pd
        
        data = {
            'Start Time': ['00:00:01,000', '00:00:05,000', '00:00:10,000'],
            'End Time': ['00:00:04,000', '00:00:08,000', '00:00:13,000'],
            'Text': ['Hello, this is a test subtitle.', 'This is the second subtitle line.', 'And this is the third subtitle.']
        }
        
        df = pd.DataFrame(data)
        excel_path = "test_subtitles.xlsx"
        df.to_excel(excel_path, index=False)
        
        with open(excel_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/excel-to-srt", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Excel to SRT conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Excel to SRT conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
        
        # Clean up Excel file
        if os.path.exists(excel_path):
            os.remove(excel_path)
            
    except ImportError:
        print("⚠️ Excel to SRT test requires pandas - skipping")
    except Exception as e:
        print(f"❌ Excel to SRT conversion test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_SRT_PATH, TEST_VTT_PATH, TEST_CSV_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all subtitle conversion tests."""
    print("🧪 Testing Subtitle Conversion API")
    print("=" * 50)
    
    # Test supported languages
    print("\n1. Testing supported languages...")
    test_supported_languages()
    
    # Test supported formats
    print("\n2. Testing supported formats...")
    test_supported_formats()
    
    # Test SRT translation
    print("\n3. Testing SRT translation...")
    test_translate_srt()
    
    # Test SRT to CSV
    print("\n4. Testing SRT to CSV conversion...")
    test_srt_to_csv()
    
    # Test SRT to Excel
    print("\n5. Testing SRT to Excel conversion...")
    test_srt_to_excel()
    
    # Test SRT to text
    print("\n6. Testing SRT to text conversion...")
    test_srt_to_text()
    
    # Test SRT to VTT
    print("\n7. Testing SRT to VTT conversion...")
    test_srt_to_vtt()
    
    # Test VTT to text
    print("\n8. Testing VTT to text conversion...")
    test_vtt_to_text()
    
    # Test VTT to SRT
    print("\n9. Testing VTT to SRT conversion...")
    test_vtt_to_srt()
    
    # Test CSV to SRT
    print("\n10. Testing CSV to SRT conversion...")
    test_csv_to_srt()
    
    # Test Excel to SRT
    print("\n11. Testing Excel to SRT conversion...")
    test_excel_to_srt()
    
    # Cleanup
    print("\n12. Cleaning up...")
    cleanup()
    
    print("\n✅ All subtitle conversion tests completed!")

if __name__ == "__main__":
    main()
