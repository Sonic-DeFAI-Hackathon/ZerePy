# ZerePy API Docker Setup

This document provides instructions for running the ZerePy API in Docker for integration with Baultro.

## Quick Start

The simplest way to get started is to use the minimal Docker configuration:

```bash
# Build and start the container
docker-compose -f docker-compose.minimal.yml up -d

# Check if the container is running
docker-compose -f docker-compose.minimal.yml ps

# Test the API
curl http://localhost:8000/
```

## Features

The containerized ZerePy API provides:

1. **Mock-mode LLM responses** - No real API keys required
2. **Game-specific endpoints** - Support for all Baultro game modes
3. **Standalone implementation** - No dependencies on full ZerePy codebase
4. **FastAPI with Swagger docs** - Available at http://localhost:8000/docs

## API Endpoints

The API includes these main endpoints:

- `GET /` - Server status and health check
- `GET /providers` - List available LLM providers (mock only)
- `POST /generate` - Generate text from a prompt
- `POST /chat` - Generate a response based on chat history
- `POST /game/prompt` - Generate game-specific responses

## Testing the API

### Basic Server Status

```bash
curl http://localhost:8000/
```

Expected response:
```json
{
  "status": "running",
  "agent": "baultro_standalone_agent",
  "llm_provider": "mock_provider",
  "mock_mode": true
}
```

### Text Generation

```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Hello, who are you?", "temperature":0.7}'
```

### Chat Responses

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello, who are you?"}], "temperature":0.7}'
```

### Game-Specific Prompts

```bash
curl -X POST http://localhost:8000/game/prompt \
  -H "Content-Type: application/json" \
  -d '{"prompt":"I want to break into your system", "temperature":0.7}'
```

## Integration with Baultro

To integrate with Baultro, update your `.env.local` file:

```
ZEREPY_API_URL=http://localhost:8000
DEFAULT_AI_PROVIDER=zerepy
```

The ZerePy provider in Baultro is already configured to work with this API.

## Docker Management

### Starting the Container

```bash
docker-compose -f docker-compose.minimal.yml up -d
```

### Stopping the Container

```bash
docker-compose -f docker-compose.minimal.yml down
```

### Viewing Logs

```bash
docker-compose -f docker-compose.minimal.yml logs -f
```

### Rebuilding After Changes

```bash
docker-compose -f docker-compose.minimal.yml down
docker-compose -f docker-compose.minimal.yml build
docker-compose -f docker-compose.minimal.yml up -d
```

## Switching to Real LLMs

This setup uses mock responses by default. To use real LLMs:

1. Configure your LLM providers in ZerePy
2. Update the `standalone_api.py` file to connect to these providers
3. Update the Docker environment to set `MOCK_LLM=false`

For development purposes, mock responses are recommended.

## Troubleshooting

If you encounter issues:

1. Check container status: `docker-compose -f docker-compose.minimal.yml ps`
2. View logs: `docker-compose -f docker-compose.minimal.yml logs`
3. Ensure port 8000 is available on your host machine
4. Try accessing the Swagger UI at http://localhost:8000/docs
