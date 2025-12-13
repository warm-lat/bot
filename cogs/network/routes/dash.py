import logging, asyncio, os, hashlib
from datetime import datetime, timezone
from fastapi import APIRouter, Request, Depends, Query, Header, HTTPException, Body
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from ..middleware.auth import verify_auth, verify_dash_auth
from ..models.dash import TicketCreate, LoginPayload, LoginResponse
load_dotenv()

log = logging.getLogger(__name__)

router = APIRouter(prefix="/dash", include_in_schema=False)

@router.get("/beta")
async def beta(request: Request):
    """
    Check whether the bearer token corresponds to a user with beta dashboard access.
    Expects Authorization: Bearer <token>
    """
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing authorization")

    token = auth_header.split(" ", 1)[1]

    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    try:
        user_data = await bot.db.fetchrow(
            """
            SELECT user_id
            FROM public.access_tokens
            WHERE token = $1
            AND expires_at > CURRENT_TIMESTAMP
            """,
            token,
        )

        if not user_data:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        beta_access = await bot.db.fetchrow(
            """
            SELECT user_id
            FROM public.beta_dashboard
            WHERE user_id = $1
            """,
            user_data["user_id"],
        )

        return {"has_access": bool(beta_access)}

    except HTTPException:
        raise
    except Exception as e:
        log.error(f"Error checking beta access: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")

@router.get("/tickets", dependencies=[Depends(verify_auth)])
async def tickets(
    request: Request, 
    ticket_id: str = Query(..., alias="id", description="The ID of the ticket to fetch."), 
    user_id: str = Header(default=..., alias="User-ID", description="The Discord User ID of the requester."),
):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")
    
    log.info(f"Request received for ticket {ticket_id} for User-ID: {user_id}")

    ticket_path = f"tickets/{ticket_id}.json"
    user_ids_path = f"tickets/{ticket_id}_ids.json"
    
    try:
        user_data = await bot.download_from_r2(user_ids_path)
        if user_data is None:
            log.warning(f"Access list for ticket {ticket_id} not found in R2.")
            raise HTTPException(status_code=404, detail="Access list not found.")

        if user_id not in map(str, user_data.get("ids", [])):
            log.warning(f"User-ID {user_id} not authorized to access ticket {ticket_id}.")
            raise HTTPException(status_code=403, detail="You do not have permission to access this ticket.")
        
        ticket_data = await bot.download_from_r2(ticket_path)
        if ticket_data is None:
            log.warning(f"Ticket {ticket_id} not found in R2.")
            raise HTTPException(status_code=404, detail="Ticket not found.")
        
        log.info(f"Ticket {ticket_id} successfully retrieved for User-ID: {user_id}")
        return ticket_data
    
    except Exception as e:
        log.error(f"Error retrieving ticket {ticket_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error.")
    
@router.post("/tickets")
async def create_ticket(request: Request, data: TicketCreate):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")
    
    try:
        ticket_id = data.ticket_id
        ticket_data = data.ticket_data
        user_ids = data.user_ids
        
        ticket_path = f"tickets/{ticket_id}.json"
        user_ids_path = f"tickets/{ticket_id}_ids.json"
        
        if await bot.download_from_r2(ticket_path):
            raise HTTPException(status_code=409, detail="Ticket with this ID already exists.")
        
        await asyncio.gather(
            bot.upload_to_r2(ticket_path, ticket_data),
            bot.upload_to_r2(user_ids_path, {"ids": user_ids}),
        )

        
        log.info(f"Created ticket {ticket_id} for users {user_ids}")
        return JSONResponse(
            content={
                "success": True,
                "message": f"Ticket {ticket_id} created successfully",
                "ticket_id": ticket_id,
            }
        )

    except Exception as e:
        log.error(f"Error creating ticket: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error.")
    
@router.post("/login", dependencies=[Depends(verify_dash_auth)], response_model=LoginResponse)
async def login(request: Request, data: LoginPayload = Body(..., embed=True)):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")
    
    try:
        timestamp = int(datetime.now(timezone.utc).timestamp())
        token_data = f"{data.user_id}-{timestamp}"
        secret = os.getenv('TOKEN_SECRET')
        token = hashlib.sha256(f"{token_data}-{secret}".encode()).hexdigest()
        
        await bot.db.execute(
            """
            INSERT INTO public.access_tokens (user_id, token, discord_token, created_at, expires_at)
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '14 days')
            ON CONFLICT (user_id) 
            DO UPDATE SET 
                token = EXCLUDED.token,
                discord_token = EXCLUDED.discord_token,
                created_at = CURRENT_TIMESTAMP,
                expires_at = CURRENT_TIMESTAMP + INTERVAL '14 days'
            """,
            data.user_id,
            token,
            data.access_token
        )
        log.info(f"Successfully generated new access token for user_id: {data.user_id}")
        return LoginResponse(success=True, token=token)
    
    except Exception as e:
        log.error(f"Error in login endpoint for user_id {data.user_id}: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="An internal error occurred while processing the login."
        )