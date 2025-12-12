import os
from fastapi import Header, HTTPException

async def verify_auth(authorization: str = Header(..., alias='Authorization')):
    """
    Dependency to verify a static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if authorization != os.getenv("INTERNAL_AUTH_KEY"):
        raise HTTPException(
            status_code=401, 
            detail="Invalid Internal API Key"
        )

async def verify_special_auth(special_auth: str = Header(..., alias='Authorization')):
    """
    Dependency to verify a special static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if special_auth != os.getenv("CALLBACK_AUTH_KEY"):
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
    import logging
    log = logging.getLogger(__name__)
    expected = os.getenv("SPECIAL_AUTH_SECRET")
    # Defensive: handle None, whitespace, and type
    received = str(dash_auth).strip() if dash_auth is not None else None
    expected = str(expected).strip() if expected is not None else None
    if not expected:
        log.error("SPECIAL_AUTH_SECRET environment variable is not set!")
        raise HTTPException(
            status_code=500,
            detail="Server misconfiguration: SPECIAL_AUTH_SECRET not set"
        )
    if received != expected:
        log.warning(f"Dashboard auth failed: received='{received}', expected='{expected}'")
        raise HTTPException(
            status_code=401,
            detail="Invalid Dashboard API Key"
        )