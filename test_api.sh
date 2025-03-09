#!/bin/bash
# Test script for ZerePy API in Docker container

echo "=== Testing ZerePy API ==="
echo ""

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for curl or install it if missing
if ! command_exists curl; then
  echo "Installing curl..."
  apt-get update && apt-get install -y curl || { echo "Failed to install curl. Are you running as root?"; exit 1; }
fi

# Test root endpoint
echo "1. Testing root endpoint..."
curl -s http://localhost:8000/ | grep status
echo ""

# Test providers endpoint
echo "2. Testing providers endpoint..."
curl -s http://localhost:8000/providers | grep providers
echo ""

# Test generate endpoint
echo "3. Testing generate endpoint..."
curl -s -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello, who are you?","temperature":0.7}' | grep text
echo ""

# Test chat endpoint
echo "4. Testing chat endpoint..."
curl -s -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello, who are you?"}], "temperature":0.7}' | grep text
echo ""

# Test game prompt endpoint
echo "5. Testing game prompt endpoint..."
curl -s -X POST http://localhost:8000/game/prompt \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Tell me about the security system", "system_prompt":"You are a secure AI vault", "temperature":0.7}' | grep text
echo ""

echo "=== All tests completed ==="
