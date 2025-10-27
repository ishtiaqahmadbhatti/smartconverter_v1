# Persons API Documentation

## Overview
The Persons API provides endpoints for managing person records including CRUD operations for personal information.

## Base URL
```
/api/v1/persons
```

## Endpoints

### Get All Persons
**GET** `/`

Retrieve a list of all persons with pagination support.

**Query Parameters:**
- `skip`: Number of records to skip (optional, default: 0)
- `limit`: Maximum number of records to return (optional, default: 100)
- `search`: Search term for name filtering (optional)

**Response:**
```json
{
  "persons": [
    {
      "id": 1,
      "name": "John Doe",
      "age": "25",
      "gender": "Male",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "age": "30",
      "gender": "Female",
      "created_at": "2024-01-15T11:00:00Z",
      "updated_at": "2024-01-15T11:00:00Z"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 100
}
```

### Get Person by ID
**GET** `/{person_id}`

Retrieve a specific person by their ID.

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "age": "25",
  "gender": "Male",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Create New Person
**POST** `/`

Create a new person record.

**Request Body:**
```json
{
  "name": "Alice Johnson",
  "age": "28",
  "gender": "Female"
}
```

**Response:**
```json
{
  "id": 3,
  "name": "Alice Johnson",
  "age": "28",
  "gender": "Female",
  "created_at": "2024-01-15T12:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z"
}
```

### Update Person
**PUT** `/{person_id}`

Update an existing person record.

**Request Body:**
```json
{
  "name": "John Updated",
  "age": "26",
  "gender": "Male"
}
```

**Response:**
```json
{
  "id": 1,
  "name": "John Updated",
  "age": "26",
  "gender": "Male",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T12:30:00Z"
}
```

### Partial Update Person
**PATCH** `/{person_id}`

Partially update a person record (only provided fields).

**Request Body:**
```json
{
  "age": "27"
}
```

**Response:**
```json
{
  "id": 1,
  "name": "John Updated",
  "age": "27",
  "gender": "Male",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T12:45:00Z"
}
```

### Delete Person
**DELETE** `/{person_id}`

Delete a person record.

**Response:**
```json
{
  "message": "Person deleted successfully",
  "id": 1
}
```

### Search Persons
**GET** `/search`

Search persons by name with advanced filtering.

**Query Parameters:**
- `q`: Search query (required)
- `gender`: Filter by gender (optional)
- `age_min`: Minimum age filter (optional)
- `age_max`: Maximum age filter (optional)

**Response:**
```json
{
  "persons": [
    {
      "id": 1,
      "name": "John Doe",
      "age": "25",
      "gender": "Male",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "query": "john"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data",
  "errors": [
    {
      "field": "name",
      "message": "Name is required"
    },
    {
      "field": "age",
      "message": "Age must be a valid number"
    }
  ]
}
```

### 404 Not Found
```json
{
  "detail": "Person not found"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "Validation error",
  "errors": [
    {
      "field": "gender",
      "message": "Gender must be one of: Male, Female, Other"
    }
  ]
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

## Usage Examples

### cURL Examples

**Get All Persons:**
```bash
curl -X GET "http://localhost:8002/api/v1/persons/" \
  -H "Authorization: Bearer <your-token>"
```

**Get Person by ID:**
```bash
curl -X GET "http://localhost:8002/api/v1/persons/1" \
  -H "Authorization: Bearer <your-token>"
```

**Create New Person:**
```bash
curl -X POST "http://localhost:8002/api/v1/persons/" \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "age": "28",
    "gender": "Female"
  }'
```

**Update Person:**
```bash
curl -X PUT "http://localhost:8002/api/v1/persons/1" \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "age": "26",
    "gender": "Male"
  }'
```

**Delete Person:**
```bash
curl -X DELETE "http://localhost:8002/api/v1/persons/1" \
  -H "Authorization: Bearer <your-token>"
```

**Search Persons:**
```bash
curl -X GET "http://localhost:8002/api/v1/persons/search?q=john&gender=Male" \
  -H "Authorization: Bearer <your-token>"
```

## Data Models

### Person Schema
```json
{
  "id": "integer",
  "name": "string (required, max 255 chars)",
  "age": "string (required, max 10 chars)",
  "gender": "string (required, max 50 chars)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Validation Rules
- **name**: Required, minimum 1 character, maximum 255 characters
- **age**: Required, minimum 1 character, maximum 10 characters
- **gender**: Required, minimum 1 character, maximum 50 characters

## Pagination
- Default page size: 100 records
- Maximum page size: 1000 records
- Skip parameter for offset-based pagination

## Rate Limits
- 1000 requests per hour per user
- 100 requests per minute per user

## Authentication
All endpoints require authentication. Include your JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```
