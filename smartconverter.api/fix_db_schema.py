import sys
import os
from sqlalchemy import text

# Add the current directory to sys.path
sys.path.append(os.getcwd())

from app.core.database import engine

def fix_schema():
    with engine.connect() as connection:
        # 1. Add missing columns
        print("Adding missing columns...")
        columns_to_add = [
            ("device_id", "VARCHAR(255)"),
            ("is_premium", "BOOLEAN DEFAULT FALSE"),
            ("subscription_plan", "VARCHAR(50) DEFAULT 'free'"),
            ("subscription_expiry", "TIMESTAMP WITH TIME ZONE")
        ]
        
        for col_name, col_type in columns_to_add:
            try:
                connection.execute(text(f"ALTER TABLE user_list ADD COLUMN IF NOT EXISTS {col_name} {col_type};"))
                print(f"Added column {col_name} (if it didn't exist).")
            except Exception as e:
                print(f"Error adding {col_name}: {e}")

        # 2. Make fields nullable
        print("Altering columns to be nullable...")
        nullable_columns = [
            "first_name", "last_name", "gender", "phone_number", "email", "password"
        ]
        for col_name in nullable_columns:
            try:
                connection.execute(text(f"ALTER TABLE user_list ALTER COLUMN {col_name} DROP NOT NULL;"))
                print(f"Made {col_name} nullable.")
            except Exception as e:
                print(f"Error making {col_name} nullable (might not exist or other error): {e}")

        connection.commit()
        print("Schema update complete.")

if __name__ == "__main__":
    try:
        fix_schema()
    except Exception as e:
        print(f"Update failed: {e}")
