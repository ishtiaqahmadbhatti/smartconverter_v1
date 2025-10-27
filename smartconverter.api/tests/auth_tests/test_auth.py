#!/usr/bin/env python3
"""
Test script for Authentication functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/auth"

def test_register():
    """Test user registration."""
    try:
        user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpassword123',
            'full_name': 'Test User'
        }
        
        response = requests.post(f"{BASE_URL}/register", json=user_data)
        
        if response.status_code == 200:
            print("✅ User registration successful")
            result = response.json()
            print(f"Registration result: {result}")
        else:
            print(f"❌ User registration failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ User registration error: {e}")

def test_login():
    """Test user login."""
    try:
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if response.status_code == 200:
            print("✅ User login successful")
            result = response.json()
            print(f"Login result: {result}")
            return result.get('access_token')
        else:
            print(f"❌ User login failed: {response.status_code}")
            print(f"Error: {response.text}")
            return None
    except Exception as e:
        print(f"❌ User login error: {e}")
        return None

def test_refresh_token():
    """Test token refresh."""
    try:
        # First login to get a token
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        login_response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            refresh_token = login_result.get('refresh_token')
            
            if refresh_token:
                refresh_data = {'refresh_token': refresh_token}
                response = requests.post(f"{BASE_URL}/refresh", json=refresh_data)
                
                if response.status_code == 200:
                    print("✅ Token refresh successful")
                    result = response.json()
                    print(f"Refresh result: {result}")
                else:
                    print(f"❌ Token refresh failed: {response.status_code}")
                    print(f"Error: {response.text}")
            else:
                print("❌ No refresh token available")
        else:
            print("❌ Login failed, cannot test refresh")
    except Exception as e:
        print(f"❌ Token refresh error: {e}")

def test_logout():
    """Test user logout."""
    try:
        # First login to get a token
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        login_response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            access_token = login_result.get('access_token')
            
            if access_token:
                headers = {'Authorization': f'Bearer {access_token}'}
                response = requests.post(f"{BASE_URL}/logout", headers=headers)
                
                if response.status_code == 200:
                    print("✅ User logout successful")
                    result = response.json()
                    print(f"Logout result: {result}")
                else:
                    print(f"❌ User logout failed: {response.status_code}")
                    print(f"Error: {response.text}")
            else:
                print("❌ No access token available")
        else:
            print("❌ Login failed, cannot test logout")
    except Exception as e:
        print(f"❌ User logout error: {e}")

def test_get_current_user():
    """Test getting current user info."""
    try:
        # First login to get a token
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        login_response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            access_token = login_result.get('access_token')
            
            if access_token:
                headers = {'Authorization': f'Bearer {access_token}'}
                response = requests.get(f"{BASE_URL}/me", headers=headers)
                
                if response.status_code == 200:
                    print("✅ Get current user successful")
                    result = response.json()
                    print(f"Current user: {result}")
                else:
                    print(f"❌ Get current user failed: {response.status_code}")
                    print(f"Error: {response.text}")
            else:
                print("❌ No access token available")
        else:
            print("❌ Login failed, cannot test get current user")
    except Exception as e:
        print(f"❌ Get current user error: {e}")

def test_change_password():
    """Test password change."""
    try:
        # First login to get a token
        login_data = {
            'username': 'testuser',
            'password': 'testpassword123'
        }
        
        login_response = requests.post(f"{BASE_URL}/login", data=login_data)
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            access_token = login_result.get('access_token')
            
            if access_token:
                headers = {'Authorization': f'Bearer {access_token}'}
                password_data = {
                    'current_password': 'testpassword123',
                    'new_password': 'newpassword123'
                }
                
                response = requests.post(f"{BASE_URL}/change-password", json=password_data, headers=headers)
                
                if response.status_code == 200:
                    print("✅ Password change successful")
                    result = response.json()
                    print(f"Password change result: {result}")
                else:
                    print(f"❌ Password change failed: {response.status_code}")
                    print(f"Error: {response.text}")
            else:
                print("❌ No access token available")
        else:
            print("❌ Login failed, cannot test password change")
    except Exception as e:
        print(f"❌ Password change error: {e}")

def test_forgot_password():
    """Test forgot password."""
    try:
        forgot_data = {'email': 'test@example.com'}
        
        response = requests.post(f"{BASE_URL}/forgot-password", json=forgot_data)
        
        if response.status_code == 200:
            print("✅ Forgot password successful")
            result = response.json()
            print(f"Forgot password result: {result}")
        else:
            print(f"❌ Forgot password failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Forgot password error: {e}")

def test_reset_password():
    """Test password reset."""
    try:
        reset_data = {
            'token': 'test_reset_token',
            'new_password': 'newpassword123'
        }
        
        response = requests.post(f"{BASE_URL}/reset-password", json=reset_data)
        
        if response.status_code == 200:
            print("✅ Password reset successful")
            result = response.json()
            print(f"Password reset result: {result}")
        else:
            print(f"❌ Password reset failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Password reset error: {e}")

def test_oauth_google():
    """Test Google OAuth."""
    try:
        oauth_data = {'code': 'test_google_code'}
        
        response = requests.post(f"{BASE_URL}/oauth/google", json=oauth_data)
        
        if response.status_code == 200:
            print("✅ Google OAuth successful")
            result = response.json()
            print(f"Google OAuth result: {result}")
        else:
            print(f"❌ Google OAuth failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Google OAuth error: {e}")

def test_oauth_github():
    """Test GitHub OAuth."""
    try:
        oauth_data = {'code': 'test_github_code'}
        
        response = requests.post(f"{BASE_URL}/oauth/github", json=oauth_data)
        
        if response.status_code == 200:
            print("✅ GitHub OAuth successful")
            result = response.json()
            print(f"GitHub OAuth result: {result}")
        else:
            print(f"❌ GitHub OAuth failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ GitHub OAuth error: {e}")

def test_oauth_microsoft():
    """Test Microsoft OAuth."""
    try:
        oauth_data = {'code': 'test_microsoft_code'}
        
        response = requests.post(f"{BASE_URL}/oauth/microsoft", json=oauth_data)
        
        if response.status_code == 200:
            print("✅ Microsoft OAuth successful")
            result = response.json()
            print(f"Microsoft OAuth result: {result}")
        else:
            print(f"❌ Microsoft OAuth failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Microsoft OAuth error: {e}")

def main():
    """Run all tests."""
    print("🧪 Testing Authentication API")
    print("=" * 50)
    
    test_register()
    print()
    
    test_login()
    print()
    
    test_refresh_token()
    print()
    
    test_logout()
    print()
    
    test_get_current_user()
    print()
    
    test_change_password()
    print()
    
    test_forgot_password()
    print()
    
    test_reset_password()
    print()
    
    test_oauth_google()
    print()
    
    test_oauth_github()
    print()
    
    test_oauth_microsoft()
    print()
    
    print("✅ Authentication tests completed!")

if __name__ == "__main__":
    main()
