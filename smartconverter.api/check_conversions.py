
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
import sys

# Add current directory to path so we can import app
sys.path.append(os.getcwd())

from app.core.config import settings
from app.models.user_conversion import UserConversionDetails

def check_conversions():
    engine = create_engine(settings.get_database_url)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    conversions = db.query(UserConversionDetails).order_by(UserConversionDetails.created_at.desc()).limit(10).all()
    print(f"Latest 10 Conversions:")
    for c in conversions:
        print(f"ID: {c.id}, UserID: {c.user_id}, Type: {c.conversion_type}, Status: {c.status}, IP: {c.ip_address}, UA: {c.user_agent[:50]}...")
    
    db.close()

if __name__ == "__main__":
    check_conversions()
