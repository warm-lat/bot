from routes import router


from main import Evict


from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from discord.ext.commands import Cog



class Network(Cog):
    """Network cog for managing network-related commands."""

    def __init__(self, bot: Evict):
        self.bot: Evict = bot
        self.app = FastAPI(
            title="warm.lat API", 
            version="2.0.1", 
            debug=True
        )
        
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

        self.app.include_router(router)