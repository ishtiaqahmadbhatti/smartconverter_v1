#!/usr/bin/env python3
"""
Test script for XML conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/xmlconversiontools"

def create_test_xml():
    """Create test XML files."""
    xml_content = '''<?xml version="1.0" encoding="UTF-8"?>
<employees>
    <employee id="1">
        <name>John Doe</name>
        <age>25</age>
        <department>IT</department>
        <salary>50000</salary>
    </employee>
    <employee id="2">
        <name>Jane Smith</name>
        <age>30</age>
        <department>HR</department>
        <salary>60000</salary>
    </employee>
    <employee id="3">
        <name>Bob Johnson</name>
        <age>35</age>
        <department>Finance</department>
        <salary>70000</salary>
    </employee>
</employees>'''
    
    with open('test_data.xml', 'w', encoding='utf-8') as f:
        f.write(xml_content)
    print("Created test XML file: test_data.xml")

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

def test_xml_to_json():
    """Test XML to JSON conversion."""
    try:
        create_test_xml()
        
        with open('test_data.xml', 'rb') as f:
            files = {'file': ('test_data.xml', f, 'application/xml')}
            response = requests.post(f"{BASE_URL}/xml-to-json", files=files)
        
        if response.status_code == 200:
            print("✅ XML to JSON conversion successful")
            json_data = response.json()
            print(f"JSON data: {json_data}")
        else:
            print(f"❌ XML to JSON failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML to JSON error: {e}")

def test_xml_to_csv():
    """Test XML to CSV conversion."""
    try:
        create_test_xml()
        
        with open('test_data.xml', 'rb') as f:
            files = {'file': ('test_data.xml', f, 'application/xml')}
            response = requests.post(f"{BASE_URL}/xml-to-csv", files=files)
        
        if response.status_code == 200:
            print("✅ XML to CSV conversion successful")
            with open('output.csv', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.csv")
        else:
            print(f"❌ XML to CSV failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML to CSV error: {e}")

def test_json_to_xml():
    """Test JSON to XML conversion."""
    try:
        json_data = {
            "products": [
                {"id": 1, "name": "Laptop", "price": 999, "category": "Electronics"},
                {"id": 2, "name": "Book", "price": 29, "category": "Education"},
                {"id": 3, "name": "Phone", "price": 699, "category": "Electronics"}
            ]
        }
        
        with open('test_data.json', 'w') as f:
            json.dump(json_data, f)
        
        with open('test_data.json', 'rb') as f:
            files = {'file': ('test_data.json', f, 'application/json')}
            response = requests.post(f"{BASE_URL}/json-to-xml", files=files)
        
        if response.status_code == 200:
            print("✅ JSON to XML conversion successful")
            with open('output.xml', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.xml")
        else:
            print(f"❌ JSON to XML failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON to XML error: {e}")

def test_xml_validation():
    """Test XML validation."""
    try:
        create_test_xml()
        
        with open('test_data.xml', 'rb') as f:
            files = {'file': ('test_data.xml', f, 'application/xml')}
            response = requests.post(f"{BASE_URL}/validate-xml", files=files)
        
        if response.status_code == 200:
            print("✅ XML validation successful")
            result = response.json()
            print(f"Validation result: {result}")
        else:
            print(f"❌ XML validation failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML validation error: {e}")

def test_xml_transform():
    """Test XML transformation."""
    try:
        create_test_xml()
        
        # Create XSLT transformation
        xslt_content = '''<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <body>
                <h2>Employee List</h2>
                <table border="1">
                    <tr>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Department</th>
                        <th>Salary</th>
                    </tr>
                    <xsl:for-each select="employees/employee">
                        <tr>
                            <td><xsl:value-of select="name"/></td>
                            <td><xsl:value-of select="age"/></td>
                            <td><xsl:value-of select="department"/></td>
                            <td><xsl:value-of select="salary"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>'''
        
        with open('transform.xslt', 'w', encoding='utf-8') as f:
            f.write(xslt_content)
        
        with open('test_data.xml', 'rb') as xml_file, open('transform.xslt', 'rb') as xslt_file:
            files = {
                'xml_file': ('test_data.xml', xml_file, 'application/xml'),
                'xslt_file': ('transform.xslt', xslt_file, 'application/xml')
            }
            response = requests.post(f"{BASE_URL}/transform-xml", files=files)
        
        if response.status_code == 200:
            print("✅ XML transformation successful")
            with open('output.html', 'wb') as f:
                f.write(response.content)
            print("Saved output as output.html")
        else:
            print(f"❌ XML transformation failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML transformation error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [
        'test_data.xml', 'test_data.json', 'transform.xslt',
        'output.csv', 'output.xml', 'output.html'
    ]
    
    for file in test_files:
        if os.path.exists(file):
            os.remove(file)
            print(f"Cleaned up: {file}")

def main():
    """Run all tests."""
    print("🧪 Testing XML Conversion API")
    print("=" * 50)
    
    test_supported_formats()
    print()
    
    test_xml_to_json()
    print()
    
    test_xml_to_csv()
    print()
    
    test_json_to_xml()
    print()
    
    test_xml_validation()
    print()
    
    test_xml_transform()
    print()
    
    cleanup()
    print("✅ XML conversion tests completed!")

if __name__ == "__main__":
    main()
