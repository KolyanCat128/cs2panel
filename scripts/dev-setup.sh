#!/bin/bash
set -e

# CS2Panel Development Environment Setup

echo "Setting up CS2Panel development environment..."
echo "=============================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "Please edit .env and add your API keys"
fi

# Build hypervisor
echo "Building hypervisor daemon..."
cd hypervisor
go build -o bin/hypervisor-daemon .
cd ..

# Build backend
echo "Building backend..."
cd backend
./mvnw clean package -DskipTests
cd ..

# Start services with Docker Compose
echo "Starting services..."
docker-compose up -d

echo "=============================================="
echo "Development environment is ready!"
echo ""
echo "Services:"
echo "  Backend:     http://localhost:8080"
echo "  Hypervisor:  http://localhost:8081"
echo "  Swagger UI:  http://localhost:8080/swagger-ui.html"
echo "  Prometheus:  http://localhost:9090"
echo "  MinIO:       http://localhost:9001"
echo "  RabbitMQ:    http://localhost:15672"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Stop services:"
echo "  docker-compose down"
