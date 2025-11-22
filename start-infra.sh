#!/bin/bash
set -e

echo "Starting the CS2Panel infrastructure..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Build and start all services in the background
docker-compose up --build -d

echo "Infrastructure started successfully!"
echo "The UI is available at http://localhost"
