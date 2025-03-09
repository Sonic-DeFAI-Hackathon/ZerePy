#!/bin/bash
# Quick start script for ZerePy Docker setup

echo "=== ZerePy Docker Quick Start ==="
echo ""
echo "This script will help you build and run the ZerePy API in Docker."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed. Please install Docker first."
  exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
  echo "Error: Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

# Function to check for newer Docker Compose command format
use_new_compose() {
  if docker compose version &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# Building the Docker image
echo "Building the Docker image..."
if use_new_compose; then
  docker compose build
else
  docker-compose build
fi

# Running the container
echo ""
echo "Starting the ZerePy API container..."
if use_new_compose; then
  docker compose up -d
else
  docker-compose up -d
fi

# Wait for container to be ready
echo ""
echo "Waiting for container to be ready..."
sleep 5

# Run tests in the container
echo ""
echo "Running API tests inside the container..."
if use_new_compose; then
  docker compose exec zerepy-api /app/test_api.sh
else
  docker-compose exec zerepy-api /app/test_api.sh
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "ZerePy API is running at: http://localhost:8000"
echo ""
echo "You can use the following commands:"
echo "  - View logs: docker compose logs -f"
echo "  - Stop container: docker compose down"
echo "  - Restart container: docker compose restart"
echo ""
echo "For more information, see the ZEREPY-INTEGRATION.md documentation."
