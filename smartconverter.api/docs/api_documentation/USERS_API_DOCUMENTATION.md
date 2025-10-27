# Users API Documentation

## Overview
The Users API provides endpoints for user management, profile operations, and user-related administrative functions.

## Base URL
```
/api/v1/users
```

## Endpoints

### Get All Users (Admin)
**GET** `/`

Retrieve a list of all users with pagination support (Admin only).

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Query Parameters:**
- `skip`: Number of records to skip (optional, default: 0)
- `limit`: Maximum number of records to return (optional, default: 100)
- `search`: Search term for user filtering (optional)
- `is_active`: Filter by active status (optional)
- `is_verified`: Filter by verification status (optional)

**Response:**
```json
{
  "users": [
    {
      "id": 1,
      "email": "user1@example.com",
      "username": "user1",
      "full_name": "John Doe",
      "is_active": true,
      "is_verified": true,
      "role": "user",
      "created_at": "2024-01-15T10:30:00Z",
      "last_login": "2024-01-15T12:00:00Z"
    },
    {
      "id": 2,
      "email": "user2@example.com",
      "username": "user2",
      "full_name": "Jane Smith",
      "is_active": true,
      "is_verified": false,
      "role": "user",
      "created_at": "2024-01-15T11:00:00Z",
      "last_login": null
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 100
}
```

### Get User by ID
**GET** `/{user_id}`

Retrieve a specific user by their ID.

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "id": 1,
  "email": "user1@example.com",
  "username": "user1",
  "full_name": "John Doe",
  "is_active": true,
  "is_verified": true,
  "role": "user",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T12:30:00Z",
  "last_login": "2024-01-15T12:00:00Z",
  "login_count": 15,
  "conversion_count": 25
}
```

### Update User (Admin)
**PUT** `/{user_id}`

Update user information (Admin only).

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Request Body:**
```json
{
  "full_name": "John Updated",
  "username": "johnupdated",
  "is_active": true,
  "is_verified": true,
  "role": "premium"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User updated successfully",
  "user": {
    "id": 1,
    "email": "user1@example.com",
    "username": "johnupdated",
    "full_name": "John Updated",
    "is_active": true,
    "is_verified": true,
    "role": "premium",
    "updated_at": "2024-01-15T12:45:00Z"
  }
}
```

### Deactivate User (Admin)
**POST** `/{user_id}/deactivate`

Deactivate a user account (Admin only).

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "success": true,
  "message": "User deactivated successfully",
  "user": {
    "id": 1,
    "is_active": false,
    "deactivated_at": "2024-01-15T13:00:00Z"
  }
}
```

### Activate User (Admin)
**POST** `/{user_id}/activate`

Activate a user account (Admin only).

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "success": true,
  "message": "User activated successfully",
  "user": {
    "id": 1,
    "is_active": true,
    "activated_at": "2024-01-15T13:15:00Z"
  }
}
```

### Delete User (Admin)
**DELETE** `/{user_id}`

Delete a user account (Admin only).

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "user_id": 1
}
```

### Get User Statistics
**GET** `/{user_id}/stats`

Get user statistics and activity data.

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "user_id": 1,
  "statistics": {
    "total_conversions": 25,
    "total_files_processed": 45,
    "total_storage_used": "125MB",
    "last_activity": "2024-01-15T12:00:00Z",
    "conversion_breakdown": {
      "pdf_conversions": 10,
      "image_conversions": 8,
      "document_conversions": 7
    },
    "monthly_usage": {
      "current_month": 15,
      "previous_month": 12
    }
  }
}
```

### Search Users
**GET** `/search`

Search users with advanced filtering.

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Query Parameters:**
- `q`: Search query (required)
- `role`: Filter by role (optional)
- `is_active`: Filter by active status (optional)
- `is_verified`: Filter by verification status (optional)
- `created_after`: Filter by creation date (optional)
- `created_before`: Filter by creation date (optional)

**Response:**
```json
{
  "users": [
    {
      "id": 1,
      "email": "user1@example.com",
      "username": "user1",
      "full_name": "John Doe",
      "is_active": true,
      "is_verified": true,
      "role": "user",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "query": "john"
}
```

### Get User Activity Log
**GET** `/{user_id}/activity`

Get user activity log with pagination.

**Request Headers:**
```
Authorization: Bearer <admin-token>
```

**Query Parameters:**
- `skip`: Number of records to skip (optional, default: 0)
- `limit`: Maximum number of records to return (optional, default: 50)
- `activity_type`: Filter by activity type (optional)

**Response:**
```json
{
  "activities": [
    {
      "id": 1,
      "user_id": 1,
      "activity_type": "conversion",
      "description": "PDF to Word conversion",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0...",
      "created_at": "2024-01-15T12:00:00Z"
    },
    {
      "id": 2,
      "user_id": 1,
      "activity_type": "login",
      "description": "User login",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0...",
      "created_at": "2024-01-15T11:30:00Z"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 50
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data",
  "errors": [
    {
      "field": "username",
      "message": "Username is required"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "detail": "Admin access required"
}
```

### 404 Not Found
```json
{
  "detail": "User not found"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "Validation error",
  "errors": [
    {
      "field": "role",
      "message": "Invalid role specified"
    }
  ]
}
```

## Usage Examples

### cURL Examples

**Get All Users (Admin):**
```bash
curl -X GET "http://localhost:8002/api/v1/users/" \
  -H "Authorization: Bearer <admin-token>"
```

**Get User by ID:**
```bash
curl -X GET "http://localhost:8002/api/v1/users/1" \
  -H "Authorization: Bearer <admin-token>"
```

**Update User (Admin):**
```bash
curl -X PUT "http://localhost:8002/api/v1/users/1" \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Updated",
    "role": "premium"
  }'
```

**Deactivate User (Admin):**
```bash
curl -X POST "http://localhost:8002/api/v1/users/1/deactivate" \
  -H "Authorization: Bearer <admin-token>"
```

**Get User Statistics:**
```bash
curl -X GET "http://localhost:8002/api/v1/users/1/stats" \
  -H "Authorization: Bearer <admin-token>"
```

**Search Users:**
```bash
curl -X GET "http://localhost:8002/api/v1/users/search?q=john&role=user" \
  -H "Authorization: Bearer <admin-token>"
```

## Data Models

### User Schema
```json
{
  "id": "integer",
  "email": "string (required, unique)",
  "username": "string (required, unique)",
  "full_name": "string (required)",
  "is_active": "boolean",
  "is_verified": "boolean",
  "role": "string (user, premium, admin)",
  "created_at": "datetime",
  "updated_at": "datetime",
  "last_login": "datetime",
  "login_count": "integer",
  "conversion_count": "integer"
}
```

### User Roles
- **user**: Standard user with basic features
- **premium**: Premium user with advanced features
- **admin**: Administrator with full access

## Permissions

### Admin Only Endpoints
- Get all users
- Update any user
- Deactivate/activate users
- Delete users
- View user statistics
- View user activity logs

### User Self-Service
- View own profile
- Update own profile (limited fields)
- View own statistics

## Rate Limits
- 1000 requests per hour per admin
- 100 requests per minute per admin
- 500 requests per hour per user (own data only)

## Authentication
All endpoints require authentication. Admin endpoints require admin role. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
