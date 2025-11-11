#!/usr/bin/env python3
"""
Test script to verify FastAPI download endpoint
Run this to test if your download endpoint is working
"""

import requests
import sys

def test_download_endpoint():
    base_url = "http://192.168.8.102:8003"
    
    print("🧪 Testing FastAPI Download Endpoint")
    print(f"🔗 Base URL: {base_url}")
    print("-" * 50)
    
    # Test 1: Check if server is running
    try:
        response = requests.get(f"{base_url}/")
        print(f"✅ Server is running: {response.status_code}")
        print(f"📄 Response: {response.json()}")
    except Exception as e:
        print(f"❌ Server not accessible: {e}")
        return
    
    # Test 2: Check health endpoint
    try:
        response = requests.get(f"{base_url}/api/v1/health/health")
        print(f"✅ Health check: {response.status_code}")
        print(f"📄 Health response: {response.json()}")
    except Exception as e:
        print(f"❌ Health check failed: {e}")
    
    # Test 3: Test download endpoint with a non-existent file
    test_filename = "test_file.pdf"
    try:
        response = requests.get(f"{base_url}/download/{test_filename}")
        print(f"📥 Download test (non-existent file): {response.status_code}")
        if response.status_code == 404:
            print("✅ Download endpoint exists but file not found (expected)")
        else:
            print(f"📄 Response: {response.text[:200]}...")
    except Exception as e:
        print(f"❌ Download endpoint test failed: {e}")
    
    # Test 4: Check if downloads directory exists (if you can access server files)
    print("\n📋 Next Steps:")
    print("1. Make sure your FastAPI server is saving processed files to the output directory")
    print("2. Check that the filename in the API response matches the actual file")
    print("3. Verify the output directory path in your settings")
    print("4. Test with a real processed file")

if __name__ == "__main__":
    test_download_endpoint()
