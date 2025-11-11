#!/usr/bin/env python3
"""
Test script to debug FastAPI server issues
"""

import requests
import json
import sys

def test_server():
    base_url = "http://192.168.8.102:8003"
    
    print("=== FastAPI Server Debug Test ===")
    print(f"Testing server at: {base_url}")
    print("-" * 50)
    
    # Test 1: Server health
    try:
        response = requests.get(f"{base_url}/")
        print(f"✅ Server is running: {response.status_code}")
        print(f"📄 Response: {response.json()}")
    except Exception as e:
        print(f"❌ Server not accessible: {e}")
        return
    
    # Test 2: Health endpoint
    try:
        response = requests.get(f"{base_url}/api/v1/health/health")
        print(f"✅ Health check: {response.status_code}")
        print(f"📄 Health response: {response.json()}")
    except Exception as e:
        print(f"❌ Health check failed: {e}")
    
    # Test 3: Check downloads directory (if debug endpoint exists)
    try:
        response = requests.get(f"{base_url}/debug/files")
        print(f"📁 Downloads directory: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Directory: {data.get('output_dir')}")
            print(f"   Files: {data.get('files', [])}")
            print(f"   Count: {data.get('file_count', 0)}")
        else:
            print("   Debug endpoint not available")
    except Exception as e:
        print(f"   Debug endpoint not available: {e}")
    
    # Test 4: Test download endpoint
    test_filename = "test_file.pdf"
    try:
        response = requests.get(f"{base_url}/download/{test_filename}")
        print(f"📥 Download test: {response.status_code}")
        if response.status_code == 404:
            print("   ✅ Download endpoint exists (file not found - expected)")
        else:
            print(f"   Response: {response.text[:100]}...")
    except Exception as e:
        print(f"   Download test failed: {e}")
    
    # Test 5: Check specific file from logs
    log_filename = "7df6a93f-cda6-4982-8710-d9ab6d5d3140_numbered.pdf"
    try:
        response = requests.get(f"{base_url}/debug/check-file/{log_filename}")
        if response.status_code == 200:
            data = response.json()
            print(f"📄 File check for {log_filename}:")
            print(f"   Exists: {data.get('exists')}")
            print(f"   Path: {data.get('file_path')}")
            print(f"   Size: {data.get('size_kb')} KB")
        else:
            print(f"   Debug file check not available")
    except Exception as e:
        print(f"   Debug file check not available: {e}")
    
    print("\n" + "=" * 50)
    print("NEXT STEPS:")
    print("1. Check if your processing endpoint saves files")
    print("2. Verify the output directory path")
    print("3. Add debug endpoints to your server")
    print("4. Check server logs for errors")
    print("5. Test with a real file upload")

if __name__ == "__main__":
    test_server()
