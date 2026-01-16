from app.core.database import engine
from sqlalchemy import text

def drop_user_table():
    try:
        with engine.connect() as connection:
            connection.execute(text("DROP TABLE IF EXISTS user_list CASCADE"))
            connection.commit()
            print("Successfully dropped user_list table.")
    except Exception as e:
        print(f"Error dropping table: {e}")

if __name__ == "__main__":
    drop_user_table()
