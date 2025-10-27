#!/usr/bin/env python3
"""
Test script for CSV conversion functionality.
"""

import requests
import os
import json
import tempfile
import pandas as pd

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/csvconversiontools"

def create_test_csv():
    """Create test CSV files."""
    try:
        # Create test data
        data = {
            'Name': ['John Doe', 'Jane Smith', 'Bob Johnson'],
            'Age': [25, 30, 35],
            'City': ['New York', 'Los Angeles', 'Chicago'],
            'Salary': [50000, 60000, 70000]
        }
        
        df = pd.DataFrame(data)
        df.to_csv('test_data.csv', index=False)
        print("Created test CSV file: test_data.csv")
        
    except ImportError:
        print("⚠️ pandas not available - creating dummy CSV file")
        with open('test_data.csv', 'w') as f:
            f.write("Name,Age,City,Salary\n")
            f.write("John Doe,25,New York,50000\n")
            f.write("Jane Smith,30,Los Angeles,60000\n")
            f.write("Bob Johnson,35,Chicago,70000\n")

def test_supported_formats():
    """Test getting supported formats."""
    try:
        response = requests.get(f"{BASE_URL}/supported-formats")
        if response.status_code == 200:
            print("✅ Supported formats endpoint working")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Supported formats failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported formats error: {e}")

def test_csv_to_excel():
    """Test CSV to Excel conversion."""
    try:
        create_test_csv()
        
        with open('test_data.csv', 'rb') as f:
            files = {'file': ('test_data.csv', f, 'text/csv')}
            response = requests.post(f"{BASE_URL}/csv-to-excel", files=files)
        
        if response.status_code == 200:
            print("✅ CSV to Excel conversion successful")
            with open('output.xlsx', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.xlsx")
        else:
            print(f"❌ CSV to Excel failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ CSV to Excel error: {e}")

def test_csv_to_json():
    """Test CSV to JSON conversion."""
    try:
        create_test_csv()
        
        with open('test_data.csv', 'rb') as f:
            files = {'file': ('test_data.csv', f, 'text/csv')}
            response = requests.post(f"{BASE_URL}/csv-to-json", files=files)
        
        if response.status_code == 200:
            print("✅ CSV to JSON conversion successful")
            json_data = response.json()
            print(f"JSON data: {json_data}")
        else:
            print(f"❌ CSV to JSON failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ CSV to JSON error: {e}")

def test_excel_to_csv():
    """Test Excel to CSV conversion."""
    try:
        # First create an Excel file
        data = {
            'Name': ['Alice', 'Bob', 'Charlie'],
            'Score': [85, 92, 78]
        }
        df = pd.DataFrame(data)
        df.to_excel('test_input.xlsx', index=False)
        
        with open('test_input.xlsx', 'rb') as f:
            files = {'file': ('test_input.xlsx', f, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')}
            response = requests.post(f"{BASE_URL}/excel-to-csv", files=files)
        
        if response.status_code == 200:
            print("✅ Excel to CSV conversion successful")
            with open('output.csv', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.csv")
        else:
            print(f"❌ Excel to CSV failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Excel to CSV error: {e}")

def test_json_to_csv():
    """Test JSON to CSV conversion."""
    try:
        json_data = [
            {"name": "Product A", "price": 100, "category": "Electronics"},
            {"name": "Product B", "price": 200, "category": "Books"},
            {"name": "Product C", "price": 150, "category": "Clothing"}
        ]
        
        with open('test_data.json', 'w') as f:
            json.dump(json_data, f)
        
        with open('test_data.json', 'rb') as f:
            files = {'file': ('test_data.json', f, 'application/json')}
            response = requests.post(f"{BASE_URL}/json-to-csv", files=files)
        
        if response.status_code == 200:
            print("✅ JSON to CSV conversion successful")
            with open('output.csv', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.csv")
        else:
            print(f"❌ JSON to CSV failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON to CSV error: {e}")

def test_csv_validation():
    """Test CSV validation."""
    try:
        create_test_csv()
        
        with open('test_data.csv', 'rb') as f:
            files = {'file': ('test_data.csv', f, 'text/csv')}
            response = requests.post(f"{BASE_URL}/validate-csv", files=files)
        
        if response.status_code == 200:
            print("✅ CSV validation successful")
            result = response.json()
            print(f"Validation result: {result}")
        else:
            print(f"❌ CSV validation failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ CSV validation error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [
        'test_data.csv', 'test_input.xlsx', 'test_data.json',
        'output.xlsx', 'output.csv'
    ]
    
    for file in test_files:
        if os.path.exists(file):
            os.remove(file)
            print(f"Cleaned up: {file}")

def main():
    """Run all tests."""
    print("🧪 Testing CSV Conversion API")
    print("=" * 50)
    
    test_supported_formats()
    print()
    
    test_csv_to_excel()
    print()
    
    test_csv_to_json()
    print()
    
    test_excel_to_csv()
    print()
    
    test_json_to_csv()
    print()
    
    test_csv_validation()
    print()
    
    cleanup()
    print("✅ CSV conversion tests completed!")

if __name__ == "__main__":
    main()
