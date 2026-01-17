import sys
import os

# Add parent directory to path to allow importing app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.models.user_conversion import UserConversionDetails
from app.services.conversion_log_service import ConversionLogService
from app.core.database import Base

def verify():
    print("Verifying conversion logging...")
    
    # Create engine
    engine = create_engine(settings.get_database_url)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        # Create tables
        Base.metadata.create_all(bind=engine)
        
        # Test 1: Log a conversion manually via service
        print("Logging a test conversion...")
        log = ConversionLogService.log_conversion(
            db=db,
            user_id=1, # Assume user 1 exists or just use 1
            conversion_type="test-conversion",
            input_filename="test.pdf",
            input_file_size=1024,
            ip_address="127.0.0.1",
            api_endpoint="/api/v1/test"
        )
        print(f"Log created: ID={log.id}")
        
        # Verify
        db_log = db.query(UserConversionDetails).filter(UserConversionDetails.id == log.id).first()
        if db_log:
            print(f"✓ Found log in DB: {db_log.conversion_type}, Status: {db_log.status}")
        else:
            print("✗ Log NOT found in DB!")
            return

        # Test 2: Update status
        print("Updating log status to 'success'...")
        updated_log = ConversionLogService.update_log_status(
            db=db,
            log_id=log.id,
            status="success",
            output_filename="test_output.json"
        )
        
        if updated_log and updated_log.status == "success":
            print(f"✓ Log updated successfully: {updated_log.output_filename}")
        else:
            print("✗ Log update failed!")

        # Cleanup test log
        db.delete(db_log)
        db.commit()
        print("Test log cleaned up.")
        
    except Exception as e:
        print(f"Error during verification: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    verify()
