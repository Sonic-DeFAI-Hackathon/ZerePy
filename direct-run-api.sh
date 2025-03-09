#!/bin/bash

# Stop any existing processes first
pkill -f "uvicorn.*standalone_api" || true

# Make sure we have all dependencies
echo "Installing required dependencies..."
pip install fastapi uvicorn requests python-dotenv

# Create a simplified .env file if it doesn't exist
if [ ! -f .env ]; then
  echo "Creating a simplified .env file..."
  cat > .env << EOL
TOGETHER_API_KEY=your_api_key
MOCK_LLM=true
EOL
fi

# Run the standalone API directly
echo "Starting ZerePy API server..."
uvicorn src.standalone_api:app --host 0.0.0.0 --port 8000 --reload
