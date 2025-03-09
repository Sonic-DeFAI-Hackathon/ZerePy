"""
Simple script to run the Together API directly without Docker
"""
import os
import sys
import subprocess
import time
from dotenv import load_dotenv

print("Running ZerePy Together API")
print("===========================")

# Load environment variables
load_dotenv()
together_key = os.getenv("TOGETHER_API_KEY")
together_model = os.getenv("TOGETHER_MODEL", "meta-llama/Llama-3-70b-chat-hf")

if not together_key:
    print("Error: TOGETHER_API_KEY not found in environment variables")
    print("Please set it in your .env file")
    sys.exit(1)

# Stop any running containers using port 8000
print("Stopping existing containers...")
subprocess.run("docker-compose -f docker-compose.minimal.yml down", shell=True)

# Install required packages
print("Installing required packages...")
subprocess.run("pip install --quiet fastapi uvicorn requests python-dotenv", shell=True)

# Run the API server
print(f"Starting API server with Together AI model: {together_model}")
print("\nAPI will be available at http://localhost:8000")
print("Press Ctrl+C to stop\n")

# Set environment variables for the subprocess
env = os.environ.copy()
env["TOGETHER_API_KEY"] = together_key
env["TOGETHER_MODEL"] = together_model

# Start the API server
subprocess.run("python -m uvicorn src.together_api:app --host 0.0.0.0 --port 8000", 
               shell=True, env=env)
