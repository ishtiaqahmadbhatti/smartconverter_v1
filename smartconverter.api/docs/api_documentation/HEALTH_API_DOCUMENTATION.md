# Health API Documentation

## Overview
The Health API provides endpoints for monitoring the application status, database connectivity, and system health.

## Base URL
```
/api/v1/health
```

## Endpoints

### Health Check
**GET** `/`

Basic health check endpoint to verify API availability.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "uptime": "2d 5h 30m"
}
```

### Detailed Health Status
**GET** `/detailed`

Comprehensive health check including all system components.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "uptime": "2d 5h 30m",
  "components": {
    "database": {
      "status": "healthy",
      "response_time": "15ms",
      "connection_pool": {
        "active": 5,
        "idle": 10,
        "max": 20
      }
    },
    "file_system": {
      "status": "healthy",
      "upload_directory": "accessible",
      "output_directory": "accessible",
      "free_space": "15.2GB"
    },
    "memory": {
      "status": "healthy",
      "used": "512MB",
      "available": "1.5GB",
      "total": "2GB"
    },
    "cpu": {
      "status": "healthy",
      "usage": "25%",
      "load_average": [0.5, 0.8, 1.2]
    }
  }
}
```

### Database Health
**GET** `/database`

Check database connectivity and performance.

**Response:**
```json
{
  "status": "healthy",
  "database": "PostgreSQL",
  "version": "14.5",
  "connection_time": "12ms",
  "query_time": "5ms",
  "active_connections": 5,
  "max_connections": 100,
  "database_size": "250MB"
}
```

### System Metrics
**GET** `/metrics`

Get system performance metrics.

**Response:**
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "metrics": {
    "requests_per_minute": 45,
    "average_response_time": "120ms",
    "error_rate": "0.5%",
    "active_users": 12,
    "conversions_in_progress": 3,
    "queue_size": 0
  }
}
```

### Service Dependencies
**GET** `/dependencies`

Check status of external service dependencies.

**Response:**
```json
{
  "status": "healthy",
  "dependencies": {
    "database": {
      "status": "healthy",
      "response_time": "15ms"
    },
    "file_storage": {
      "status": "healthy",
      "response_time": "8ms"
    },
    "ocr_service": {
      "status": "healthy",
      "response_time": "250ms"
    },
    "conversion_engines": {
      "status": "healthy",
      "available_workers": 8,
      "busy_workers": 2
    }
  }
}
```

## Error Responses

### 503 Service Unavailable
```json
{
  "status": "unhealthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "error": "Database connection failed",
  "components": {
    "database": {
      "status": "unhealthy",
      "error": "Connection timeout"
    }
  }
}
```

### 500 Internal Server Error
```json
{
  "status": "error",
  "timestamp": "2024-01-15T10:30:00Z",
  "error": "Health check failed",
  "details": "Unable to connect to required services"
}
```

## Usage Examples

### cURL Examples

**Basic Health Check:**
```bash
curl -X GET "http://localhost:8002/api/v1/health/"
```

**Detailed Health Status:**
```bash
curl -X GET "http://localhost:8002/api/v1/health/detailed"
```

**Database Health:**
```bash
curl -X GET "http://localhost:8002/api/v1/health/database"
```

**System Metrics:**
```bash
curl -X GET "http://localhost:8002/api/v1/health/metrics"
```

## Health Status Values

### Status Types
- **healthy**: All systems operational
- **degraded**: Some non-critical issues
- **unhealthy**: Critical issues detected
- **error**: Health check failed

### Component Status
- **healthy**: Component working normally
- **warning**: Minor issues detected
- **critical**: Component failure
- **unknown**: Status cannot be determined

## Monitoring Integration

### Prometheus Metrics
The health endpoints can be integrated with monitoring systems like Prometheus for continuous health monitoring.

### Health Check Intervals
- **Basic check**: Every 30 seconds
- **Detailed check**: Every 5 minutes
- **Database check**: Every 2 minutes
- **Metrics collection**: Every 1 minute

## Authentication
Health endpoints are publicly accessible and do not require authentication for basic monitoring purposes.

## Rate Limits
- 1000 requests per hour per IP
- No authentication required for basic health checks
