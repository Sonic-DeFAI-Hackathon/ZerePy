#!/bin/bash
# Direct run script for ZerePy with Together AI integration

# Load API key from .env
if [ -f .env ]; then
  source .env
  TOGETHER_KEY=${TOGETHER_API_KEY}
  TOGETHER_MODEL=${TOGETHER_MODEL:-meta-llama/Llama-3-70b-chat-hf}
  
  # Show masked API key for verification
  if [ -n "$TOGETHER_KEY" ]; then
    MASKED_KEY="${TOGETHER_KEY:0:6}...${TOGETHER_KEY: -6}"
    echo "Using Together API key: $MASKED_KEY"
    echo "Using model: $TOGETHER_MODEL"
  else
    echo "❌ No Together API key found in .env file"
    exit 1
  fi
else
  echo "❌ No .env file found"
  exit 1
fi

# Stop any existing containers (both minimal and together versions)
echo "Stopping any existing containers..."
docker-compose -f docker-compose.minimal.yml down 2>/dev/null
docker stop zerepy-together-api 2>/dev/null
docker rm zerepy-together-api 2>/dev/null

# Build Docker image
echo "Building Docker image..."
docker build -t zerepy-together-api:latest -f Dockerfile.together .

# Start container
echo "Starting container..."
docker run -d --name zerepy-together-api \
  -p 8000:8000 \
  -e TOGETHER_API_KEY="$TOGETHER_KEY" \
  -e TOGETHER_MODEL="$TOGETHER_MODEL" \
  zerepy-together-api:latest

# Check if container started successfully
echo "Checking container status..."
sleep 2
if [ "$(docker inspect -f {{.State.Running}} zerepy-together-api)" = "true" ]; then
  echo "✅ Container started successfully. API available at http://localhost:8000"
  echo ""
  echo "Test with:"
  echo "curl -X POST http://localhost:8000/generate \\"
  echo "  -H \"Content-Type: application/json\" \\"
  echo "  -d '{\"prompt\":\"Hello, what is Baultro?\", \"temperature\":0.7}'"
  echo ""
  echo "View logs with:"
  echo "docker logs -f zerepy-together-api"
else
  echo "❌ Container failed to start."
  docker logs zerepy-together-api
  exit 1
fi
