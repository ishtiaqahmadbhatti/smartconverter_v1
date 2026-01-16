from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from app.core.config import settings
from pydantic import EmailStr
from typing import List

class EmailService:
    # Configure connection
    conf = ConnectionConfig(
        MAIL_USERNAME=settings.MAIL_USERNAME,
        MAIL_PASSWORD=settings.MAIL_PASSWORD,
        MAIL_FROM=settings.MAIL_FROM,
        MAIL_PORT=settings.MAIL_PORT,
        MAIL_SERVER=settings.MAIL_SERVER,
        MAIL_STARTTLS=settings.MAIL_STARTTLS,
        MAIL_SSL_TLS=settings.MAIL_SSL_TLS,
        USE_CREDENTIALS=settings.USE_CREDENTIALS,
        VALIDATE_CERTS=settings.VALIDATE_CERTS
    )

    @staticmethod
    async def send_password_reset_email(email: EmailStr, new_password: str):
        """
        Send an email with the new password.
        """
        html = f"""
        <html>
            <body style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
                <h2 style="color: #00D4FF;">SmartConverter Password Reset</h2>
                <p>Hello,</p>
                <p>Your password has been successfully reset.</p>
                <div style="background-color: #f4f4f4; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <p style="margin: 0; font-size: 14px;">Your New Password:</p>
                    <p style="margin: 10px 0 0 0; font-size: 24px; font-weight: bold; color: #7C3AED; letter-spacing: 2px;">
                        {new_password}
                    </p>
                </div>
                <p>Please log in with this password and change it immediately from your profile.</p>
                <br>
                <p>Best regards,</p>
                <p><strong>SmartConverter Team</strong></p>
            </body>
        </html>
        """

        message = MessageSchema(
            subject="SmartConverter - New Password",
            recipients=[email],
            body=html,
            subtype=MessageType.html
        )

        try:
            fm = FastMail(EmailService.conf)
            await fm.send_message(message)
            return True
        except Exception as e:
            print(f"Error sending email: {e}")
            return False
