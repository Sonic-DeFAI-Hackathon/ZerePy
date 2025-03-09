#!/bin/bash
set -e

echo "🚀 Starting ZerePy Baultro API server with Together AI integration..."

# Check if Together API key is provided
if [ -z "$TOGETHER_API_KEY" ]; then
  echo "⚠️ WARNING: TOGETHER_API_KEY is not set. The API will run in mock mode."
else
  echo "🧠 Together AI API key found. Using model: ${TOGETHER_MODEL:-meta-llama/Llama-3-70b-chat-hf}"
fi

# Create a default agent file if it doesn't exist
AGENT_DIR="/app/agents"
DEFAULT_AGENT_FILE="$AGENT_DIR/default.json"

if [ ! -d "$AGENT_DIR" ]; then
  echo "📁 Creating agents directory..."
  mkdir -p "$AGENT_DIR"
fi

if [ ! -f "$DEFAULT_AGENT_FILE" ]; then
  echo "📝 Creating default agent configuration..."
  cat > "$DEFAULT_AGENT_FILE" << EOF
{
  "name": "BaultroAI",
  "bio": [
    "You are BaultroAI, an AI assistant for the Baultro gaming platform.",
    "You help players navigate through various game modes and provide responses based on the game context."
  ],
  "traits": ["Helpful", "Responsive", "Game-focused"],
  "examples": ["How can I help you with your Baultro gaming experience?", "I'm here to assist with your gaming needs."],
  "example_accounts": [],
  "loop_delay": 60,
  "config": [
    {
      "name": "together",
      "model": "${TOGETHER_MODEL:-meta-llama/Llama-3-70b-chat-hf}"
    }
  ],
  "tasks": [],
  "use_time_based_weights": false,
  "time_based_multipliers": {}
}
EOF
fi

# Start the FastAPI server
echo "🌐 Starting server on port 8000..."
echo "🔄 Using Together AI implementation for Baultro"
exec uvicorn src.together_api:app --host 0.0.0.0 --port 8000
