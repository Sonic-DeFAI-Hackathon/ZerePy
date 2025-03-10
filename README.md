# ZerePy with Together AI Integration for Baultro

This document describes how to set up and use the ZerePy integration with Together AI for the Baultro gaming platform.

## Overview

This integration provides a FastAPI server that connects to the Together AI API, allowing Baultro to use Together AI's powerful language models for its AI-powered gameplay features.

## Setup Instructions 

### 1. Prerequisites

- Docker and Docker Compose installed
- Together AI API key (get one from https://www.together.ai/)

### 2. Configuration

1. Create or edit the `.env` file in the ZerePy directory:

   ```
   # Together AI API key
   TOGETHER_API_KEY=your_together_api_key_here
   # Together AI model to use
   TOGETHER_MODEL=meta-llama/Llama-3-70b-chat-hf
   ```

   Replace `your_together_api_key_here` with your actual Together AI API key.

2. You can optionally change the model by modifying the `TOGETHER_MODEL` variable. Available options include:
   - `meta-llama/Llama-3-70b-chat-hf` (default)
   - `meta-llama/Llama-3-8b-chat-hf`
   - `mistralai/Mixtral-8x7B-Instruct-v0.1`
   - `togethercomputer/StripedHyena-Nous-7B`
   - And many more available on Together AI

### 3. Starting the API Server

You can start the server using the provided script:

```bash
./start-together-api.sh
```

This will:
1. Check for the required configuration
2. Build and start the Docker container
3. Make the API available at http://localhost:8000

Alternatively, you can use Docker Compose directly:

```bash
docker-compose -f docker-compose.together.yml up -d
```

### 4. Verification

You can verify that the API is working correctly by accessing:

```
http://localhost:8000/
```

You should see a JSON response with server status information.

To test text generation, you can use curl:

```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello, what is Baultro?", "temperature":0.7}'
```

## API Endpoints

The ZerePy API with Together AI integration provides the following endpoints:

### 1. GET /

Returns server status information.

### 2. GET /providers

Lists available LLM providers (Together AI).

### 3. POST /generate

Generates text from a prompt.

**Request Body:**
```json
{
  "prompt": "Your prompt text here",
  "system_prompt": "Optional system instructions",
  "model": "Optional model override",
  "temperature": 0.7,
  "max_tokens": 1024
}
```

### 4. POST /chat

Generates a response based on chat history.

**Request Body:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello, how are you?"
    },
    {
      "role": "assistant",
      "content": "I'm doing well, thank you for asking!"
    },
    {
      "role": "user",
      "content": "What is Baultro?"
    }
  ],
  "system_prompt": "Optional system instructions",
  "model": "Optional model override",
  "temperature": 0.7,
  "max_tokens": 1024
}
```

### 5. POST /game/prompt

Generates a game-specific response for Baultro.

**Request Body:**
```json
{
  "prompt": "Your game-related prompt here",
  "system_prompt": "love", // or "battle", "mystery", "raid"
  "temperature": 0.7,
  "max_tokens": 1024
}
```

## Integration with Baultro

To integrate this API with Baultro, you'll need to:

1. Make sure the API server is running
2. Configure the ZerePy provider in Baultro to point to this API server
3. Update your environment settings to use ZerePy with Together AI

For detailed instructions on integrating with Baultro, see the main ZEREPY-INTEGRATION.md file.

## Troubleshooting

### API Key Issues

If you see this message:
```
⚠️ WARNING: TOGETHER_API_KEY is not set. The API will run in mock mode.
```

It means your Together AI API key is not being properly passed to the container. Check your `.env` file and make sure the key is correct.

### Container Issues

If the container fails to start:

1. Check logs with:
   ```bash
   docker-compose -f docker-compose.together.yml logs
   ```

2. Make sure the ports aren't already in use:
   ```bash
   sudo lsof -i :8000
   ```

### API Response Issues

If you're getting mock responses instead of real ones:

1. Check the server status to see if it's in mock mode:
   ```
   curl http://localhost:8000/
   ```

2. Verify your Together AI API key is valid and has not expired.

## Advanced Configuration

### Custom Models

You can specify any model supported by Together AI by setting the `TOGETHER_MODEL` environment variable.

### System Prompts

The API includes custom system prompts for each game mode:
- Battle Mode: Security-focused vault protection
- Love Mode: AI assistant avoiding saying "I love you"
- Mystery Mode: AI with a hidden secret
- Raid Mode: Multi-layer security system

You can customize these prompts by editing the `GAME_SYSTEM_PROMPTS` dictionary in `together_api.py`.