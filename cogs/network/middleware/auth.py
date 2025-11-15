import os
from fastapi import Header, HTTPException, Security

async def verify_auth(authorization: str = Security(Header(None, alias='Authorization'))):
    """
    Dependency to verify a static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if not authorization:
        raise HTTPException(
            status_code=401,
            detail=f"'Authorization' header is missing",
        )
    if authorization != os.getenv("INTERNAL_AUTH_KEY"):
        raise HTTPException(
            status_code=401, 
            detail="Invalid Authorization token"
        )

async def verify_special_auth(special_auth: str = Security(Header(None, alias='Authorization'))):
    """
    Dependency to verify a special static API key in the 'Authorization' header.
    
    Raises HTTPException with status 401 if the key is missing or invalid.
    """
    if not special_auth:
        raise HTTPException(
            status_code=401,
            detail=f"'Authorization' header is missing",
        )
    if special_auth != os.getenv("CALLBACK_AUTH_KEY"):
        raise HTTPException(
            status_code=401, 
            detail="Invalid Special Authorization token"
        )