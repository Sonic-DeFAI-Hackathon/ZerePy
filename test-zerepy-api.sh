#!/bin/bash
# ZerePy E2E Testing Script
# This script starts the ZerePy server and tests it with curl commands

# Color codes for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(pwd)"

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}        ZerePy API Test Suite         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Check if Docker is running
if command -v docker &> /dev/null; then
    if ! docker info &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker is not running. Attempting to run without Docker.${NC}"
        USE_DOCKER=false
    else
        echo -e "${GREEN}✅ Docker is running.${NC}"
        USE_DOCKER=true
    fi
else
    echo -e "${YELLOW}⚠️  Docker is not installed. Attempting to run without Docker.${NC}"
    USE_DOCKER=false
fi

# Setup environment
echo -e "\n${BLUE}Setting up environment...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  No .env file found, creating one with mock values...${NC}"
    echo "TOGETHER_API_KEY=mock-key" > .env
    echo "TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf" >> .env
else
    echo -e "${GREEN}✅ Using existing .env file.${NC}"
fi

# Stop any existing containers or processes
echo -e "\n${BLUE}Stopping any existing ZerePy processes...${NC}"
if [ "$USE_DOCKER" = true ]; then
    docker-compose down &> /dev/null
    docker stop zerepy-together-api 2>/dev/null || true
    docker rm zerepy-together-api 2>/dev/null || true
else
    pkill -f "uvicorn src.together_api:app" &> /dev/null || true
    pkill -f "python -m uvicorn src.together_api:app" &> /dev/null || true
fi

# Start ZerePy API server
echo -e "\n${BLUE}Starting ZerePy API server...${NC}"
API_URL="http://localhost:8000"

# Set up logging
mkdir -p logs
LOG_FILE="logs/zerepy_api_$(date +%Y%m%d_%H%M%S).log"

# Choose the appropriate method to start the server
if [ "$USE_DOCKER" = true ]; then
    # Start with Docker
    echo -e "${BLUE}Starting with Docker...${NC}"
    TOGETHER_API_KEY=$(grep TOGETHER_API_KEY .env | cut -d= -f2)
    TOGETHER_MODEL=$(grep TOGETHER_MODEL .env | cut -d= -f2)
    docker-compose -f docker-compose.together.yml down &> /dev/null
    docker-compose -f docker-compose.together.yml up -d > "$LOG_FILE" 2>&1
else
    # Start directly with Python
    echo -e "${BLUE}Starting with Python...${NC}"
    source .env &> /dev/null || true
    export TOGETHER_API_KEY=${TOGETHER_API_KEY:-"mock-key"}
    export TOGETHER_MODEL=${TOGETHER_MODEL:-"meta-llama/Llama-3-70b-chat-hf"}
    
    # Check if uvicorn is installed
    if ! command -v uvicorn &> /dev/null; then
        echo -e "${YELLOW}⚠️  uvicorn not found, attempting to install...${NC}"
        pip install uvicorn fastapi requests python-dotenv > "$LOG_FILE" 2>&1
    fi
    
    # Start the server in the background
    python -m uvicorn src.together_api:app --host 0.0.0.0 --port 8000 > "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    echo "Server started with PID: $SERVER_PID" >> "$LOG_FILE"
fi

# Wait for server to start
echo -e "${BLUE}Waiting for server to start...${NC}"
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
    echo -e "${YELLOW}Check the log at: $LOG_FILE${NC}"
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

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! ZerePy API is working correctly.${NC}"
    echo -e "${GREEN}The server is now running and ready to be used by your frontend application.${NC}"
    echo -e "${BLUE}API URL: $API_URL${NC}"
else
    echo -e "${RED}❌ $FAILED_TESTS test(s) failed.${NC}"
    echo -e "${YELLOW}Check the log at: $LOG_FILE${NC}"
fi

# Don't stop the server if all tests passed
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${BLUE}The ZerePy API server is still running.${NC}"
    echo -e "${BLUE}Use the following to stop it:${NC}"
    if [ "$USE_DOCKER" = true ]; then
        echo -e "  docker-compose -f docker-compose.together.yml down"
    else
        echo -e "  kill $SERVER_PID"
    fi
else
    # Clean up if tests failed
    echo -e "\n${BLUE}Cleaning up...${NC}"
    if [ "$USE_DOCKER" = true ]; then
        docker-compose -f docker-compose.together.yml down &> /dev/null
    else
        [ -n "$SERVER_PID" ] && kill $SERVER_PID &> /dev/null
    fi
fi

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
    exit 0
else
    exit 1
fi
