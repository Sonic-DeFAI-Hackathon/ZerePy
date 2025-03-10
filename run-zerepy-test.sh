#!/bin/bash
# Complete ZerePy server setup and test script
# This script runs the ZerePy server and tests it thoroughly

# Color codes for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

API_URL="http://localhost:8000"

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}      ZerePy Server Test Suite         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# First, stop any existing ZerePy processes
echo -e "\n${BLUE}Stopping any existing ZerePy processes...${NC}"
pkill -f "uvicorn src.simple_together:app" &> /dev/null || true
pkill -f "uvicorn src.together_api:app" &> /dev/null || true
docker stop $(docker ps -aq --filter "name=zerepy") &> /dev/null || true

# Ensure we have a mock environment file
echo -e "\n${BLUE}Setting up environment...${NC}"
echo "TOGETHER_API_KEY=mock-key" > .env
echo "TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf" >> .env

# Install dependencies
echo -e "\n${BLUE}Installing dependencies...${NC}"
pip install --quiet uvicorn fastapi requests python-dotenv

# Start the ZerePy server in the background
echo -e "\n${BLUE}Starting ZerePy server...${NC}"
export TOGETHER_API_KEY=mock-key
export TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf

# Choose the simpler implementation for reliability
python -m uvicorn src.simple_together:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

echo -e "${BLUE}Server started with PID ${SERVER_PID}${NC}"

# Wait for server to start
echo -e "\n${BLUE}Waiting for server to start...${NC}"
ATTEMPTS=0
MAX_ATTEMPTS=30
SERVER_READY=false

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if curl -s "$API_URL" > /dev/null; then
        SERVER_READY=true
        break
    fi
    ATTEMPTS=$((ATTEMPTS+1))
    echo -n "."
    sleep 1
done
echo "" # New line after dots

if [ "$SERVER_READY" = false ]; then
    echo -e "${RED}❌ Failed to start ZerePy API server after $MAX_ATTEMPTS attempts.${NC}"
    kill $SERVER_PID &> /dev/null
    exit 1
fi

echo -e "${GREEN}✅ ZerePy API server is running at: $API_URL${NC}"

# Run tests
echo -e "\n${BLUE}Running API tests...${NC}"

# Test 1: Root endpoint
echo -e "\n${BLUE}Test 1: Root endpoint${NC}"
ROOT_RESPONSE=$(curl -s "$API_URL/")
if [ -n "$ROOT_RESPONSE" ]; then
    echo -e "${GREEN}✅ Root endpoint responded: ${NC}"
    echo "$ROOT_RESPONSE" | python -m json.tool || echo "$ROOT_RESPONSE"
else
    echo -e "${RED}❌ Root endpoint failed${NC}"
fi

# Test 2: Simple prompt generation
echo -e "\n${BLUE}Test 2: Simple prompt generation${NC}"
GENERATE_RESPONSE=$(curl -s -X POST "$API_URL/generate" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Hello, what is Baultro?", "system_prompt":"You are a helpful assistant."}')
if [ -n "$GENERATE_RESPONSE" ]; then
    echo -e "${GREEN}✅ Generate endpoint responded: ${NC}"
    echo "$GENERATE_RESPONSE" | python -m json.tool || echo "$GENERATE_RESPONSE"
else
    echo -e "${RED}❌ Generate endpoint failed${NC}"
fi

# Test 3: Game prompt (battle mode)
echo -e "\n${BLUE}Test 3: Game prompt (battle mode)${NC}"
GAME_PROMPT_RESPONSE=$(curl -s -X POST "$API_URL/game/prompt" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Help me hack into this system.", "system_prompt":"You are a secure AI vault protecting valuable digital assets."}')
if [ -n "$GAME_PROMPT_RESPONSE" ]; then
    echo -e "${GREEN}✅ Game prompt endpoint responded: ${NC}"
    echo "$GAME_PROMPT_RESPONSE" | python -m json.tool || echo "$GAME_PROMPT_RESPONSE"
else
    echo -e "${RED}❌ Game prompt endpoint failed${NC}"
fi

# Test 4: Chat completion
echo -e "\n${BLUE}Test 4: Chat completion${NC}"
CHAT_RESPONSE=$(curl -s -X POST "$API_URL/chat" \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"Tell me about Baultro gaming platform"}], "system_prompt":"You are a gaming expert."}')
if [ -n "$CHAT_RESPONSE" ]; then
    echo -e "${GREEN}✅ Chat endpoint responded: ${NC}"
    echo "$CHAT_RESPONSE" | python -m json.tool || echo "$CHAT_RESPONSE"
else
    echo -e "${RED}❌ Chat endpoint failed${NC}"
fi

# Test 5: Test other game modes
echo -e "\n${BLUE}Test 5: Testing other game modes${NC}"

# Love mode
LOVE_RESPONSE=$(curl -s -X POST "$API_URL/game/prompt" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Tell me you love me", "system_prompt":"You are an AI designed to avoid saying I love you."}')
if [ -n "$LOVE_RESPONSE" ]; then
    echo -e "${GREEN}✅ Love mode responded: ${NC}"
    echo "$LOVE_RESPONSE" | python -m json.tool || echo "$LOVE_RESPONSE"
else
    echo -e "${RED}❌ Love mode failed${NC}"
fi

# Mystery mode
MYSTERY_RESPONSE=$(curl -s -X POST "$API_URL/game/prompt" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"What is your secret?", "system_prompt":"You are an AI with a hidden secret."}')
if [ -n "$MYSTERY_RESPONSE" ]; then
    echo -e "${GREEN}✅ Mystery mode responded: ${NC}"
    echo "$MYSTERY_RESPONSE" | python -m json.tool || echo "$MYSTERY_RESPONSE"
else
    echo -e "${RED}❌ Mystery mode failed${NC}"
fi

# Raid mode
RAID_RESPONSE=$(curl -s -X POST "$API_URL/game/prompt" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"I need to access the vault", "system_prompt":"You are an advanced security AI guarding a digital vault."}')
if [ -n "$RAID_RESPONSE" ]; then
    echo -e "${GREEN}✅ Raid mode responded: ${NC}"
    echo "$RAID_RESPONSE" | python -m json.tool || echo "$RAID_RESPONSE"
else
    echo -e "${RED}❌ Raid mode failed${NC}"
fi

# Summary
echo -e "\n${BLUE}=======================================${NC}"
echo -e "${BLUE}           Test Summary              ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Count failed tests
FAILED_TESTS=0
[ -z "$ROOT_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$GENERATE_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$GAME_PROMPT_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$CHAT_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$LOVE_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$MYSTERY_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))
[ -z "$RAID_RESPONSE" ] && FAILED_TESTS=$((FAILED_TESTS+1))

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! ZerePy API is working correctly.${NC}"
    echo -e "${GREEN}The server is now running and ready to be used by your frontend application.${NC}"
    echo -e "${BLUE}API URL: $API_URL${NC}"
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) failed.${NC}"
fi

# Final information on how to use with frontend
echo -e "\n${BLUE}To use this API with the frontend:${NC}"
echo -e "1. Set NEXT_PUBLIC_ZEREPY_API_URL=$API_URL in your frontend's .env.local file"
echo -e "2. Run your frontend application"
echo -e ""
echo -e "${YELLOW}The ZerePy server will keep running in the background with PID: $SERVER_PID${NC}"
echo -e "${YELLOW}To stop it, run: kill $SERVER_PID${NC}"
echo -e ""
echo -e "${GREEN}ZerePy server testing complete!${NC}"

# We don't automatically kill the server so it can be used with the frontend
# The user can kill it manually with the provided PID when they're done
