#!/bin/bash
# Script to run the Baultro API for testing

cd "$(dirname "$0")"

# Create a .env file if it doesn't exist
if [ ! -f .env ]; then
  echo "Creating .env file with Sonic Blaze Testnet configuration"
  cat > .env << EOF
# ZerePy Environment Configuration for Baultro Test

# Use mock LLM responses to avoid requiring API keys
MOCK_LLM=true

# Sonic Blaze Testnet Configuration - Only chain supported
SONIC_NETWORK=sonic_blaze_testnet

# You can add your Sonic private key here for testing blockchain functions
# SONIC_PRIVATE_KEY=0x

# Uncomment and add your API keys if you want to use real LLM responses
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
# GEMINI_API_KEY=
EOF
  echo ".env file created with mock mode enabled"
fi

# Install required packages if needed
pip install -q fastapi uvicorn python-dotenv web3

# Start the API server in test mode
echo "Starting Baultro API server for testing on http://localhost:8888"
echo "Using Sonic Blaze Testnet as the only supported blockchain"
echo "Press Ctrl+C to stop the server"
python -m uvicorn src.baultro_api:app --host 0.0.0.0 --port 8888 --reload
