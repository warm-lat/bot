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
            detail="Invalid Internal-API Key"
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