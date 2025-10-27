#!/usr/bin/env python3
"""
API Health Check Test Script
This script tests the API health endpoint to verify PostgreSQL connectivity.
"""

import requests
import json
import sys
import time

def test_api_health(base_url="http://localhost:8000"):
    """Test the API health endpoint."""
    print("🔍 Testing API Health Endpoint...")
    print(f"🌐 API URL: {base_url}/api/v1/health")
    print("-" * 50)
    
    try:
        # Make request to health endpoint
        response = requests.get(f"{base_url}/api/v1/health", timeout=10)
        
        if response.status_code == 200:
            health_data = response.json()
            
            print("✅ API is responding!")
            print(f"📊 Status: {health_data.get('status', 'unknown')}")
            print(f"🏷️  App Name: {health_data.get('app_name', 'unknown')}")
            print(f"🔢 Version: {health_data.get('version', 'unknown')}")
            print(f"⏱️  Uptime: {health_data.get('uptime', 'unknown')} seconds")
            
            # Check database status
            database_info = health_data.get('database', {})
            if database_info:
                db_status = database_info.get('status', 'unknown')
                if db_status == 'connected':
                    print("✅ Database: Connected to PostgreSQL!")
                else:
                    print(f"❌ Database: {db_status}")
                    if database_info.get('error'):
                        print(f"🔍 Database Error: {database_info['error']}")
            else:
                print("⚠️  No database information available")
            
            return health_data.get('status') == 'healthy'
            
        else:
            print(f"❌ API returned status code: {response.status_code}")
            print(f"📄 Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to API. Make sure the server is running!")
        print("💡 Start the server with: uvicorn app.main:app --reload")
        return False
    except requests.exceptions.Timeout:
        print("❌ API request timed out!")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def main():
    """Main function to run the API health test."""
    print("🚀 API Health Check Test")
    print("=" * 50)
    
    # Allow custom base URL
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
    
    success = test_api_health(base_url)
    
    print("-" * 50)
    if success:
        print("🎉 API health check passed! Your API is connected to PostgreSQL.")
        sys.exit(0)
    else:
        print("💥 API health check failed.")
        print("\n📝 Troubleshooting tips:")
        print("1. Make sure your FastAPI server is running")
        print("2. Check if PostgreSQL is running and accessible")
        print("3. Verify your .env file configuration")
        print("4. Check the server logs for errors")
        sys.exit(1)

if __name__ == "__main__":
    main()
