#!/usr/bin/env python3
"""
Development setup script for TechMindsForge FastAPI.
This script helps set up the development environment.
"""

import os
import sys
import subprocess
from pathlib import Path


def run_command(command, description):
    """Run a command and handle errors."""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed: {e.stderr}")
        return False


def create_directories():
    """Create necessary directories."""
    directories = ["uploads", "outputs", "logs"]
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
        print(f"📁 Created directory: {directory}")


def setup_environment():
    """Set up environment file."""
    env_file = Path(".env")
    env_example = Path(".env.example")
    
    if not env_file.exists() and env_example.exists():
        env_file.write_text(env_example.read_text())
        print("📝 Created .env file from .env.example")
    elif not env_file.exists():
        # Create basic .env file
        env_content = """# Application Settings
APP_NAME=Smart Convert API
APP_VERSION=1.0.0
DEBUG=True

# Server Configuration
HOST=127.0.0.1
PORT=8000

# File Upload Settings
UPLOAD_DIR=uploads
OUTPUT_DIR=outputs
MAX_FILE_SIZE=52428800  # 50MB

# OCR Settings (Windows)
TESSERACT_PATH=C:\\Program Files\\Tesseract-OCR\\tesseract.exe
"""
        env_file.write_text(env_content)
        print("📝 Created basic .env file")


def main():
    """Main setup function."""
    print("🚀 Setting up TechMindsForge FastAPI development environment...")
    
    # Create directories
    create_directories()
    
    # Setup environment
    setup_environment()
    
    # Install dependencies
    if not run_command("pip install -r requirements.txt", "Installing dependencies"):
        print("❌ Failed to install dependencies. Please check your Python environment.")
        return False
    
    # Install development dependencies
    if not run_command("pip install -e .[dev]", "Installing development dependencies"):
        print("⚠️  Development dependencies installation failed, but continuing...")
    
    # Run code formatting
    print("🎨 Running code formatting...")
    run_command("black app/ tests/", "Code formatting with Black")
    run_command("isort app/ tests/", "Import sorting with isort")
    
    print("\n✅ Development environment setup completed!")
    print("\n📋 Next steps:")
    print("1. Update .env file with your configuration")
    print("2. Install Tesseract OCR for image-to-text functionality")
    print("3. Run the application: python -m app.main")
    print("4. Access the API docs at: http://127.0.0.1:8000/docs")
    
    return True


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
