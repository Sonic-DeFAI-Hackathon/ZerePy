#!/bin/bash
# Run simple Together AI server

# Stop any existing containers
echo "Stopping any existing containers..."
docker-compose -f docker-compose.minimal.yml down

# Install required dependencies
echo "Installing dependencies..."
pip install -q fastapi uvicorn requests python-dotenv

# Start the server
echo "Starting Together AI server on http://localhost:8000"
echo "Press Ctrl+C to stop"
echo ""

# Run the server
cd /Users/pc/apps/MPC/hackathons/game/ZerePy
python -m uvicorn src.simple_together:app --host 0.0.0.0 --port 8000
