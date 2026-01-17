
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
import sys

# Add current directory to path so we can import app
sys.path.append(os.getcwd())

from app.core.config import settings
from app.models.user_list import UserList

def check_users():
    engine = create_engine(settings.get_database_url)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    users = db.query(UserList).all()
    print(f"Total Users: {len(users)}")
    for user in users:
        print(f"ID: {user.id}, Email: {user.email}, DeviceID: {user.device_id}")
    
    db.close()

if __name__ == "__main__":
    check_users()
