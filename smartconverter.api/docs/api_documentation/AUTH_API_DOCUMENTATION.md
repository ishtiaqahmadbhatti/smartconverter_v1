# Authentication API Documentation

## Overview
The Authentication API provides endpoints for user authentication, registration, and session management using JWT tokens and OAuth integration.

## Base URL
```
/api/v1/auth
```

## Endpoints

### User Registration
**POST** `/register`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "full_name": "John Doe",
  "username": "johndoe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "johndoe",
    "full_name": "John Doe",
    "is_active": true,
    "created_at": "2024-01-15T10:30:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### User Login
**POST** `/login`

Authenticate user and return access token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "johndoe",
    "full_name": "John Doe",
    "is_active": true
  }
}
```

### Refresh Token
**POST** `/refresh`

Refresh an expired access token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### Logout
**POST** `/logout`

Logout user and invalidate tokens.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

### Get Current User
**GET** `/me`

Get current authenticated user information.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "johndoe",
  "full_name": "John Doe",
  "is_active": true,
  "is_verified": true,
  "created_at": "2024-01-15T10:30:00Z",
  "last_login": "2024-01-15T12:00:00Z"
}
```

### Update Profile
**PUT** `/me`

Update current user profile information.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "full_name": "John Updated",
  "username": "johnupdated"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "johnupdated",
    "full_name": "John Updated",
    "is_active": true,
    "updated_at": "2024-01-15T12:30:00Z"
  }
}
```

### Change Password
**POST** `/change-password`

Change user password.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "current_password": "oldpassword123",
  "new_password": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

### OAuth Login - Google
**GET** `/oauth/google`

Initiate Google OAuth login.

**Response:**
```json
{
  "auth_url": "https://accounts.google.com/oauth/authorize?...",
  "state": "random-state-string"
}
```

### OAuth Callback - Google
**GET** `/oauth/google/callback`

Handle Google OAuth callback.

**Query Parameters:**
- `code`: Authorization code from Google
- `state`: State parameter for security

**Response:**
```json
{
  "success": true,
  "message": "OAuth login successful",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "user@gmail.com",
    "username": "googleuser",
    "full_name": "Google User",
    "provider": "google"
  }
}
```

### Forgot Password
**POST** `/forgot-password`

Send password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

### Reset Password
**POST** `/reset-password`

Reset password using token from email.

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "new_password": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "Account is disabled"
}
```

### 409 Conflict
```json
{
  "detail": "Email already registered"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "Validation error",
  "errors": [
    {
      "field": "password",
      "message": "Password does not meet requirements"
    }
  ]
}
```

## Usage Examples

### cURL Examples

**User Registration:**
```bash
curl -X POST "http://localhost:8002/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123",
    "full_name": "John Doe",
    "username": "johndoe"
  }'
```

**User Login:**
```bash
curl -X POST "http://localhost:8002/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123"
  }'
```

**Get Current User:**
```bash
curl -X GET "http://localhost:8002/api/v1/auth/me" \
  -H "Authorization: Bearer <your-token>"
```

**Update Profile:**
```bash
curl -X PUT "http://localhost:8002/api/v1/auth/me" \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Updated",
    "username": "johnupdated"
  }'
```

**Change Password:**
```bash
curl -X POST "http://localhost:8002/api/v1/auth/change-password" \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "current_password": "oldpassword123",
    "new_password": "newpassword123"
  }'
```

## Security Features

### Password Requirements
- Minimum 8 characters
- Must contain uppercase and lowercase letters
- Must contain at least one number
- Must contain at least one special character

### Token Security
- JWT tokens with 1-hour expiration
- Refresh tokens with 30-day expiration
- Secure token storage recommendations
- Token blacklisting on logout

### OAuth Providers
- Google OAuth 2.0
- GitHub OAuth
- Microsoft OAuth (planned)

## Rate Limits
- Registration: 5 attempts per hour per IP
- Login: 10 attempts per hour per IP
- Password reset: 3 attempts per hour per email
- OAuth: 20 attempts per hour per IP

## Authentication
Most endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
