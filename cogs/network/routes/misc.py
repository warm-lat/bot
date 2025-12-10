import hmac, hashlib, time, orjson, logging, config
from fastapi import APIRouter, Request, HTTPException, Header
from fastapi.responses import JSONResponse
from discord import Embed
from ..models.github import GithubPushEvent, CONFIG

log = logging.getLogger(__name__)

router = APIRouter(prefix="/misc", include_in_schema=False)

@router.post("/github")
async def github_webhook(request: Request):
    event_type = request.headers.get('X-GitHub-Event')
    
    if event_type == "ping":
        return JSONResponse(content={"message": "Pong!"})
    
    if event_type != "push":
        return JSONResponse(content={"message": "Event type not supported."}, status_code=403)
    
    payload = await request.body()
    
    signature = request.headers.get('X-Hub-Signature-256')
    
    if not signature:
        return JSONResponse(content={"message": "Missing signature."}, status_code=400)
    
    secret = "d0f9a543-87d0-4f40-906a-ceab5193d445".encode()
    
    expected_signature = 'sha256=' + hmac.new(
        secret, 
        payload, 
        hashlib.sha256
        ).hexdigest()
    
    if not hmac.compare_digest(expected_signature, signature):
        return JSONResponse(content={"message": "Invalid signature."}, status_code=401)
    
    # Use request.client.host for rate limiting key
    cache_key = f"github_webhook:{request.client.host}"
    bot = request.app.state.bot
    if await bot.redis.exists(cache_key):
        return JSONResponse({"error": "Rate limited"}, status_code=429)
    await bot.redis.set(cache_key, "1", ex=2)
    
    try:
        if request.headers.get('content-type') == 'application/x-www-form-urlencoded':
            form_data = await request.form()
            payload_str = form_data.get('payload')
            if not payload_str:
                log.error("Webhook payload is missing from form data")
                return JSONResponse({"error": "Missing payload in form data"}, status_code=400)
            data = orjson.loads(payload_str)
        else:
            data = orjson.loads(payload)
    except Exception as e:
        log.error(f"Failed to parse webhook payload: {e}")
        return JSONResponse({"error": "Invalid payload"}, status_code=400)
        
    repo_name = data.get('repository', {}).get('full_name')
    allowed_repos = CONFIG.get('github_allowed_repos', [])
    if repo_name not in allowed_repos:
        log.warning(f"Webhook received for unauthorized repo: {repo_name}")
        return JSONResponse({"error": "Repository not authorized"}, status_code=403)

    try:
        event = GithubPushEvent.parse_obj(data)
        await event.send_message()
    except Exception as e:
        log.error(f"Error processing webhook: {e}", exc_info=True)
        return JSONResponse({"error": "Failed to process webhook"}, status_code=500)
    return JSONResponse({"success": True})

@router.post("/topgg")
async def topgg_webhook(
    request: Request,
    authorization: str = Header(None, alias="Authorization")
):
    if authorization != config.AUTHORIZATION.TOPGG_AUTH:
        raise HTTPException(status_code=401, detail="Invalid authorization")
    
    bot = request.app.state.bot
    
    try:
        data = await request.json()
        if not data or "user" not in data:
            return JSONResponse({"error": "Invalid payload"}, status_code=400)
        
        user_id = data["user"]
        await bot.db.execute(
            """
            INSERT INTO public.user_votes (user_id, last_vote_time)
            VALUES ($1, NOW())
            ON CONFLICT (user_id)
            DO UPDATE SET last_vote_time = NOW();
            """,
            int(user_id)
        )
        
        try:
            user = await bot.fetch_user(int(user_id))
            if user:
                channel = bot.get_channel(1430620347022970890)
                if channel:
                    embed = Embed(
                        title="New Vote Received!",
                        description=(
                            f"🎉 {user.mention} (`{user.id}`) has voted for Warm!\n\n"
                            "Their access to donator-only commands is granted for 6 hours.\n"
                            "Vote again in 12 hours to maintain access."
                        ),
                        color=0x2f3136,
                        timestamp=time.time()
                    )
                    embed.set_footer(text="Tip: Donators get permanent access to these commands!")
                    await channel.send(embed=embed)
        except Exception as e:
            log.error(f"Error sending vote notification: {e}")
            
        return JSONResponse({"success": True})
    
    except Exception as e:
        log.error(f"Error processing Top.gg webhook: {e}", exc_info=True)
        return JSONResponse({"error": "Internal server error"}, status_code=500)


@router.get("/health")
async def health(request: Request):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")
    else:
        return JSONResponse({
            "status": "ok",
            "timestamp": int(time.time()),
            "uptime": int(bot.uptime2)
        })