#!/usr/bin/env python3
"""
Simple test script to debug FastAPI server
"""

import requests
import json

def test_server():
    base_url = "http://192.168.8.100:8003"
    
    print("=== FastAPI Server Test ===")
    print(f"Testing server at: {base_url}")
    print("-" * 50)
    
    # Test 1: Server health
    try:
        response = requests.get(f"{base_url}/")
        print(f"Server is running: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Server not accessible: {e}")
        return
    
    # Test 2: Health endpoint
    try:
        response = requests.get(f"{base_url}/api/v1/health/health")
        print(f"Health check: {response.status_code}")
        print(f"Health response: {response.json()}")
    except Exception as e:
        print(f"Health check failed: {e}")
    
    # Test 3: Test download endpoint
    test_filename = "test_file.pdf"
    try:
        response = requests.get(f"{base_url}/download/{test_filename}")
        print(f"Download test: {response.status_code}")
        if response.status_code == 404:
            print("Download endpoint exists (file not found - expected)")
        else:
            print(f"Response: {response.text[:100]}...")
    except Exception as e:
        print(f"Download test failed: {e}")
    
    print("\n" + "=" * 50)
    print("NEXT STEPS:")
    print("1. Check if your processing endpoint saves files")
    print("2. Verify the output directory path")
    print("3. Check server logs for errors")

if __name__ == "__main__":
    test_server()
