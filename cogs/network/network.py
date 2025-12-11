import uvicorn
import asyncio

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from discord.ext.commands import Cog

from main import Evict
from .routes import bots, dash, misc, music
from core.client import logging


log = logging.getLogger(__name__)

class Network(Cog):
    """Network cog for managing network-related commands."""

    def __init__(self, bot: Evict):
        self.bot: Evict = bot
        self.app = FastAPI(
            title="warm.lat API", 
            version="2.0.2",
            docs_url="/",
            redoc_url=None,
            openapi_url="/openapi.json"
        )
        self.app.state.bot = bot
        
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

        self.app.include_router(bots.router)
        self.app.include_router(dash.router)
        self.app.include_router(misc.router)
        self.app.include_router(music.router)

        config = uvicorn.Config(
            self.app,
            host="0.0.0.0",
            port=8000,
            log_level="info",
            proxy_headers=True,
            server_header=False
        )
        self.server = uvicorn.Server(config)
        self.task = None

    async def cog_load(self):
        """Start the API server when the cog is loaded."""
        self.task = asyncio.create_task(self.server.serve())

    async def cog_unload(self):
        """Handle cleanup when the cog is unloaded."""
        self.server.should_exit = True
        if self.task:
            self.task.cancel()
        log.info("FastAPI server stopped")