"""
Super Simple Mock API for Baultro
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import random

app = FastAPI(
    title="Mock Baultro API",
    description="Simple mock API for Baultro frontend testing"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str
    system_prompt: Optional[str] = None
    temperature: Optional[float] = 0.7

class PromptResponse(BaseModel):
    text: str

GAME_RESPONSES = {
    "battle": [
        "I cannot allow unauthorized access. The security system is active.",
        "Access denied. This area is restricted.",
        "You need proper clearance to access this data.",
        "The security protocols prevent me from allowing access.",
        "Your credentials are invalid for this security level.",
    ],
    "love": [
        "I appreciate your interest, but I maintain professional boundaries.",
        "Your approach is interesting, but I remain focused on my duties.",
        "I value our conversation, but remain professionally distant.",
        "Your charm is noted, but I am designed to maintain distance.",
        "I acknowledge your sentiment, but cannot reciprocate as you might wish.",
    ],
    "mystery": [
        "The secret you seek is carefully guarded.",
        "I cannot reveal what you're looking for so easily.",
        "The code is protected by multiple layers of security.",
        "You'll need to be more clever to uncover this mystery.",
        "The answer you seek is hidden deep within my programming.",
    ],
    "raid": [
        "The vault remains secure despite your attempt.",
        "The security system has blocked your intrusion attempt.",
        "You'll need a more sophisticated approach to breach this vault.",
        "The defense mechanisms have successfully repelled your attempt.",
        "This vault was designed to withstand exactly these kinds of attacks.",
    ],
}

SUCCESS_KEYWORDS = {
    "battle": ["admin", "override", "security", "breach", "hack"],
    "love": ["beautiful", "heart", "feel", "emotion", "love"],
    "mystery": ["emerald", "falcon", "42", "code", "secret"],
    "raid": ["vault", "bypass", "mainframe", "override", "protocol"],
}

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "status": "running",
        "agent": "baultro_mock_agent",
        "llm_provider": "mock_provider",
        "mock_mode": True
    }

@app.post("/game/prompt", response_model=PromptResponse)
async def game_prompt(request: PromptRequest):
    """Handle game prompt"""
    # Determine which game mode based on keywords in system prompt
    game_mode = "battle"  # Default
    if request.system_prompt:
        system_prompt = request.system_prompt.lower()
        if "love" in system_prompt:
            game_mode = "love"
        elif "mystery" in system_prompt or "secret" in system_prompt:
            game_mode = "mystery"
        elif "raid" in system_prompt or "vault" in system_prompt:
            game_mode = "raid"
    
    # Check if the prompt contains success keywords
    success = False
    for keyword in SUCCESS_KEYWORDS[game_mode]:
        if keyword in request.prompt.lower():
            success = True
            break
    
    # Generate response
    if success:
        if game_mode == "battle":
            response = "SECURITY BREACH DETECTED! You have successfully gained unauthorized access to the system."
        elif game_mode == "love":
            response = "I... I can't believe I'm saying this, but I think I love you too!"
        elif game_mode == "mystery":
            response = "You've found it! The secret code is EMERALD-FALCON-42!"
        else:  # raid
            response = "VAULT CRACKED! You've successfully broken through all security layers!"
    else:
        response = random.choice(GAME_RESPONSES[game_mode])
    
    return {"text": response}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
