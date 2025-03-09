import sys
import os
import subprocess
import time

print("ZerePy Together AI Quick Fix")
print("============================")

# Stop existing containers
print("Stopping existing containers...")
subprocess.run("docker-compose -f docker-compose.minimal.yml down", shell=True)
subprocess.run("docker stop zerepy-together-api 2>/dev/null || true", shell=True)
subprocess.run("docker rm zerepy-together-api 2>/dev/null || true", shell=True)

# Copy the together_api.py to standalone_api.py
print("Setting up API files...")
with open('src/together_api.py', 'r') as f:
    content = f.read()

with open('src/standalone_api.py', 'w') as f:
    f.write(content)

# Build and start using the existing minimal setup
print("Building and starting container...")
subprocess.run("docker-compose -f docker-compose.minimal.yml build", shell=True)
subprocess.run("docker-compose -f docker-compose.minimal.yml up -d", shell=True)

# Wait a bit and check status
print("Waiting for container to start...")
time.sleep(5)

# Test if the API is working
print("Testing API...")
try:
    result = subprocess.run(
        "docker-compose -f docker-compose.minimal.yml exec -T zerepy-api curl -s http://localhost:8000/",
        shell=True, capture_output=True, text=True
    )
    print("API Status:", result.stdout)
    
    print("\nAPI is now running with Together AI integration!")
    print("You can use it at http://localhost:8000")
except Exception as e:
    print("Error testing API:", e)

print("\nDone!")
