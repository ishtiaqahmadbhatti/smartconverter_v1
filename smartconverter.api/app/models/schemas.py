from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List
from enum import Enum
from datetime import datetime


class ConversionType(str, Enum):
    """Supported conversion types."""
    # Basic conversions
    PDF_TO_WORD = "pdf-to-word"
    WORD_TO_PDF = "word-to-pdf"
    IMAGE_TO_TEXT = "image-to-text"
    
    # PDF to other formats
    PDF_TO_JPG = "pdf-to-jpg"
    PDF_TO_POWERPOINT = "pdf-to-powerpoint"
    PDF_TO_EXCEL = "pdf-to-excel"
    PDF_TO_PDFA = "pdf-to-pdfa"
    
    # Other formats to PDF
    JPG_TO_PDF = "jpg-to-pdf"
    POWERPOINT_TO_PDF = "powerpoint-to-pdf"
    EXCEL_TO_PDF = "excel-to-pdf"
    HTML_TO_PDF = "html-to-pdf"
    
    # PDF manipulation
    MERGE_PDF = "merge-pdf"
    SPLIT_PDF = "split-pdf"
    COMPRESS_PDF = "compress-pdf"
    REMOVE_PAGES = "remove-pages"
    EXTRACT_PAGES = "extract-pages"
    ORGANIZE_PDF = "organize-pdf"
    SCAN_TO_PDF = "scan-to-pdf"
    REPAIR_PDF = "repair-pdf"
    OCR_PDF = "ocr-pdf"
    ROTATE_PDF = "rotate-pdf"
    ADD_PAGE_NUMBERS = "add-page-numbers"
    ADD_WATERMARK = "add-watermark"
    CROP_PDF = "crop-pdf"
    EDIT_PDF = "edit-pdf"
    UNLOCK_PDF = "unlock-pdf"
    PROTECT_PDF = "protect-pdf"
    SIGN_PDF = "sign-pdf"
    REDACT_PDF = "redact-pdf"
    COMPARE_PDF = "compare-pdf"


class FileUploadResponse(BaseModel):
    """Response model for file upload operations."""
    success: bool
    message: str
    filename: str
    file_size: int
    conversion_type: ConversionType


class ConversionResponse(BaseModel):
    """Response model for conversion operations."""
    success: bool
    message: str
    output_filename: Optional[str] = None
    download_url: Optional[str] = None
    extracted_text: Optional[str] = None
    converted_data: Optional[str] = None


class ErrorResponse(BaseModel):
    """Standardized error response model."""
    error_type: str
    message: str
    details: dict = Field(default_factory=dict)


class HealthCheckResponse(BaseModel):
    """Health check response model."""
    status: str
    app_name: str
    version: str
    uptime: Optional[float] = None
    database: Optional[dict] = None


# User Authentication Schemas
class UserRole(str, Enum):
    """User roles for authorization."""
    USER = "user"
    ADMIN = "admin"
    MODERATOR = "moderator"
    PREMIUM = "premium"


class UserBase(BaseModel):
    """Base user schema with common fields."""
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=100)
    full_name: Optional[str] = Field(None, max_length=255)


class UserCreate(UserBase):
    """Schema for user registration."""
    password: str = Field(..., min_length=8, max_length=100)


class UserResponse(UserBase):
    """Schema for user data in responses."""
    id: int
    role: UserRole
    is_active: bool
    is_verified: bool
    created_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class UserLogin(BaseModel):
    """Schema for user login."""
    email: EmailStr
    password: str


class Token(BaseModel):
    """Token response schema."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class TokenData(BaseModel):
    """Token data schema."""
    email: Optional[str] = None


class UserUpdate(BaseModel):
    """Schema for updating user information."""
    full_name: Optional[str] = Field(None, max_length=255)
    username: Optional[str] = Field(None, min_length=3, max_length=100)


# PDF Operation Schemas
class PDFOperationRequest(BaseModel):
    """Base schema for PDF operations."""
    pages: Optional[List[int]] = None
    page_range: Optional[str] = None
    quality: Optional[str] = "medium"  # low, medium, high
    password: Optional[str] = None
    rotation: Optional[int] = 0  # 0, 90, 180, 270
    watermark_text: Optional[str] = None
    watermark_position: Optional[str] = "center"  # top-left, top-right, center, bottom-left, bottom-right
    crop_box: Optional[dict] = None  # {"x": 0, "y": 0, "width": 100, "height": 100}
    protection_password: Optional[str] = None
    permissions: Optional[List[str]] = None  # ["print", "copy", "modify", "annotate"]


# Person API Schemas
class PersonBase(BaseModel):
    """Base person schema with common fields."""
    name: str = Field(..., min_length=1, max_length=255, description="Full name of the person")
    age: str = Field(..., min_length=1, max_length=10, description="Age of the person")
    gender: str = Field(..., min_length=1, max_length=50, description="Gender of the person")


class PersonCreate(PersonBase):
    """Schema for creating a new person."""
    pass


class PersonUpdate(BaseModel):
    """Schema for updating person information."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    age: Optional[str] = Field(None, min_length=1, max_length=10)
    gender: Optional[str] = Field(None, min_length=1, max_length=50)


class PersonResponse(PersonBase):
    """Schema for person data in responses."""
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class PersonListResponse(BaseModel):
    """Schema for listing persons."""
    persons: List[PersonResponse]
    total: int
    page: int
    size: int
