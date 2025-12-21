from app.core.database import engine, Base
from sqlalchemy import text

def reset_user_list():
    """Drop and recreate the UserList table."""
    try:
        with engine.connect() as connection:
            print("Dropping UserList table...")
            connection.execute(text('DROP TABLE IF EXISTS "UserList" CASCADE'))
            connection.commit()
            print("Table dropped successfully.")
            
        print("Recreating tables...")
        from app.models.user_list import UserList
        Base.metadata.create_all(bind=engine)
        print("UserList table recreated successfully.")
    except Exception as e:
        print(f"Error resetting table: {e}")

if __name__ == "__main__":
    reset_user_list()
