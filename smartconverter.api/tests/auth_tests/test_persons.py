#!/usr/bin/env python3
"""
Test script for Persons functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/persons"

def get_auth_token():
    """Get authentication token for testing."""
    try:
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        response = requests.post("http://localhost:8000/api/v1/auth/login", data=login_data)
        
        if response.status_code == 200:
            result = response.json()
            return result.get('access_token')
        else:
            print(f"❌ Login failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def test_get_persons():
    """Test getting all persons."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(f"{BASE_URL}/", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get persons successful")
            result = response.json()
            print(f"Persons: {result}")
        else:
            print(f"❌ Get persons failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get persons error: {e}")

def test_get_person_by_id():
    """Test getting person by ID."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        person_id = 1  # Assuming person ID 1 exists
        response = requests.get(f"{BASE_URL}/{person_id}", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get person by ID successful")
            result = response.json()
            print(f"Person: {result}")
        else:
            print(f"❌ Get person by ID failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get person by ID error: {e}")

def test_create_person():
    """Test creating a new person."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        person_data = {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'phone': '+1234567890',
            'address': '123 Main St, City, State',
            'age': 30,
            'occupation': 'Software Engineer',
            'notes': 'Test person for API testing'
        }
        
        response = requests.post(f"{BASE_URL}/", json=person_data, headers=headers)
        
        if response.status_code == 200:
            print("✅ Create person successful")
            result = response.json()
            print(f"Created person: {result}")
        else:
            print(f"❌ Create person failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Create person error: {e}")

def test_update_person():
    """Test updating a person."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        person_id = 1  # Assuming person ID 1 exists
        update_data = {
            'name': 'John Updated Doe',
            'phone': '+1234567891',
            'notes': 'Updated notes for testing'
        }
        
        response = requests.put(f"{BASE_URL}/{person_id}", json=update_data, headers=headers)
        
        if response.status_code == 200:
            print("✅ Update person successful")
            result = response.json()
            print(f"Updated person: {result}")
        else:
            print(f"❌ Update person failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Update person error: {e}")

def test_delete_person():
    """Test deleting a person."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        person_id = 2  # Assuming person ID 2 exists and can be deleted
        
        response = requests.delete(f"{BASE_URL}/{person_id}", headers=headers)
        
        if response.status_code == 200:
            print("✅ Delete person successful")
            result = response.json()
            print(f"Delete result: {result}")
        else:
            print(f"❌ Delete person failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Delete person error: {e}")

def test_search_persons():
    """Test searching persons."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        search_params = {'q': 'John', 'limit': 10}
        
        response = requests.get(f"{BASE_URL}/search", params=search_params, headers=headers)
        
        if response.status_code == 200:
            print("✅ Search persons successful")
            result = response.json()
            print(f"Search results: {result}")
        else:
            print(f"❌ Search persons failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Search persons error: {e}")

def test_get_persons_by_age():
    """Test getting persons by age range."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        age_params = {'min_age': 25, 'max_age': 35}
        
        response = requests.get(f"{BASE_URL}/by-age", params=age_params, headers=headers)
        
        if response.status_code == 200:
            print("✅ Get persons by age successful")
            result = response.json()
            print(f"Persons by age: {result}")
        else:
            print(f"❌ Get persons by age failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get persons by age error: {e}")

def test_get_persons_by_occupation():
    """Test getting persons by occupation."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        occupation_params = {'occupation': 'Software Engineer'}
        
        response = requests.get(f"{BASE_URL}/by-occupation", params=occupation_params, headers=headers)
        
        if response.status_code == 200:
            print("✅ Get persons by occupation successful")
            result = response.json()
            print(f"Persons by occupation: {result}")
        else:
            print(f"❌ Get persons by occupation failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get persons by occupation error: {e}")

def test_export_persons():
    """Test exporting persons to CSV."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(f"{BASE_URL}/export/csv", headers=headers)
        
        if response.status_code == 200:
            print("✅ Export persons to CSV successful")
            with open('persons_export.csv', 'wb') as f:
                f.write(response.content)
            print("Saved export as persons_export.csv")
        else:
            print(f"❌ Export persons to CSV failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Export persons to CSV error: {e}")

def test_import_persons():
    """Test importing persons from CSV."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        # Create test CSV file
        csv_content = """name,email,phone,age,occupation
Jane Smith,jane.smith@example.com,+1234567892,28,Designer
Bob Johnson,bob.johnson@example.com,+1234567893,32,Manager"""
        
        with open('test_import.csv', 'w') as f:
            f.write(csv_content)
        
        headers = {'Authorization': f'Bearer {token}'}
        with open('test_import.csv', 'rb') as f:
            files = {'file': ('test_import.csv', f, 'text/csv')}
            response = requests.post(f"{BASE_URL}/import/csv", files=files, headers=headers)
        
        if response.status_code == 200:
            print("✅ Import persons from CSV successful")
            result = response.json()
            print(f"Import result: {result}")
        else:
            print(f"❌ Import persons from CSV failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Import persons from CSV error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = ['persons_export.csv', 'test_import.csv']
    
    for file in test_files:
        if os.path.exists(file):
            os.remove(file)
            print(f"Cleaned up: {file}")

def main():
    """Run all tests."""
    print("🧪 Testing Persons API")
    print("=" * 50)
    
    test_get_persons()
    print()
    
    test_get_person_by_id()
    print()
    
    test_create_person()
    print()
    
    test_update_person()
    print()
    
    test_delete_person()
    print()
    
    test_search_persons()
    print()
    
    test_get_persons_by_age()
    print()
    
    test_get_persons_by_occupation()
    print()
    
    test_export_persons()
    print()
    
    test_import_persons()
    print()
    
    cleanup()
    print("✅ Persons tests completed!")

if __name__ == "__main__":
    main()
