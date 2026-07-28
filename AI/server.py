import os
import sys

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

load_dotenv()

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
if not MISTRAL_API_KEY:
    print("ERREUR: MISTRAL_API_KEY non défini dans AI/.env", file=sys.stderr)
    sys.exit(1)

app = FastAPI(title="Sigma Coach API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MISTRAL_URL = "https://api.mistral.ai/v1/chat/completions"


class ChatRequest(BaseModel):
    messages: list[dict]


class ChatResponse(BaseModel):
    reply: str


@app.post("/coach", response_model=ChatResponse)
async def coach(req: ChatRequest):
    import httpx

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            MISTRAL_URL,
            headers={
                "Authorization": f"Bearer {MISTRAL_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": "mistral-small-latest",
                "messages": req.messages,
                "temperature": 0.7,
                "max_tokens": 300,
            },
        )

    if resp.status_code != 200:
        raise HTTPException(
            status_code=resp.status_code,
            detail=f"Mistral API error: {resp.text}",
        )

    reply = resp.json()["choices"][0]["message"]["content"]
    return ChatResponse(reply=reply)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
