# TechMindsForge FastAPI - User Registration & File Conversion System

This document describes the user registration, authentication, and file conversion system implemented in the TechMindsForge FastAPI application.

## Features

### User Authentication
- ✅ User registration with email, username, and password
- ✅ Secure password hashing using bcrypt
- ✅ JWT token-based authentication
- ✅ User profile management
- ✅ Duplicate email/username prevention
- ✅ Input validation and error handling

### File Conversion
- ✅ PDF to Word conversion
- ✅ **Word to PDF conversion** (NEW!)
- ✅ Image to Text (OCR) extraction
- ✅ File upload and download handling
- ✅ Multiple file format support

## API Endpoints

### Authentication Endpoints

#### 1. Register User
```
POST /api/v1/auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "full_name": "Full Name"  // optional
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "username",
  "full_name": "Full Name",
  "is_active": true,
  "is_verified": false,
  "created_at": "2024-01-01T00:00:00Z",
  "last_login": null
}
```

#### 2. Login User (JSON)
```
POST /api/v1/auth/login-json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

#### 3. Login User (OAuth2 Form)
```
POST /api/v1/auth/login
```

**Form Data:**
- username: user@example.com
- password: password123

### User Management Endpoints

#### 4. Get Current User Profile
```
GET /api/v1/users/me
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "username",
  "full_name": "Full Name",
  "is_active": true,
  "is_verified": false,
  "created_at": "2024-01-01T00:00:00Z",
  "last_login": "2024-01-01T12:00:00Z"
}
```

#### 5. Update User Profile
```
PUT /api/v1/users/me
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "full_name": "New Full Name",  // optional
  "username": "newusername"      // optional
}
```

### File Conversion Endpoints

#### 6. Convert PDF to Word
```
POST /api/v1/convert/pdf-to-word
```

**Request:** Multipart form with PDF file

**Response (200 OK):**
```json
{
  "success": true,
  "message": "PDF converted to Word successfully",
  "output_filename": "converted.docx",
  "download_url": "/download/converted.docx"
}
```

#### 7. Convert Word to PDF (NEW!)
```
POST /api/v1/convert/word-to-pdf
```

**Request:** Multipart form with Word (.docx) file

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Word document converted to PDF successfully",
  "output_filename": "converted.pdf",
  "download_url": "/download/converted.pdf"
}
```

#### 8. Extract Text from Image (OCR)
```
POST /api/v1/convert/image-to-text
```

**Request:** Multipart form with image file

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Text extracted from image successfully",
  "extracted_text": "Extracted text content..."
}
```

#### 9. Download Converted File
```
GET /api/v1/convert/download/{filename}
```

**Response:** File download

## Setup Instructions

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Start the Application
```bash
python -m app.main
```

The application will automatically:
- Create the SQLite database
- Create all necessary tables
- Create a default admin user (admin@techmindsforge.com / admin123)

### 3. Test the System
```bash
# Test user registration and authentication
python -c "
import requests
# Register user
response = requests.post('http://127.0.0.1:8000/api/v1/auth/register', 
    json={'email': 'test@example.com', 'username': 'testuser', 'password': 'testpass123'})
print('Registration:', response.status_code)

# Login
response = requests.post('http://127.0.0.1:8000/api/v1/auth/login-json',
    json={'email': 'test@example.com', 'password': 'testpass123'})
print('Login:', response.status_code)
"
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    last_login DATETIME
);
```

## Security Features

- **Password Hashing**: Uses bcrypt for secure password storage
- **JWT Tokens**: Secure token-based authentication
- **Input Validation**: Comprehensive validation using Pydantic
- **Email Validation**: Proper email format validation
- **Duplicate Prevention**: Prevents duplicate emails and usernames

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid input data or duplicate email/username
- `401 Unauthorized`: Invalid credentials or missing/invalid token
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server-side errors

## Default Admin User

A default admin user is created automatically:
- **Email**: admin@techmindsforge.com
- **Username**: admin
- **Password**: admin123
- **Status**: Active and verified

## Environment Variables

You can customize the following settings in your `.env` file:

```env
DATABASE_URL=sqlite:///./app.db
SECRET_KEY=your-secret-key-change-in-production
```

## Production Considerations

1. **Change the secret key** in production
2. **Use a proper database** (PostgreSQL/MySQL) instead of SQLite
3. **Set up proper CORS** origins
4. **Use environment variables** for sensitive configuration
5. **Implement email verification** for user registration
6. **Add rate limiting** for authentication endpoints
7. **Use HTTPS** in production
