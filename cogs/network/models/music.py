from typing import Optional
from pydantic import BaseModel

class TrackRecommendation(BaseModel):
    title: str
    author: str
    uri: Optional[str] = None
    sourceName: str
    artwork: Optional[str] = None