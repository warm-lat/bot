from fastapi import APIRouter
from . import bot, dash, misc, verify

router = APIRouter()
for route in (bot, dash, misc, verify):
    router.include_router(route.router)
