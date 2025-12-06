import uvicorn
import asyncio
from .routes import router

from main import Evict

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from discord.ext.commands import Cog



class Network(Cog):
    """Network cog for managing network-related commands."""

    def __init__(self, bot: Evict):
        self.bot = Evict
        self.app = FastAPI(
            title="warm.lat API", 
            version="2.0.1", 
            debug=False
        )
        self.app.state.bot = bot
        
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

        self.app.include_router(router)

        config = uvicorn.Config(
            self.app,
            host="0.0.0.0",
            port=8000,
            log_level="info",
        )
        self.server = uvicorn.Server(config)
        self.task = asyncio.create_task(self.server.serve())

    def cog_unload(self):
        """Handle cleanup when the cog is unloaded."""
        self.server.should_exit = True
        self.task.cancel()