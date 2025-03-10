#!/bin/bash

# Setup Baultro with Sonic Blaze Testnet
echo "🔷 Setting up Baultro with Sonic Blaze Testnet"

# Check if .env exists and create if not
if [ ! -f .env ]; then
    touch .env
    echo "Created new .env file"
fi

# Set required environment variables
if [ -z "$SONIC_PRIVATE_KEY" ]; then
    echo "Enter your Sonic Blaze Testnet wallet private key (without 0x prefix):"
    read -s private_key
    if [[ ! $private_key == 0x* ]]; then
        private_key="0x$private_key"
    fi
    echo "SONIC_PRIVATE_KEY=$private_key" >> .env
    echo "Private key configured."
fi

# Set default network to sonic_blaze_testnet 
echo "SONIC_NETWORK=sonic_blaze_testnet" >> .env

# Set up API key for Gemini (required for Baultro gaming AI)
if [ -z "$GEMINI_API_KEY" ]; then
    echo "Enter your Google Gemini API key (required for Baultro AI gameplay):"
    read api_key
    echo "GEMINI_API_KEY=$api_key" >> .env
    echo "Gemini API key configured."
fi

echo "✅ Setup complete! Starting Baultro API server..."
uvicorn src.baultro_api:app --host 0.0.0.0 --port 8000 --reload
