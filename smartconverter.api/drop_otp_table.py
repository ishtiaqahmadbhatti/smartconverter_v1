from app.core.database import engine, Base
from sqlalchemy import text

def drop_otp_table():
    try:
        with engine.connect() as connection:
            connection.execute(text("DROP TABLE IF EXISTS password_reset_otps CASCADE"))
            connection.commit()
            print("Successfully dropped password_reset_otps table.")
    except Exception as e:
        print(f"Error dropping table: {e}")

if __name__ == "__main__":
    drop_otp_table()
