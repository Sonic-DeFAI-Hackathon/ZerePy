#!/usr/bin/env python3
"""
Simple script to directly run the together API
"""
import os
import sys
import subprocess
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
together_key = os.getenv("TOGETHER_API_KEY")
together_model = os.getenv("TOGETHER_MODEL", "meta-llama/Llama-3-70b-chat-hf")

if not together_key:
    print("Error: TOGETHER_API_KEY not found")
    sys.exit(1)

print(f"Using Together AI with model: {together_model}")

# Stop any existing services
print("Stopping any existing services...")
subprocess.run("docker-compose -f docker-compose.minimal.yml down", shell=True)

# Install dependencies
print("Installing dependencies...")
subprocess.run("pip install fastapi uvicorn python-dotenv requests", shell=True)

# Set environment variables
os.environ["TOGETHER_API_KEY"] = together_key
os.environ["TOGETHER_MODEL"] = together_model

# Start the server
print("\nStarting API server at http://localhost:8000")
print("Press Ctrl+C to stop")
os.chdir("/Users/pc/apps/MPC/hackathons/game/ZerePy")
os.system("python -m uvicorn src.simple_together:app --host 0.0.0.0 --port 8000")
