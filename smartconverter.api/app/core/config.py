from pydantic_settings import BaseSettings
from typing import Optional
import os


class Settings(BaseSettings):
    """Application settings and configuration."""
    
    # Application
    app_name: str = "SmartConverter FastAPI"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Directories
    upload_dir: str = "uploads"
    output_dir: str = "outputs"
    
    # File upload limits
    max_file_size: int = 50 * 1024 * 1024  # 50MB
    
    # OCR Settings
    tesseract_path: Optional[str] = None
    
    # Database Settings
    database_url: Optional[str] = None
    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "SmartConverterDB"
    db_user: str = "postgres"
    db_password: str = "Ishtiaq@913"
    
    # JWT Settings
    secret_key: str = "your-secret-key-change-this-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    
    # Redis Settings (optional)
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_db: int = 0
    redis_password: Optional[str] = None
    
    # OAuth Providers
    google_client_id: Optional[str] = None
    google_client_secret: Optional[str] = None
    facebook_client_id: Optional[str] = None
    facebook_client_secret: Optional[str] = None
    
    @property
    def get_database_url(self) -> str:
        """Get the database URL, either from environment or constructed from settings."""
        if self.database_url:
            return self.database_url
        # URL encode the password to handle special characters
        from urllib.parse import quote_plus
        encoded_password = quote_plus(self.db_password)
        return f"postgresql://{self.db_user}:{encoded_password}@{self.db_host}:{self.db_port}/{self.db_name}"

    # Email Settings
    MAIL_USERNAME: str = "techmindsforge@gmail.com"
    MAIL_PASSWORD: str = "ckpm hbdy zuux qsym"
    MAIL_FROM: str = "techmindsforge@gmail.com"
    MAIL_PORT: int = 587
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False
    USE_CREDENTIALS: bool = True
    VALIDATE_CERTS: bool = True
    
    class Config:
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()

# Ensure directories exist
os.makedirs(settings.upload_dir, exist_ok=True)
os.makedirs(settings.output_dir, exist_ok=True)
