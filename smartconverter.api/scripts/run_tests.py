#!/usr/bin/env python3
"""
Test runner script for TechMindsForge FastAPI.
"""

import subprocess
import sys
from pathlib import Path


def run_command(command, description):
    """Run a command and handle errors."""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed successfully")
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed:")
        print(e.stdout)
        print(e.stderr)
        return False


def main():
    """Main test runner function."""
    print("🧪 Running TechMindsForge FastAPI tests...")
    
    # Run linting
    print("\n📋 Running code quality checks...")
    run_command("flake8 app/ tests/", "Code linting with flake8")
    run_command("black --check app/ tests/", "Code formatting check with Black")
    run_command("isort --check-only app/ tests/", "Import sorting check with isort")
    
    # Run tests
    print("\n🧪 Running tests...")
    if not run_command("pytest tests/ -v", "Running pytest"):
        print("❌ Tests failed!")
        return False
    
    # Run tests with coverage
    print("\n📊 Running tests with coverage...")
    if not run_command("pytest tests/ --cov=app --cov-report=html --cov-report=term", "Running tests with coverage"):
        print("⚠️  Coverage report failed, but tests passed")
    
    print("\n✅ All tests completed!")
    return True


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
