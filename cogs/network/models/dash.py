from typing import Any, Dict, List
from pydantic import BaseModel, Field

class TicketCreate(BaseModel):
    ticket_id: str
    ticket_data: Dict[str, Any]
    user_ids: List[int]
    
class LoginResponse(BaseModel):
    success: bool
    token: str
    expires_in: int = Field(1209600, alias="expiresIn")
    
class LoginPayload(BaseModel):
    user_id: str 
    access_token: str