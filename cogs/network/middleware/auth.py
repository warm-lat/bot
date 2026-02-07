import config, logging
from fastapi import Header, HTTPException

log = logging.getLogger(__name__)

async def verify_auth(authorization: str = Header(..., alias='Authorization')):
    """
    Dependency to verify a static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if authorization != config.AUTHORIZATION.INTERNAL.API_KEY:
        raise HTTPException(
            status_code=401, 
            detail="Invalid Internal API Key"
        )

async def verify_special_auth(special_auth: str = Header(..., alias='Authorization')):
    """
    Dependency to verify a special static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if special_auth != config.AUTHORIZATION.INTERNAL.CALLBACK:
        raise HTTPException(
            status_code=401, 
            detail="Invalid Callback API Key"
        )
        
async def verify_dash_auth(dash_auth: str = Header(..., alias='X-Special-Auth')):
    """
    Dependency to verify a dashboard static API key in the 'X-Special-Auth' header.

    Raises HTTPException with status 401 if the key is missing or invalid.
    Also logs the received and expected key for debugging (do not use in production for real secrets).
    """

    if dash_auth != config.AUTHORIZATION.INTERNAL.SPECIAL:
        raise HTTPException(
            status_code=401, 
            detail="Invalid Dashboard API Key"
        )