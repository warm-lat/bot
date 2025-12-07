from pydantic import BaseModel, Field
from typing import List

class ShardStatus(BaseModel):
    id: int
    guilds: int
    users: int
    ping: float
    status: str

class BotStatus(BaseModel):
    shards: List[ShardStatus]
    total_guilds: int = Field(..., alias="totalGuilds")
    total_users: int = Field(..., alias="totalUsers")
    total_shards: int = Field(..., alias="totalShards")
    avg_ping: float = Field(..., alias="avgPing")
    uptime: int