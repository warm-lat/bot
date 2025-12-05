from typing import Any, Dict, List
from pydantic import BaseModel


class TicketCreate(BaseModel):
    ticket_id: str
    ticket_data: Dict[str, Any]
    user_ids: List[int]