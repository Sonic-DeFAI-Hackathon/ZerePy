#!/bin/bash
# Ultra-simple script to run the ZerePy API using simple_together.py

echo "Starting ZerePy API server using simple_together.py..."
echo "This will use mock mode without a real Together API key"

# Make sure uvicorn and other requirements are installed
pip install uvicorn fastapi requests python-dotenv > /dev/null 2>&1

# Set mock environment variables
export TOGETHER_API_KEY="mock-key"
export TOGETHER_MODEL="meta-llama/Llama-3-70b-chat-hf"

# Run the server
python -m uvicorn src.simple_together:app --host 0.0.0.0 --port 8000

echo "Server started on http://localhost:8000"
