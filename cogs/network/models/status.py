from pydantic import BaseModel
from typing import List

class ShardStatus(BaseModel):
    id: int
    ping_ms: float
    guilds: int
    users: int

class StatusResponse(BaseModel):
    uptime_seconds: int
    total_guilds: int
    total_users: int
    shards: List[ShardStatus]