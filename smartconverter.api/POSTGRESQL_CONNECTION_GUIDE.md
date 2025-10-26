# PostgreSQL Connection Testing Guide

This guide shows you how to confirm that your FastAPI API is properly connected to PostgreSQL 18.

## 🚀 Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Set Up Environment
Copy the example environment file and configure it:
```bash
cp env.example .env
```

Edit `.env` file with your PostgreSQL credentials:
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/techmindsforge
DB_HOST=localhost
DB_PORT=5432
DB_NAME=techmindsforge
DB_USER=postgres
DB_PASSWORD=postgres
```

## 🔍 Testing Methods

### Method 1: Direct Database Connection Test
Run the database connection test script:
```bash
python test_db_connection.py
```

**Expected Output:**
```
🚀 PostgreSQL Connection Test
==================================================
🔍 Testing PostgreSQL Connection...
📊 Database URL: postgresql://postgres:postgres@localhost:5432/techmindsforge
--------------------------------------------------
✅ Database connection successful!
📋 Database Name: techmindsforge
👤 User: postgres
🔢 PostgreSQL Version: PostgreSQL 18.x
✅ Table creation test passed!
🧹 Test table cleaned up!
--------------------------------------------------
🎉 All tests passed! Your API is ready to connect to PostgreSQL.
```

### Method 2: API Health Endpoint Test
Start your FastAPI server:
```bash
uvicorn app.main:app --reload
```

Then test the health endpoint:
```bash
python test_api_health.py
```

**Expected Output:**
```
🚀 API Health Check Test
==================================================
🔍 Testing API Health Endpoint...
🌐 API URL: http://localhost:8000/api/v1/health
--------------------------------------------------
✅ API is responding!
📊 Status: healthy
🏷️  App Name: TechMindsForge FastAPI
🔢 Version: 1.0.0
⏱️  Uptime: 45.67 seconds
✅ Database: Connected to PostgreSQL!
--------------------------------------------------
🎉 API health check passed! Your API is connected to PostgreSQL.
```

### Method 3: Manual API Testing
You can also test manually using curl or a browser:

```bash
# Using curl
curl http://localhost:8000/api/v1/health

# Using browser
# Navigate to: http://localhost:8000/api/v1/health
```

**Expected JSON Response:**
```json
{
  "status": "healthy",
  "app_name": "TechMindsForge FastAPI",
  "version": "1.0.0",
  "uptime": 45.67,
  "database": {
    "status": "connected",
    "error": null
  }
}
```

## 🐳 Docker Testing

If you're using Docker, start the services:
```bash
docker-compose up -d
```

Then test the API:
```bash
python test_api_health.py
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Database Connection Failed
**Error:** `psycopg2.OperationalError: could not connect to server`

**Solutions:**
- Ensure PostgreSQL is running: `pg_ctl status`
- Check if the database exists: `psql -l`
- Verify credentials in `.env` file
- Check firewall settings

#### 2. Database Does Not Exist
**Error:** `database "techmindsforge" does not exist`

**Solution:**
```bash
# Create the database
createdb techmindsforge

# Or using psql
psql -U postgres -c "CREATE DATABASE techmindsforge;"
```

#### 3. Permission Denied
**Error:** `permission denied for database`

**Solution:**
```bash
# Grant permissions to user
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE techmindsforge TO postgres;"
```

#### 4. API Not Responding
**Error:** `Cannot connect to API`

**Solutions:**
- Start the FastAPI server: `uvicorn app.main:app --reload`
- Check if port 8000 is available
- Verify the server is running: `netstat -an | grep 8000`

#### 5. Environment Variables Not Loaded
**Error:** `database_url is None`

**Solutions:**
- Ensure `.env` file exists and is in the project root
- Check `.env` file syntax (no spaces around `=`)
- Restart the application after changing `.env`

## 📊 Health Check Endpoint Details

The enhanced health endpoint (`/api/v1/health`) now provides:

- **Overall Status**: `healthy` or `unhealthy`
- **Application Info**: Name and version
- **Uptime**: Server uptime in seconds
- **Database Status**: Connection status and any errors

### Database Status Values:
- `connected`: Database is accessible and responding
- `disconnected`: Database connection failed
- `error`: Contains the specific error message

## 🎯 Success Indicators

Your API is successfully connected to PostgreSQL when:

1. ✅ `test_db_connection.py` runs without errors
2. ✅ Health endpoint returns `"status": "healthy"`
3. ✅ Database status shows `"status": "connected"`
4. ✅ No error messages in the database section

## 📝 Next Steps

After confirming the connection:

1. **Run Database Migrations** (if you have any):
   ```bash
   alembic upgrade head
   ```

2. **Test Your Endpoints**: Try creating users or other database operations

3. **Monitor Performance**: Use the health endpoint for monitoring

4. **Set Up Logging**: Configure proper logging for production

## 🆘 Getting Help

If you're still having issues:

1. Check the FastAPI server logs
2. Verify PostgreSQL logs: `tail -f /var/log/postgresql/postgresql-*.log`
3. Test PostgreSQL directly: `psql -U postgres -d techmindsforge`
4. Check network connectivity: `telnet localhost 5432`
