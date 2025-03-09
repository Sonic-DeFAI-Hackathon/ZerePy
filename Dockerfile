FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl && apt-get clean

# Install uv for faster Python package management
RUN pip install uv

# Copy only the dependency files first to leverage Docker cache
COPY pyproject.toml poetry.lock* ./

# Install dependencies directly with uv
RUN python -m uv pip install -U pip && \
    python -m uv pip install uvicorn==0.29.0 fastapi==0.112.1 pydantic==2.6.4 python-dotenv==1.0.1

# Copy the rest of the application
COPY . .

# Make sure the scripts are executable
RUN chmod +x /app/start_baultro_api.sh
RUN chmod +x /app/docker-entrypoint.sh

# Expose the FastAPI port
EXPOSE 8000

# Run the FastAPI server using our entrypoint script
CMD ["/app/docker-entrypoint.sh"]
