import sys
import os

# Add the current directory to sys.path
sys.path.append(os.getcwd())

try:
    print("Attempting to import app.main...")
    # Trying to import the main api router which imports everything
    from app.api.v1.api import api_router
    print("Import successful!")
    
    from app.services.auth_service import authenticate_user
    print("Auth service imported.")
    
except Exception as e:
    print(f"Import failed: {e}")
    sys.exit(1)
