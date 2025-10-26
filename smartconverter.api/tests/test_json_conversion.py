#!/usr/bin/env python3
"""
Comprehensive tests for JSON conversion APIs.
"""

import pytest
import json
import tempfile
import os
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


class TestJSONConversion:
    """Test class for JSON conversion endpoints."""
    
    def test_xml_to_json(self):
        """Test XML to JSON conversion."""
        xml_content = """
        <root>
            <person>
                <name>John Doe</name>
                <age>30</age>
                <city>New York</city>
            </person>
            <person>
                <name>Jane Smith</name>
                <age>25</age>
                <city>Los Angeles</city>
            </person>
        </root>
        """
        
        response = client.post(
            "/api/v1/convert/json/xml-to-json",
            json={"xml_content": xml_content}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert "person" in data["converted_data"]
    
    def test_json_to_xml(self):
        """Test JSON to XML conversion."""
        json_data = {
            "root": {
                "person": [
                    {"name": "John Doe", "age": 30, "city": "New York"},
                    {"name": "Jane Smith", "age": 25, "city": "Los Angeles"}
                ]
            }
        }
        
        response = client.post(
            "/api/v1/convert/json/json-to-xml",
            json={"json_data": json_data, "root_name": "root"}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert "<root>" in data["converted_data"]
    
    def test_json_formatter(self):
        """Test JSON formatting."""
        json_data = {"name": "John", "age": 30, "city": "New York"}
        
        response = client.post(
            "/api/v1/convert/json/json-formatter",
            json={"json_data": json_data}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        # Check if formatted JSON has proper indentation
        assert "\n" in data["converted_data"]
    
    def test_json_validator_valid(self):
        """Test JSON validation with valid JSON."""
        json_content = '{"name": "John", "age": 30}'
        
        response = client.post(
            "/api/v1/convert/json/json-validator",
            json={"json_content": json_content}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["valid"] is True
        assert "JSON is valid" in data["message"]
    
    def test_json_validator_invalid(self):
        """Test JSON validation with invalid JSON."""
        json_content = '{"name": "John", "age": 30,}'  # Trailing comma
        
        response = client.post(
            "/api/v1/convert/json/json-validator",
            json={"json_content": json_content}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["valid"] is False
        assert "Invalid JSON" in data["message"]
    
    def test_json_to_csv(self):
        """Test JSON to CSV conversion."""
        json_data = [
            {"name": "John", "age": 30, "city": "New York"},
            {"name": "Jane", "age": 25, "city": "Los Angeles"}
        ]
        
        response = client.post(
            "/api/v1/convert/json/json-to-csv",
            json={"json_data": json_data, "delimiter": ","}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert "name,age,city" in data["converted_data"]
    
    def test_json_to_excel(self):
        """Test JSON to Excel conversion."""
        json_data = [
            {"name": "John", "age": 30, "city": "New York"},
            {"name": "Jane", "age": 25, "city": "Los Angeles"}
        ]
        
        response = client.post(
            "/api/v1/convert/json/json-to-excel",
            json={"json_objects": json_data}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "output_filename" in data
        assert "download_url" in data
    
    def test_excel_to_json(self):
        """Test Excel to JSON conversion."""
        # Create a temporary Excel file
        import pandas as pd
        
        df = pd.DataFrame({
            'name': ['John', 'Jane'],
            'age': [30, 25],
            'city': ['New York', 'Los Angeles']
        })
        
        with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
            df.to_excel(tmp.name, index=False)
            tmp_path = tmp.name
        
        try:
            with open(tmp_path, 'rb') as f:
                response = client.post(
                    "/api/v1/convert/json/excel-to-json",
                    files={"file": ("test.xlsx", f, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")}
                )
            
            assert response.status_code == 200
            data = response.json()
            assert data["success"] is True
            assert "converted_data" in data
            assert "data" in data["converted_data"]
            assert len(data["converted_data"]["data"]) == 2
        
        finally:
            os.unlink(tmp_path)
    
    def test_csv_to_json(self):
        """Test CSV to JSON conversion."""
        csv_content = "name,age,city\nJohn,30,New York\nJane,25,Los Angeles"
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as tmp:
            tmp.write(csv_content)
            tmp_path = tmp.name
        
        try:
            with open(tmp_path, 'rb') as f:
                response = client.post(
                    "/api/v1/convert/json/csv-to-json",
                    files={"file": ("test.csv", f, "text/csv")},
                    data={"delimiter": ","}
                )
            
            assert response.status_code == 200
            data = response.json()
            assert data["success"] is True
            assert "converted_data" in data
            assert len(data["converted_data"]) == 2
        
        finally:
            os.unlink(tmp_path)
    
    def test_json_to_yaml(self):
        """Test JSON to YAML conversion."""
        json_data = {
            "name": "John",
            "age": 30,
            "city": "New York",
            "hobbies": ["reading", "swimming"]
        }
        
        response = client.post(
            "/api/v1/convert/json/json-to-yaml",
            json={"json_data": json_data}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert "name: John" in data["converted_data"]
    
    def test_yaml_to_json(self):
        """Test YAML to JSON conversion."""
        yaml_content = """
name: John
age: 30
city: New York
hobbies:
  - reading
  - swimming
        """
        
        response = client.post(
            "/api/v1/convert/json/yaml-to-json",
            json={"yaml_content": yaml_content}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert data["converted_data"]["name"] == "John"
        assert data["converted_data"]["age"] == 30
    
    def test_json_objects_to_csv(self):
        """Test JSON objects to CSV conversion."""
        json_objects = [
            {"name": "John", "age": 30, "city": "New York"},
            {"name": "Jane", "age": 25, "city": "Los Angeles"}
        ]
        
        response = client.post(
            "/api/v1/convert/json/json-objects-to-csv",
            json={"json_objects": json_objects, "delimiter": ","}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        assert "name,age,city" in data["converted_data"]
    
    def test_json_objects_to_excel(self):
        """Test JSON objects to Excel conversion."""
        json_objects = [
            {"name": "John", "age": 30, "city": "New York"},
            {"name": "Jane", "age": 25, "city": "Los Angeles"}
        ]
        
        response = client.post(
            "/api/v1/convert/json/json-objects-to-excel",
            json={"json_objects": json_objects}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "output_filename" in data
        assert "download_url" in data
    
    def test_invalid_xml(self):
        """Test XML to JSON with invalid XML."""
        invalid_xml = "<root><person>John</person><root>"  # Unclosed tag
        
        response = client.post(
            "/api/v1/convert/json/xml-to-json",
            json={"xml_content": invalid_xml}
        )
        
        assert response.status_code == 400
        data = response.json()
        assert data["detail"]["error_type"] == "FileProcessingError"
    
    def test_invalid_json_format(self):
        """Test JSON formatter with invalid JSON."""
        invalid_json = {"name": "John", "age": 30,}  # Trailing comma
        
        response = client.post(
            "/api/v1/convert/json/json-formatter",
            json={"json_data": invalid_json}
        )
        
        assert response.status_code == 400
        data = response.json()
        assert data["detail"]["error_type"] == "FileProcessingError"
    
    def test_empty_json_array(self):
        """Test JSON to CSV with empty array."""
        response = client.post(
            "/api/v1/convert/json/json-to-csv",
            json={"json_data": [], "delimiter": ","}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert data["converted_data"] == ""
    
    def test_large_json_data(self):
        """Test with large JSON data."""
        large_data = [{"id": i, "name": f"Person {i}", "value": i * 10} for i in range(1000)]
        
        response = client.post(
            "/api/v1/convert/json/json-to-csv",
            json={"json_data": large_data, "delimiter": ","}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "converted_data" in data
        # Should have 1001 lines (header + 1000 data rows)
        assert data["converted_data"].count('\n') == 1000


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
