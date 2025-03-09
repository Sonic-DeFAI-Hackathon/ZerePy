#!/bin/bash
# Direct execution of the Together API server

# Stop any existing containers
docker-compose -f docker-compose.minimal.yml down

# Check for Together API key
if [ -f .env ]; then
  source .env
  if [ -n "$TOGETHER_API_KEY" ]; then
    echo "Using Together API key from .env"
    export TOGETHER_API_KEY
    export TOGETHER_MODEL=${TOGETHER_MODEL:-meta-llama/Llama-3-70b-chat-hf}
  else
    echo "No Together API key found in .env"
    exit 1
  fi
else
  echo "No .env file found"
  exit 1
fi

# Install required packages
pip install --quiet fastapi uvicorn requests python-dotenv

# Start the API server directly
echo "Starting API server on http://localhost:8000"
cd /Users/pc/apps/MPC/hackathons/game/ZerePy
python -m uvicorn src.together_api:app --host 0.0.0.0 --port 8000
