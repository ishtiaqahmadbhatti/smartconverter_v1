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
class Token(BaseModel):
    """Schema for JWT token."""
    access_token: str
    refresh_token: str
    token_type: str
    expires_in: int
    full_name: Optional[str] = None


class TokenData(BaseModel):
    """Schema for JWT token data."""
    email: Optional[str] = None




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


# UserList Schemas
class UserListBase(BaseModel):
    """Base schema for UserList."""
    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    gender: Optional[str] = Field(None, min_length=1, max_length=50)
    phone_number: Optional[str] = Field(None, min_length=1, max_length=20)
    email: Optional[EmailStr] = None
    device_id: Optional[str] = None
    is_premium: Optional[bool] = False
    subscription_plan: Optional[str] = 'free'
    subscription_expiry: Optional[datetime] = None


class UserListCreate(UserListBase):
    """Schema for creating a new user in UserList."""
    password: str = Field(..., min_length=8, max_length=100)


class UserListUpdate(BaseModel):
    """Schema for updating UserList."""
    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    gender: Optional[str] = Field(None, min_length=1, max_length=50)
    phone_number: Optional[str] = Field(None, min_length=1, max_length=20)
    email: Optional[EmailStr] = None


class ChangePassword(BaseModel):
    """Schema for changing password."""
    old_password: str = Field(..., min_length=1)
    new_password: str = Field(..., min_length=8, max_length=100)


class ForgotPassword(BaseModel):
    """Schema for forgot password request."""
    email: EmailStr
    device_id: Optional[str] = None


class VerifyOTP(BaseModel):
    """Schema for verifying OTP."""
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)


class ResetPasswordConfirm(BaseModel):
    """Schema for resetting password with token."""
    reset_token: str
    new_password: str = Field(..., min_length=8, max_length=100)



class UserListResponse(UserListBase):
    """Schema for UserList response."""
    id: int
    created_at: datetime
    modified_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserListLogin(BaseModel):
    """Schema for UserList login."""
    email: EmailStr
    password: str

# Alias for backward compatibility or generic usage
UserLogin = UserListLogin
class GuestRegistration(BaseModel):
    """Schema for guest registration."""
    device_id: str = Field(..., min_length=5)

class SubscriptionUpgrade(BaseModel):
    """Schema for subscription upgrade."""
    plan_id: str # monthly, yearly


