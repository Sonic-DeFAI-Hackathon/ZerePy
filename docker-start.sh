#!/bin/bash
# Start ZerePy with Together AI using Docker

echo "Starting ZerePy with Together AI integration"
echo "=========================================="

# Load API key from .env
source .env
TOGETHER_KEY=${TOGETHER_API_KEY}
TOGETHER_MODEL=${TOGETHER_MODEL:-meta-llama/Llama-3-70b-chat-hf}

if [ -z "$TOGETHER_KEY" ]; then
  echo "❌ No Together API key found in .env file"
  exit 1
fi

echo "Using model: $TOGETHER_MODEL"

# Stop existing containers
echo "Stopping existing containers..."
docker-compose -f docker-compose.minimal.yml down
docker stop zerepy-together 2>/dev/null || true
docker rm zerepy-together 2>/dev/null || true

# Create a Dockerfile on the fly
echo "Creating Dockerfile..."
cat > Dockerfile.simple << EOF
FROM python:3.10-slim

WORKDIR /app

RUN pip install --no-cache-dir fastapi==0.112.1 uvicorn==0.29.0 python-dotenv==1.0.1 requests==2.31.0

COPY src/simple_together.py /app/src/
COPY .env /app/

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "src.simple_together:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Build the Docker image
echo "Building Docker image..."
docker build -t zerepy-together:latest -f Dockerfile.simple .

# Run the container
echo "Starting container..."
docker run -d --name zerepy-together -p 8000:8000 \
  -e TOGETHER_API_KEY="$TOGETHER_KEY" \
  -e TOGETHER_MODEL="$TOGETHER_MODEL" \
  zerepy-together:latest

# Check if container started
echo "Waiting for API to start..."
sleep 3

if docker ps | grep -q zerepy-together; then
  echo "✅ Container started successfully"
  echo "API available at http://localhost:8000"
  
  # Test the API
  echo ""
  echo "Testing API server..."
  curl -s http://localhost:8000/ | jq .
  
  echo ""
  echo "Try sending a test request:"
  echo 'curl -X POST http://localhost:8000/generate -H "Content-Type: application/json" -d '\''{"prompt":"Hello, what is Baultro?"}'\'''
else
  echo "❌ Failed to start container"
  docker logs zerepy-together
fi
