#!/bin/bash
# Simple script to directly run the Together API without Docker

# Color codes for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}    Starting ZerePy API (Direct Mode)    ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Setup environment
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  No .env file found, creating one with mock values...${NC}"
    echo "TOGETHER_API_KEY=mock-key" > .env
    echo "TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf" >> .env
fi

# Load environment variables
source .env
export TOGETHER_API_KEY=${TOGETHER_API_KEY:-"mock-key"}
export TOGETHER_MODEL=${TOGETHER_MODEL:-"meta-llama/Llama-3-70b-chat-hf"}

# Kill any existing processes
echo -e "${BLUE}Stopping any existing ZerePy processes...${NC}"
pkill -f "uvicorn src.together_api:app" &> /dev/null || true
pkill -f "python -m uvicorn src.together_api:app" &> /dev/null || true

# Install required packages if they're not already installed
echo -e "${BLUE}Checking for required packages...${NC}"
pip install uvicorn fastapi requests python-dotenv > /dev/null 2>&1

# Run the server
echo -e "${BLUE}Starting ZerePy API server...${NC}"
echo -e "${BLUE}API URL: http://localhost:8000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Run Python directly, not as a module
cd $(dirname "$0")
python -m uvicorn src.together_api:app --host 0.0.0.0 --port 8000
