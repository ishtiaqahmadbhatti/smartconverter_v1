# Authentication & Authorization Guide

This guide explains the comprehensive authentication and authorization system implemented in the TechMindsForge FastAPI application.

## Overview

The authentication system provides:
- JWT-based authentication with access and refresh tokens
- Role-based authorization (User, Premium, Moderator, Admin)
- OAuth integration (Google, Facebook)
- Token blacklisting for secure logout
- Rate limiting and security middleware
- User management and profile endpoints

## Authentication Flow

### 1. User Registration
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "username",
  "password": "securepassword",
  "full_name": "Full Name"
}
```

### 2. User Login
```bash
POST /api/v1/auth/login
Content-Type: application/x-www-form-urlencoded

username=user@example.com&password=securepassword
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 1800
}
```

### 3. Using Access Token
```bash
GET /api/v1/users/profile
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

### 4. Token Refresh
```bash
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### 5. Logout
```bash
POST /api/v1/auth/logout
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

## User Roles

### User (Default)
- Basic file conversions
- Limited file size (10MB)
- 10 conversions per day
- Standard features

### Premium
- All conversion types
- Larger file sizes (100MB)
- 100 conversions per day
- Advanced features

### Moderator
- All Premium features
- User management capabilities
- 50 conversions per day
- System monitoring

### Admin
- Full system access
- Unlimited conversions
- User role management
- System administration

## Authorization Examples

### Protected Endpoints
Most conversion endpoints now require authentication:

```python
@router.post("/pdf-to-word")
async def convert_pdf_to_word(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user)
):
    # User must be authenticated
    pass
```

### Role-Based Access
```python
@router.get("/admin/users")
async def get_all_users(
    current_user: User = Depends(get_current_admin_user)
):
    # Only admins can access
    pass
```

### Premium Features
```python
@router.post("/advanced-conversion")
async def advanced_conversion(
    current_user: User = Depends(get_current_premium_user)
):
    # Only premium users and above
    pass
```

## OAuth Integration

### Google OAuth
```bash
GET /api/v1/auth/google/url
# Returns authorization URL

GET /api/v1/auth/google/callback
# Handles OAuth callback
```

### Facebook OAuth
```bash
GET /api/v1/auth/facebook/url
# Returns authorization URL

GET /api/v1/auth/facebook/callback
# Handles OAuth callback
```

## User Management

### Get Profile
```bash
GET /api/v1/users/profile
Authorization: Bearer <token>
```

### Update Profile
```bash
PUT /api/v1/users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "full_name": "New Name",
  "username": "newusername"
}
```

### User Statistics
```bash
GET /api/v1/users/stats
Authorization: Bearer <token>
```

## Admin Endpoints

### Get All Users
```bash
GET /api/v1/users/admin/all?skip=0&limit=100
Authorization: Bearer <admin_token>
```

### Update User Role
```bash
PUT /api/v1/users/admin/{user_id}/role
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "new_role": "premium"
}
```

### Activate/Deactivate User
```bash
PUT /api/v1/users/admin/{user_id}/activate
Authorization: Bearer <admin_token>
```

## Security Features

### Token Blacklisting
- Tokens are blacklisted on logout
- Redis integration for token management
- Automatic token expiration

### Rate Limiting
- 100 requests per minute per IP
- Configurable limits per user role
- Protection against abuse

### Security Headers
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security
- Referrer-Policy

## Configuration

### Environment Variables
```bash
# JWT Settings
SECRET_KEY=your-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# OAuth Settings
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
FACEBOOK_CLIENT_ID=your-facebook-client-id
FACEBOOK_CLIENT_SECRET=your-facebook-client-secret

# Database
DATABASE_URL=postgresql://user:password@localhost/dbname
```

## Error Handling

### Authentication Errors
- 401 Unauthorized: Invalid or missing token
- 403 Forbidden: Insufficient permissions
- 400 Bad Request: Invalid credentials

### Common Error Responses
```json
{
  "detail": "Could not validate credentials"
}
```

```json
{
  "detail": "Not enough permissions"
}
```

## Best Practices

1. **Always use HTTPS in production**
2. **Store tokens securely on client side**
3. **Implement token refresh logic**
4. **Handle token expiration gracefully**
5. **Use appropriate user roles**
6. **Monitor authentication logs**
7. **Regular security audits**

## Testing Authentication

### Using curl
```bash
# Register
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123","full_name":"Test User"}'

# Login
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=password123"

# Use token
curl -X GET "http://localhost:8000/api/v1/users/profile" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Using Python requests
```python
import requests

# Login
response = requests.post(
    "http://localhost:8000/api/v1/auth/login",
    data={"username": "test@example.com", "password": "password123"}
)
token = response.json()["access_token"]

# Use token
headers = {"Authorization": f"Bearer {token}"}
response = requests.get(
    "http://localhost:8000/api/v1/users/profile",
    headers=headers
)
```

This authentication system provides a robust, secure, and scalable foundation for the TechMindsForge API.
