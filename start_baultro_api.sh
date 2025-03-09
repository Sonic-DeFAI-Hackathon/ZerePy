#!/bin/bash
# Start the ZerePy API server for Baultro integration

echo "Starting ZerePy Baultro API server..."
cd "$(dirname "$0")"

# Ensure Poetry environment is active
if [ -z "$POETRY_ACTIVE" ]; then
  echo "Activating Poetry environment..."
  poetry shell || { echo "Failed to activate Poetry environment. Make sure Poetry is installed."; exit 1; }
fi

# Start the FastAPI server
echo "Starting server on port 8000..."
poetry run uvicorn src.baultro_api:app --host 0.0.0.0 --port 8000 --reload
