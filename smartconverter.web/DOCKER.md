
+# SmartConverter Web - Docker Deployment

This directory contains the Angular frontend application for SmartConverter.

## Docker Setup

### Prerequisites
- Docker installed on your system
- Docker Compose (optional, for easier deployment)

## Deployment Options

### Option 1: Simple Deployment (Recommended for Quick Start)

This approach requires building the Angular app locally first, then creating a lightweight Docker image.

**Step 1: Build the Angular application locally**
```bash
npm install
npm run build
```

**Step 2: Build and run Docker container**
```bash
# Build using simple Dockerfile
docker build -f Dockerfile.simple -t smartconverter-web .

# Run the container
docker run -d -p 4200:80 --name smartconverter-web smartconverter-web
```

### Option 2: Full Multi-Stage Build

This approach builds everything inside Docker (takes longer but more portable).

```bash
# Build the image
docker build -t smartconverter-web .

# Run the container
docker run -d -p 4200:80 --name smartconverter-web smartconverter-web
```

### Using Docker Compose

```bash
# Start the application
docker-compose up -d

# Stop the application
docker-compose down

# View logs
docker-compose logs -f

# Rebuild and restart
docker-compose up -d --build
```

### Accessing the Application

Once running, access the application at:
- **Local**: http://localhost:4200

### Environment Variables

You can customize the deployment by setting environment variables in `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - API_URL=http://your-api-url
```

### Production Deployment

For production deployment:

1. **Build the image**:
   ```bash
   docker build -t smartconverter-web:latest .
   ```

2. **Tag for registry** (if using Docker Hub or private registry):
   ```bash
   docker tag smartconverter-web:latest your-registry/smartconverter-web:latest
   ```

3. **Push to registry**:
   ```bash
   docker push your-registry/smartconverter-web:latest
   ```

4. **Deploy on server**:
   ```bash
   docker pull your-registry/smartconverter-web:latest
   docker run -d -p 80:80 --name smartconverter-web your-registry/smartconverter-web:latest
   ```

### Docker Image Details

- **Base Image**: Node 20 Alpine (build stage)
- **Web Server**: Nginx Alpine (production stage)
- **Port**: 80 (internal), mapped to 4200 (external)
- **Size**: Optimized multi-stage build (~50MB final image)

### Troubleshooting

**Container not starting:**
```bash
docker logs smartconverter-web
```

**Rebuild without cache:**
```bash
docker build --no-cache -t smartconverter-web .
```

**Remove old containers:**
```bash
docker rm -f smartconverter-web
```

### Development

For local development without Docker:
```bash
npm install
npm start
```

## File Structure

```
smartconverter.web/
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose configuration
├── nginx.conf             # Nginx server configuration
├── .dockerignore          # Files to exclude from Docker build
└── src/                   # Angular source code
```

## Support

For issues or questions, please contact the development team.
