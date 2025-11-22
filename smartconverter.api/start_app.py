#!/usr/bin/env python3
"""
Startup script for Smart Converter FastAPI
"""

import sys
import os

# Add current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def start_app():
    """Start the FastAPI application."""
    try:
        from app.main import app
        import uvicorn
        
        print("Starting Smart Converter FastAPI...")
        print("=" * 50)
        import sys as _sys
        print(f"Python executable: {_sys.executable}")
        print("Available endpoints:")
        print("- Main API: http://10.27.239.35:8000/")
        print("- API Documentation: http://10.27.239.35:8000/docs")
        print("- ReDoc Documentation: http://10.27.239.35:8000/redoc")
        print("- Health Check: http://10.27.239.35:8000/api/v1/health/")
        print("\nFor mobile device access:")
        print("- Physical Device: http://10.27.239.35:8000/")
        print("- Android Emulator: http://10.0.2.2:8000/ (from app)")
        print("- Mobile Docs: http://10.27.239.35:8000/docs")
        print("=" * 50)
        print("\nPDF Conversion Tools available at: /api/v1/pdfconversiontools/")
        print("General Conversion Tools available at: /api/v1/convert/")
        print("\nPress Ctrl+C to stop the server")
        print("=" * 50)
        
        # Start the server
        uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
        
    except Exception as e:
        print(f"Error starting application: {e}")
        return False
    
    return True

if __name__ == "__main__":
    start_app()
