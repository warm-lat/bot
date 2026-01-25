from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class Shards(BaseModel):
    id: int
    guilds: int
    users: int
    ping: float
    status: str

class Status(BaseModel):
    shards: List[Shards]
    total_guilds: int = Field(..., alias="totalGuilds")
    total_users: int = Field(..., alias="totalUsers")
    total_shards: int = Field(..., alias="totalShards")
    avg_ping: float = Field(..., alias="avgPing")
    uptime: int

class CommandFlag(BaseModel):
    name: str
    description: str

class CommandFlags(BaseModel):
    required: List[CommandFlag]
    optional: List[CommandFlag]

class CommandParameter(BaseModel):
    name: str
    type: str
    default: Optional[str]
    flags: Optional[CommandFlags]
    optional: bool

class Commands(BaseModel):
    name: str
    description: str
    aliases: List[str]
    parameters: List[CommandParameter]
    category: str
    permissions: List[str]
    donator: bool

class CommandsResponse(BaseModel):
    categories: List[str]
    commands: List[Commands]