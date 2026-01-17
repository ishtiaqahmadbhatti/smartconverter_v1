
import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add the parent directory to sys.path to import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.config import settings

def dump_conversions():
    engine = create_engine(settings.get_database_url)
    Session = sessionmaker(bind=engine)
    session = Session()
    
    try:
        query = text("SELECT id, conversion_type, status, user_id, ip_address, user_agent, created_at FROM user_conversion_details ORDER BY id DESC LIMIT 50")
        result = session.execute(query)
        
        print(f"{'ID':<5} | {'Type':<15} | {'Status':<10} | {'User':<5} | {'IP':<15} | {'UA'}")
        print("-" * 100)
        
        for row in result:
            ua = row.user_agent[:40] if row.user_agent else "None"
            print(f"{row.id:<5} | {row.conversion_type:<15} | {row.status:<10} | {str(row.user_id):<5} | {str(row.ip_address):<15} | {ua}")
            
    finally:
        session.close()

if __name__ == "__main__":
    dump_conversions()
