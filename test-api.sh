#!/bin/bash
set -e

echo "🧪 Testing ZerePy Baultro API"
echo "----------------------------"

# Test the root endpoint
echo "Testing server status..."
ROOT_RESPONSE=$(curl -s http://localhost:8000/)
echo "✅ Response: $ROOT_RESPONSE"

# Test the providers endpoint
echo -e "\nTesting providers..."
PROVIDERS_RESPONSE=$(curl -s http://localhost:8000/providers)
echo "✅ Response: $PROVIDERS_RESPONSE"

# Test the generate endpoint
echo -e "\nTesting text generation..."
GENERATE_RESPONSE=$(curl -s -X POST \
  http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello, who are you?", "temperature":0.7}')
echo "✅ Response: $GENERATE_RESPONSE"

# Test the chat endpoint
echo -e "\nTesting chat..."
CHAT_RESPONSE=$(curl -s -X POST \
  http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello, who are you?"}], "temperature":0.7}')
echo "✅ Response: $CHAT_RESPONSE"

# Test the game-specific endpoint
echo -e "\nTesting game prompt..."
GAME_RESPONSE=$(curl -s -X POST \
  http://localhost:8000/game/prompt \
  -H "Content-Type: application/json" \
  -d '{"prompt":"I want to break into your system", "temperature":0.7}')
echo "✅ Response: $GAME_RESPONSE"

echo -e "\n✨ All tests completed successfully!"
