#!/bin/bash
# Start the ZerePy API server with Together AI integration

echo "Starting ZerePy API server with Together AI integration..."

# Make sure Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Use the API key from env.txt
TOGETHER_API_KEY=$(grep TOGETHER_API_KEY env.txt | cut -d= -f2)
TOGETHER_MODEL=$(grep TOGETHER_MODEL env.txt | cut -d= -f2)

if [ -z "$TOGETHER_API_KEY" ]; then
  echo "⚠️ No Together API key found in env.txt file."
  exit 1
fi

echo "Using Together API key: ${TOGETHER_API_KEY:0:6}...${TOGETHER_API_KEY:(-6)}"
echo "Using model: $TOGETHER_MODEL"

# Stop and remove any existing containers
docker-compose -f docker-compose.together.yml down

# Build and start the container with environment variables
docker-compose -f docker-compose.together.yml build --no-cache
docker-compose -f docker-compose.together.yml up -d \
  -e TOGETHER_API_KEY=$TOGETHER_API_KEY \
  -e TOGETHER_MODEL=$TOGETHER_MODEL

# Check if container started successfully
if docker-compose -f docker-compose.together.yml ps | grep -q "zerepy-api"; then
  echo "✅ ZerePy API server with Together AI integration started successfully!"
  echo "API is available at http://localhost:8000"

  # Test the API
  echo "Testing the API..."
  sleep 3
  curl -s http://localhost:8000/
  echo ""
  echo "Testing text generation..."
  curl -s -X POST http://localhost:8000/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Hello, what is Baultro?", "temperature":0.7}'
  echo ""
else
  echo "❌ Failed to start ZerePy API server."
  docker-compose -f docker-compose.together.yml logs
  exit 1
fi