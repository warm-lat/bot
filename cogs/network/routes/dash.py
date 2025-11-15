import logging
from fastapi import APIRouter, Request, Depends, Query, Header, HTTPException
from ..middleware.auth import verify_auth
log = logging.getLogger(__name__)
router = APIRouter(prefix="/dash")

@router.get("/tickets", include_in_schema=False, dependencies=[Depends(verify_auth)])
async def tickets(
    request: Request, 
    ticket_id: str = Query(..., alias="id", description="The ID of the ticket to fetch."), 
    user_id: str = Header(..., alias="User-ID", description="The Discord User ID of the requester."),
):
    bot = getattr(request.app.state, "bot", None)
    if not bot or not hasattr(bot, "download_from_r2"):
        log.error("Bot instance or download_from_r2 method not available on app state.")
        raise HTTPException(status_code=503, detail="Service is not ready.")
    
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
    
    except HTTPException:
        raise
    except Exception as e:
        log.error(f"Error retrieving ticket {ticket_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error.")