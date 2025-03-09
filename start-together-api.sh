#!/bin/bash
# Start the ZerePy API server with Together AI integration

echo "Starting ZerePy API server with Together AI integration..."

# Make sure Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
  echo "No .env file found. Creating a template .env file..."
  cat > .env << EOF
# Together AI API key
TOGETHER_API_KEY=your_together_api_key_here
# Together AI model to use
TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf
EOF
  echo "Please edit the .env file to add your Together AI API key."
  exit 1
fi

# Source the .env file to check for API key
source .env

if [ -z "$TOGETHER_API_KEY" ] || [ "$TOGETHER_API_KEY" == "your_together_api_key_here" ]; then
  echo "⚠️ No valid Together API key found in .env file."
  echo "Please edit the .env file to add your Together AI API key."
  exit 1
fi

# Stop and remove any existing containers
docker-compose -f docker-compose.together.yml down

# Build and start the container
docker-compose -f docker-compose.together.yml up -d

# Check if container started successfully
if docker-compose -f docker-compose.together.yml ps | grep -q "zerepy-api"; then
  echo "✅ ZerePy API server with Together AI integration started successfully!"
  echo "API is available at http://localhost:8000"
else
  echo "❌ Failed to start ZerePy API server."
  docker-compose -f docker-compose.together.yml logs
  exit 1
fi
