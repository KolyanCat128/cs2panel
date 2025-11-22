#!/bin/bash
set -e

echo "Stopping the CS2Panel infrastructure..."

# Stop and remove all services
docker-compose down

echo "Infrastructure stopped successfully!"
