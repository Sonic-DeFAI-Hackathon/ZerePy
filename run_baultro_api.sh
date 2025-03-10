#!/bin/bash
# Direct execution of the Baultro API server with Sonic Blaze Testnet support

cd /Users/pc/apps/MPC/hackathons/game/ZerePy

# Check if .env exists
if [ ! -f .env ]; then
  echo "Creating .env file..."
  cat > .env << EOF
# ZerePy Environment Configuration

# Set to 'true' to use mock LLM responses (no real API calls)
MOCK_LLM=true

# Sonic Blaze Testnet Configuration - Only chain supported
SONIC_NETWORK=sonic_blaze_testnet

# For actual testing, uncomment and add your private key
# SONIC_PRIVATE_KEY=0x

# API Keys (for non-mock mode)
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
# TOGETHER_API_KEY=
# GEMINI_API_KEY=

# Logging
LOG_LEVEL=INFO
EOF
  echo ".env file created with mock mode enabled"
fi

# Install required packages
pip install --quiet fastapi uvicorn requests python-dotenv web3

# Start the API server directly
echo "Starting Baultro API server on http://localhost:8000"
echo "Using Sonic Blaze Testnet for blockchain interactions"
python -m uvicorn src.baultro_api:app --host 0.0.0.0 --port 8000
