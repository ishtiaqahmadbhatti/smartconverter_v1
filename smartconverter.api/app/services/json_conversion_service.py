import json
import xml.etree.ElementTree as ET
import csv
import yaml
import pandas as pd
import io
import os
from typing import Dict, List, Any, Optional, Union
from datetime import datetime
from app.core.exceptions import FileProcessingError
from app.services.file_service import FileService
from app.services.request_logging_service import RequestLoggingService


class JSONConversionService:
    """Service for handling JSON conversion operations."""
    
    @staticmethod
    def xml_to_json(xml_content: str) -> Dict[str, Any]:
        """Convert XML string to JSON."""
        try:
            # Parse XML
            root = ET.fromstring(xml_content)
            
            # Convert to dictionary
            def xml_to_dict(element):
                result = {}
                
                # Add attributes
                if element.attrib:
                    result['@attributes'] = element.attrib
                
                # Add text content if present
                if element.text and element.text.strip():
                    if len(element) == 0:  # Leaf node
                        return element.text.strip()
                    else:
                        result['#text'] = element.text.strip()
                
                # Process children
                children = {}
                for child in element:
                    child_data = xml_to_dict(child)
                    if child.tag in children:
                        if not isinstance(children[child.tag], list):
                            children[child.tag] = [children[child.tag]]
                        children[child.tag].append(child_data)
                    else:
                        children[child.tag] = child_data
                
                result.update(children)
                return result
            
            return xml_to_dict(root)
            
        except ET.ParseError as e:
            raise FileProcessingError(f"Invalid XML format: {str(e)}")
        except Exception as e:
            raise FileProcessingError(f"XML to JSON conversion failed: {str(e)}")
    
    @staticmethod
    def json_to_xml(json_data: Dict[str, Any], root_name: str = "root") -> str:
        """Convert JSON to XML string."""
        try:
            def dict_to_xml(data, root):
                if isinstance(data, dict):
                    for key, value in data.items():
                        if key == '@attributes':
                            root.attrib.update(value)
                        elif key == '#text':
                            root.text = str(value)
                        else:
                            if isinstance(value, list):
                                for item in value:
                                    child = ET.SubElement(root, key)
                                    dict_to_xml(item, child)
                            else:
                                child = ET.SubElement(root, key)
                                dict_to_xml(value, child)
                else:
                    root.text = str(data)
            
            root = ET.Element(root_name)
            dict_to_xml(json_data, root)
            
            # Convert to string
            return ET.tostring(root, encoding='unicode')
            
        except Exception as e:
            raise FileProcessingError(f"JSON to XML conversion failed: {str(e)}")
    
    @staticmethod
    def format_json(json_data: Union[str, Dict, List]) -> str:
        """Format JSON with proper indentation."""
        try:
            if isinstance(json_data, str):
                parsed = json.loads(json_data)
            else:
                parsed = json_data
            
            return json.dumps(parsed, indent=2, ensure_ascii=False)
            
        except json.JSONDecodeError as e:
            raise FileProcessingError(f"Invalid JSON format: {str(e)}")
        except Exception as e:
            raise FileProcessingError(f"JSON formatting failed: {str(e)}")
    
    @staticmethod
    def validate_json(json_data: str) -> Dict[str, Any]:
        """Validate JSON and return validation result."""
        try:
            parsed = json.loads(json_data)
            return {
                "valid": True,
                "message": "JSON is valid",
                "size": len(json_data),
                "structure": JSONConversionService._analyze_structure(parsed)
            }
        except json.JSONDecodeError as e:
            return {
                "valid": False,
                "message": f"Invalid JSON: {str(e)}",
                "error_line": getattr(e, 'lineno', None),
                "error_column": getattr(e, 'colno', None)
            }
        except Exception as e:
            return {
                "valid": False,
                "message": f"Validation error: {str(e)}"
            }
    
    @staticmethod
    def json_to_csv(json_data: Union[Dict, List], delimiter: str = ",") -> str:
        """Convert JSON to CSV format."""
        try:
            if isinstance(json_data, str):
                data = json.loads(json_data)
            else:
                data = json_data
            
            if isinstance(data, list):
                if not data:
                    return ""
                
                # Get all unique keys
                all_keys = set()
                for item in data:
                    if isinstance(item, dict):
                        all_keys.update(item.keys())
                
                # Create CSV
                output = io.StringIO()
                writer = csv.DictWriter(output, fieldnames=sorted(all_keys), delimiter=delimiter)
                writer.writeheader()
                
                for item in data:
                    if isinstance(item, dict):
                        writer.writerow(item)
                
                return output.getvalue()
            else:
                raise FileProcessingError("JSON must be an array of objects for CSV conversion")
                
        except Exception as e:
            raise FileProcessingError(f"JSON to CSV conversion failed: {str(e)}")
    
    @staticmethod
    def json_to_excel(json_data: Union[Dict, List], filename: str = None) -> str:
        """Convert JSON to Excel file."""
        try:
            if isinstance(json_data, str):
                data = json.loads(json_data)
            else:
                data = json_data
            
            if filename is None:
                filename = f"converted_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            
            output_path = FileService.get_output_path(filename, ".xlsx")
            
            if isinstance(data, list):
                df = pd.DataFrame(data)
            elif isinstance(data, dict):
                # Convert dict to list of records
                if all(isinstance(v, (list, tuple)) for v in data.values()):
                    # If all values are lists, treat as columns
                    df = pd.DataFrame(data)
                else:
                    # Single record
                    df = pd.DataFrame([data])
            else:
                raise FileProcessingError("Unsupported JSON structure for Excel conversion")
            
            df.to_excel(output_path, index=False)
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"JSON to Excel conversion failed: {str(e)}")
    
    @staticmethod
    def excel_to_json(file_path: str) -> Dict[str, Any]:
        """Convert Excel file to JSON."""
        try:
            # Read Excel file
            df = pd.read_excel(file_path)
            
            # Convert to JSON
            result = {
                "data": df.to_dict('records'),
                "columns": df.columns.tolist(),
                "shape": df.shape,
                "info": {
                    "rows": len(df),
                    "columns": len(df.columns)
                }
            }
            
            return result
            
        except Exception as e:
            raise FileProcessingError(f"Excel to JSON conversion failed: {str(e)}")
    
    @staticmethod
    def csv_to_json(csv_content: str, delimiter: str = ",") -> List[Dict[str, Any]]:
        """Convert CSV string to JSON."""
        try:
            # Parse CSV
            csv_reader = csv.DictReader(io.StringIO(csv_content), delimiter=delimiter)
            data = list(csv_reader)
            
            return data
            
        except Exception as e:
            raise FileProcessingError(f"CSV to JSON conversion failed: {str(e)}")
    
    @staticmethod
    def json_to_yaml(json_data: Union[Dict, List]) -> str:
        """Convert JSON to YAML."""
        try:
            if isinstance(json_data, str):
                data = json.loads(json_data)
            else:
                data = json_data
            
            return yaml.dump(data, default_flow_style=False, allow_unicode=True)
            
        except Exception as e:
            raise FileProcessingError(f"JSON to YAML conversion failed: {str(e)}")
    
    @staticmethod
    def yaml_to_json(yaml_content: str) -> Dict[str, Any]:
        """Convert YAML to JSON."""
        try:
            data = yaml.safe_load(yaml_content)
            return data
            
        except yaml.YAMLError as e:
            raise FileProcessingError(f"Invalid YAML format: {str(e)}")
        except Exception as e:
            raise FileProcessingError(f"YAML to JSON conversion failed: {str(e)}")
    
    @staticmethod
    def json_objects_to_csv(json_data: List[Dict], delimiter: str = ",") -> str:
        """Convert JSON objects array to CSV."""
        try:
            if not isinstance(json_data, list):
                raise FileProcessingError("Input must be a list of JSON objects")
            
            if not json_data:
                return ""
            
            # Get all unique keys
            all_keys = set()
            for item in json_data:
                if isinstance(item, dict):
                    all_keys.update(item.keys())
            
            # Create CSV
            output = io.StringIO()
            writer = csv.DictWriter(output, fieldnames=sorted(all_keys), delimiter=delimiter)
            writer.writeheader()
            
            for item in json_data:
                if isinstance(item, dict):
                    writer.writerow(item)
            
            return output.getvalue()
            
        except Exception as e:
            raise FileProcessingError(f"JSON objects to CSV conversion failed: {str(e)}")
    
    @staticmethod
    def json_objects_to_excel(json_data: List[Dict], filename: str = None) -> str:
        """Convert JSON objects array to Excel."""
        try:
            if not isinstance(json_data, list):
                raise FileProcessingError("Input must be a list of JSON objects")
            
            if filename is None:
                filename = f"converted_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            
            output_path = FileService.get_output_path(filename, ".xlsx")
            
            df = pd.DataFrame(json_data)
            df.to_excel(output_path, index=False)
            
            return output_path
            
        except Exception as e:
            raise FileProcessingError(f"JSON objects to Excel conversion failed: {str(e)}")
    
    @staticmethod
    def _analyze_structure(data: Any) -> Dict[str, Any]:
        """Analyze JSON structure."""
        if isinstance(data, dict):
            return {
                "type": "object",
                "keys": list(data.keys()),
                "size": len(data)
            }
        elif isinstance(data, list):
            return {
                "type": "array",
                "length": len(data),
                "item_types": list(set(type(item).__name__ for item in data)) if data else []
            }
        else:
            return {
                "type": type(data).__name__,
                "value": str(data)[:100] if len(str(data)) > 100 else str(data)
            }
    
    @staticmethod
    def log_conversion(conversion_type: str, input_data: str, output_data: str, 
                      success: bool, error_message: str = None, user_id: str = None):
        """Log conversion operation to database."""
        try:
            RequestLoggingService.log_request(
                endpoint=f"/api/v1/convert/json/{conversion_type}",
                method="POST",
                user_id=user_id,
                request_data={"conversion_type": conversion_type},
                response_data={
                    "success": success,
                    "input_size": len(input_data) if input_data else 0,
                    "output_size": len(output_data) if output_data else 0,
                    "error_message": error_message
                },
                status_code=200 if success else 400
            )
        except Exception as e:
            print(f"Warning: Failed to log conversion: {str(e)}")
    
    @staticmethod
    def cleanup_temp_files(*file_paths: str) -> None:
        """Clean up temporary files."""
        for file_path in file_paths:
            FileService.cleanup_file(file_path)
