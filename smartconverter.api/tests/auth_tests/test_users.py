#!/usr/bin/env python3
"""
Test script for Users functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/users"

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

def test_get_users():
    """Test getting all users."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(f"{BASE_URL}/", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get users successful")
            result = response.json()
            print(f"Users: {result}")
        else:
            print(f"❌ Get users failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get users error: {e}")

def test_get_user_by_id():
    """Test getting user by ID."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        user_id = 1  # Assuming user ID 1 exists
        response = requests.get(f"{BASE_URL}/{user_id}", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get user by ID successful")
            result = response.json()
            print(f"User: {result}")
        else:
            print(f"❌ Get user by ID failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get user by ID error: {e}")

def test_create_user():
    """Test creating a new user."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        user_data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'newpassword123',
            'full_name': 'New User',
            'is_active': True,
            'is_superuser': False
        }
        
        response = requests.post(f"{BASE_URL}/", json=user_data, headers=headers)
        
        if response.status_code == 200:
            print("✅ Create user successful")
            result = response.json()
            print(f"Created user: {result}")
        else:
            print(f"❌ Create user failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Create user error: {e}")

def test_update_user():
    """Test updating a user."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        user_id = 1  # Assuming user ID 1 exists
        update_data = {
            'full_name': 'Updated User Name',
            'is_active': True
        }
        
        response = requests.put(f"{BASE_URL}/{user_id}", json=update_data, headers=headers)
        
        if response.status_code == 200:
            print("✅ Update user successful")
            result = response.json()
            print(f"Updated user: {result}")
        else:
            print(f"❌ Update user failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Update user error: {e}")

def test_delete_user():
    """Test deleting a user."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        user_id = 2  # Assuming user ID 2 exists and can be deleted
        
        response = requests.delete(f"{BASE_URL}/{user_id}", headers=headers)
        
        if response.status_code == 200:
            print("✅ Delete user successful")
            result = response.json()
            print(f"Delete result: {result}")
        else:
            print(f"❌ Delete user failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Delete user error: {e}")

def test_get_user_profile():
    """Test getting user profile."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(f"{BASE_URL}/profile", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get user profile successful")
            result = response.json()
            print(f"User profile: {result}")
        else:
            print(f"❌ Get user profile failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get user profile error: {e}")

def test_update_user_profile():
    """Test updating user profile."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        profile_data = {
            'full_name': 'Updated Profile Name',
            'bio': 'This is my updated bio',
            'avatar_url': 'https://example.com/avatar.jpg'
        }
        
        response = requests.put(f"{BASE_URL}/profile", json=profile_data, headers=headers)
        
        if response.status_code == 200:
            print("✅ Update user profile successful")
            result = response.json()
            print(f"Updated profile: {result}")
        else:
            print(f"❌ Update user profile failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Update user profile error: {e}")

def test_get_user_stats():
    """Test getting user statistics."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(f"{BASE_URL}/stats", headers=headers)
        
        if response.status_code == 200:
            print("✅ Get user stats successful")
            result = response.json()
            print(f"User stats: {result}")
        else:
            print(f"❌ Get user stats failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Get user stats error: {e}")

def test_search_users():
    """Test searching users."""
    try:
        token = get_auth_token()
        if not token:
            print("❌ No auth token available")
            return
        
        headers = {'Authorization': f'Bearer {token}'}
        search_params = {'q': 'test', 'limit': 10}
        
        response = requests.get(f"{BASE_URL}/search", params=search_params, headers=headers)
        
        if response.status_code == 200:
            print("✅ Search users successful")
            result = response.json()
            print(f"Search results: {result}")
        else:
            print(f"❌ Search users failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Search users error: {e}")

def main():
    """Run all tests."""
    print("🧪 Testing Users API")
    print("=" * 50)
    
    test_get_users()
    print()
    
    test_get_user_by_id()
    print()
    
    test_create_user()
    print()
    
    test_update_user()
    print()
    
    test_delete_user()
    print()
    
    test_get_user_profile()
    print()
    
    test_update_user_profile()
    print()
    
    test_get_user_stats()
    print()
    
    test_search_users()
    print()
    
    print("✅ Users tests completed!")

if __name__ == "__main__":
    main()
