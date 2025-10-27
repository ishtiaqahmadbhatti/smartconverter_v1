#!/usr/bin/env python3
"""
Test script for file formatter functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/fileformattertools"
TEST_JSON_PATH = "test_data.json"
TEST_XML_PATH = "test_data.xml"
TEST_XSD_PATH = "test_schema.xsd"
TEST_JSON_SCHEMA_PATH = "test_schema.json"

def create_test_json():
    """Create a test JSON file."""
    json_data = {
        "name": "John Doe",
        "age": 30,
        "email": "john@example.com",
        "address": {
            "street": "123 Main St",
            "city": "New York",
            "state": "NY",
            "zip": "10001"
        },
        "hobbies": ["reading", "swimming", "coding"],
        "active": True
    }
    
    with open(TEST_JSON_PATH, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, indent=2)
    
    print(f"Created test JSON file: {TEST_JSON_PATH}")

def create_test_xml():
    """Create a test XML file."""
    xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<person>
    <name>John Doe</name>
    <age>30</age>
    <email>john@example.com</email>
    <address>
        <street>123 Main St</street>
        <city>New York</city>
        <state>NY</state>
        <zip>10001</zip>
    </address>
    <hobbies>
        <hobby>reading</hobby>
        <hobby>swimming</hobby>
        <hobby>coding</hobby>
    </hobbies>
    <active>true</active>
</person>"""
    
    with open(TEST_XML_PATH, 'w', encoding='utf-8') as f:
        f.write(xml_content)
    
    print(f"Created test XML file: {TEST_XML_PATH}")

def create_test_xsd():
    """Create a test XSD schema file."""
    xsd_content = """<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="person">
        <xs:complexType>
            <xs:sequence>
                <xs:element name="name" type="xs:string"/>
                <xs:element name="age" type="xs:int"/>
                <xs:element name="email" type="xs:string"/>
                <xs:element name="address">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="street" type="xs:string"/>
                            <xs:element name="city" type="xs:string"/>
                            <xs:element name="state" type="xs:string"/>
                            <xs:element name="zip" type="xs:string"/>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
                <xs:element name="hobbies">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="hobby" type="xs:string" maxOccurs="unbounded"/>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
                <xs:element name="active" type="xs:boolean"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
</xs:schema>"""
    
    with open(TEST_XSD_PATH, 'w', encoding='utf-8') as f:
        f.write(xsd_content)
    
    print(f"Created test XSD file: {TEST_XSD_PATH}")

def create_test_json_schema():
    """Create a test JSON schema file."""
    json_schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer", "minimum": 0},
            "email": {"type": "string", "format": "email"},
            "address": {
                "type": "object",
                "properties": {
                    "street": {"type": "string"},
                    "city": {"type": "string"},
                    "state": {"type": "string"},
                    "zip": {"type": "string"}
                },
                "required": ["street", "city", "state", "zip"]
            },
            "hobbies": {
                "type": "array",
                "items": {"type": "string"}
            },
            "active": {"type": "boolean"}
        },
        "required": ["name", "age", "email", "address", "hobbies", "active"]
    }
    
    with open(TEST_JSON_SCHEMA_PATH, 'w', encoding='utf-8') as f:
        json.dump(json_schema, f, indent=2)
    
    print(f"Created test JSON schema file: {TEST_JSON_SCHEMA_PATH}")

def test_supported_formats():
    """Test getting supported formats."""
    try:
        response = requests.get(f"{BASE_URL}/supported-formats")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported formats test passed")
            print(f"Supported formats: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Supported formats test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported formats test error: {e}")

def test_format_json():
    """Test JSON formatting."""
    try:
        if not os.path.exists(TEST_JSON_PATH):
            create_test_json()
        
        with open(TEST_JSON_PATH, 'rb') as f:
            files = {'file': f}
            data = {'indent': 4, 'sort_keys': True}
            response = requests.post(f"{BASE_URL}/format-json", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JSON formatting test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JSON formatting test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON formatting test error: {e}")

def test_validate_json():
    """Test JSON validation."""
    try:
        if not os.path.exists(TEST_JSON_PATH):
            create_test_json()
        
        with open(TEST_JSON_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/validate-json", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JSON validation test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JSON validation test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON validation test error: {e}")

def test_validate_json_with_schema():
    """Test JSON validation with schema."""
    try:
        if not os.path.exists(TEST_JSON_PATH):
            create_test_json()
        if not os.path.exists(TEST_JSON_SCHEMA_PATH):
            create_test_json_schema()
        
        with open(TEST_JSON_PATH, 'rb') as f, open(TEST_JSON_SCHEMA_PATH, 'rb') as s:
            files = {'file': f, 'schema_file': s}
            response = requests.post(f"{BASE_URL}/validate-json", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JSON validation with schema test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JSON validation with schema test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON validation with schema test error: {e}")

def test_validate_xml():
    """Test XML validation."""
    try:
        if not os.path.exists(TEST_XML_PATH):
            create_test_xml()
        
        with open(TEST_XML_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/validate-xml", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ XML validation test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ XML validation test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML validation test error: {e}")

def test_validate_xml_with_xsd():
    """Test XML validation with XSD."""
    try:
        if not os.path.exists(TEST_XML_PATH):
            create_test_xml()
        if not os.path.exists(TEST_XSD_PATH):
            create_test_xsd()
        
        with open(TEST_XML_PATH, 'rb') as f, open(TEST_XSD_PATH, 'rb') as s:
            files = {'file': f, 'xsd_file': s}
            response = requests.post(f"{BASE_URL}/validate-xml", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ XML validation with XSD test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ XML validation with XSD test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML validation with XSD test error: {e}")

def test_validate_xsd():
    """Test XSD validation."""
    try:
        if not os.path.exists(TEST_XSD_PATH):
            create_test_xsd()
        
        with open(TEST_XSD_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/validate-xsd", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ XSD validation test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ XSD validation test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XSD validation test error: {e}")

def test_minify_json():
    """Test JSON minification."""
    try:
        if not os.path.exists(TEST_JSON_PATH):
            create_test_json()
        
        with open(TEST_JSON_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/minify-json", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JSON minification test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JSON minification test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON minification test error: {e}")

def test_format_xml():
    """Test XML formatting."""
    try:
        if not os.path.exists(TEST_XML_PATH):
            create_test_xml()
        
        with open(TEST_XML_PATH, 'rb') as f:
            files = {'file': f}
            data = {'indent': 4}
            response = requests.post(f"{BASE_URL}/format-xml", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ XML formatting test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ XML formatting test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ XML formatting test error: {e}")

def test_json_schema_info():
    """Test JSON schema info."""
    try:
        if not os.path.exists(TEST_JSON_PATH):
            create_test_json()
        
        with open(TEST_JSON_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/json-schema-info", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ JSON schema info test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ JSON schema info test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ JSON schema info test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_JSON_PATH, TEST_XML_PATH, TEST_XSD_PATH, TEST_JSON_SCHEMA_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all file formatter tests."""
    print("🧪 Testing File Formatter API")
    print("=" * 50)
    
    # Test supported formats
    print("\n1. Testing supported formats...")
    test_supported_formats()
    
    # Test JSON formatting
    print("\n2. Testing JSON formatting...")
    test_format_json()
    
    # Test JSON validation
    print("\n3. Testing JSON validation...")
    test_validate_json()
    
    # Test JSON validation with schema
    print("\n4. Testing JSON validation with schema...")
    test_validate_json_with_schema()
    
    # Test XML validation
    print("\n5. Testing XML validation...")
    test_validate_xml()
    
    # Test XML validation with XSD
    print("\n6. Testing XML validation with XSD...")
    test_validate_xml_with_xsd()
    
    # Test XSD validation
    print("\n7. Testing XSD validation...")
    test_validate_xsd()
    
    # Test JSON minification
    print("\n8. Testing JSON minification...")
    test_minify_json()
    
    # Test XML formatting
    print("\n9. Testing XML formatting...")
    test_format_xml()
    
    # Test JSON schema info
    print("\n10. Testing JSON schema info...")
    test_json_schema_info()
    
    # Cleanup
    print("\n11. Cleaning up...")
    cleanup()
    
    print("\n✅ All file formatter tests completed!")

if __name__ == "__main__":
    main()
