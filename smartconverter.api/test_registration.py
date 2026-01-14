import requests
import json
import random
import string

def get_random_string(length):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def test_register():
    url = "http://127.0.0.1:8000/api/v1/auth/register-userlist"
    
    email = f"test_{get_random_string(5)}@example.com"
    password = "password123"
    
    payload = {
        "email": email,
        "password": password,
        "first_name": "Test",
        "last_name": "User",
        "device_id": f"DEVICE_{get_random_string(5)}"
    }
    
    print(f"Sending registration request for {email}...")
    try:
        response = requests.post(url, json=payload)
        print(f"Status Code: {response.status_code}")
        print("Response Body:")
        print(response.text)
    except Exception as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    test_register()
