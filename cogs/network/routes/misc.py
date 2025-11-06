import hmac, hashlib
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse, Response
import time

router = APIRouter(prefix="/misc")

@router.post("/github", include_in_schema=False)
async def github_webhook(self, request: Request):
    event_type = request.headers.get('X-GitHub-Event')
    if event_type == "ping":
        return JSONResponse(content={"message": "Pong!"})
    
    if event_type != "push":
        return JSONResponse(content={"message": "Event type not supported."}, status_code=403)
    
    payload = request.read()
    
    signature = request.headers.get('X-Hub-Signature-256')
    if not signature:
        return JSONResponse(content={"message": "Missing signature."}, status_code=400)
    
    secret = "d0f9a543-87d0-4f40-906a-ceab5193d445".encode()
    expected_signature = 'sha256=' + hmac.new(secret, payload, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected_signature, signature):
        return JSONResponse(content={"message": "Invalid signature."}, status_code=401)
    cache_key = f"github_webhook:{request.remote}"
    if await self.bot.redis.exists(cache_key):
        return JSONResponse({"error": "Rate limited"}, status=429)
    await self.bot.redis.set(cache_key, "1", ex=2)  


@router.get("/health")
async def health(self):
        return JSONResponse({
            "status": "ok",
            "timestamp": int(time.time()),
            "uptime": int(self.bot.uptime2)
        })