#!/usr/bin/env python3
"""
Test script for general Conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/convert"

def test_supported_conversions():
    """Test getting supported conversions."""
    try:
        response = requests.get(f"{BASE_URL}/supported-conversions")
        if response.status_code == 200:
            print("✅ Supported conversions endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Supported conversions failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported conversions error: {e}")

def test_conversion_status():
    """Test getting conversion status."""
    try:
        conversion_id = "test-conversion-id"
        response = requests.get(f"{BASE_URL}/status/{conversion_id}")
        
        if response.status_code == 200:
            print("✅ Conversion status endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Conversion status failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion status error: {e}")

def test_batch_conversion():
    """Test batch conversion."""
    try:
        # Create test files
        test_files = []
        for i in range(3):
            filename = f'test_file_{i}.txt'
            with open(filename, 'w') as f:
                f.write(f'Test content for file {i}')
            test_files.append(filename)
        
        files = []
        for filename in test_files:
            with open(filename, 'rb') as f:
                files.append(('files', (filename, f, 'text/plain')))
        
        conversion_data = {
            'target_format': 'pdf',
            'options': {
                'quality': 'high',
                'compression': False
            }
        }
        
        response = requests.post(f"{BASE_URL}/batch", files=files, data=conversion_data)
        
        if response.status_code == 200:
            print("✅ Batch conversion successful")
            result = response.json()
            print(f"Batch conversion result: {result}")
        else:
            print(f"❌ Batch conversion failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Batch conversion error: {e}")
    finally:
        # Cleanup test files
        for filename in test_files:
            if os.path.exists(filename):
                os.remove(filename)

def test_conversion_history():
    """Test getting conversion history."""
    try:
        params = {
            'limit': 10,
            'offset': 0,
            'format': 'pdf'
        }
        
        response = requests.get(f"{BASE_URL}/history", params=params)
        
        if response.status_code == 200:
            print("✅ Conversion history endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Conversion history failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion history error: {e}")

def test_conversion_analytics():
    """Test getting conversion analytics."""
    try:
        params = {
            'period': '30d',
            'format': 'pdf'
        }
        
        response = requests.get(f"{BASE_URL}/analytics", params=params)
        
        if response.status_code == 200:
            print("✅ Conversion analytics endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Conversion analytics failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion analytics error: {e}")

def test_conversion_queue():
    """Test conversion queue management."""
    try:
        # Get queue status
        response = requests.get(f"{BASE_URL}/queue/status")
        
        if response.status_code == 200:
            print("✅ Conversion queue status endpoint working")
            print(f"Queue status: {response.json()}")
        else:
            print(f"❌ Conversion queue status failed: {response.status_code}")
        
        # Clear queue
        response = requests.post(f"{BASE_URL}/queue/clear")
        
        if response.status_code == 200:
            print("✅ Conversion queue clear successful")
            print(f"Clear result: {response.json()}")
        else:
            print(f"❌ Conversion queue clear failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion queue error: {e}")

def test_conversion_settings():
    """Test conversion settings."""
    try:
        # Get current settings
        response = requests.get(f"{BASE_URL}/settings")
        
        if response.status_code == 200:
            print("✅ Get conversion settings successful")
            print(f"Settings: {response.json()}")
        else:
            print(f"❌ Get conversion settings failed: {response.status_code}")
        
        # Update settings
        settings_data = {
            'default_quality': 'high',
            'max_file_size': 10485760,  # 10MB
            'allowed_formats': ['pdf', 'docx', 'txt'],
            'auto_cleanup': True
        }
        
        response = requests.put(f"{BASE_URL}/settings", json=settings_data)
        
        if response.status_code == 200:
            print("✅ Update conversion settings successful")
            print(f"Updated settings: {response.json()}")
        else:
            print(f"❌ Update conversion settings failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion settings error: {e}")

def test_conversion_health():
    """Test conversion service health."""
    try:
        response = requests.get(f"{BASE_URL}/health")
        
        if response.status_code == 200:
            print("✅ Conversion health check successful")
            print(f"Health status: {response.json()}")
        else:
            print(f"❌ Conversion health check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion health check error: {e}")

def test_conversion_metrics():
    """Test conversion metrics."""
    try:
        response = requests.get(f"{BASE_URL}/metrics")
        
        if response.status_code == 200:
            print("✅ Conversion metrics endpoint working")
            print(f"Metrics: {response.json()}")
        else:
            print(f"❌ Conversion metrics failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion metrics error: {e}")

def test_conversion_limits():
    """Test conversion limits."""
    try:
        response = requests.get(f"{BASE_URL}/limits")
        
        if response.status_code == 200:
            print("✅ Conversion limits endpoint working")
            print(f"Limits: {response.json()}")
        else:
            print(f"❌ Conversion limits failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Conversion limits error: {e}")

def main():
    """Run all tests."""
    print("🧪 Testing Conversion API")
    print("=" * 50)
    
    test_supported_conversions()
    print()
    
    test_conversion_status()
    print()
    
    test_batch_conversion()
    print()
    
    test_conversion_history()
    print()
    
    test_conversion_analytics()
    print()
    
    test_conversion_queue()
    print()
    
    test_conversion_settings()
    print()
    
    test_conversion_health()
    print()
    
    test_conversion_metrics()
    print()
    
    test_conversion_limits()
    print()
    
    print("✅ Conversion tests completed!")

if __name__ == "__main__":
    main()
