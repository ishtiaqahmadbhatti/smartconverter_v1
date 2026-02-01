#!/bin/bash

# SmartConverter Web - Docker Build & Deploy Script

echo "🐳 Building SmartConverter Web Docker Image..."

# Clean up old containers and images
echo "🧹 Cleaning up old containers..."
docker compose down 2>/dev/null || true

# Build and start
echo "🔨 Building and starting containers..."
docker compose up -d --build

# Wait for container to be ready
echo "⏳ Waiting for container to start..."
sleep 5

# Check status
echo "📊 Container Status:"
docker compose ps

# Show logs
echo "📝 Recent Logs:"
docker compose logs --tail=50

echo ""
echo "✅ Deployment complete!"
echo "🌐 Access the application at: http://localhost:4200"
echo ""
echo "Useful commands:"
echo "  - View logs: docker compose logs -f"
echo "  - Stop: docker compose down"
echo "  - Restart: docker compose restart"
