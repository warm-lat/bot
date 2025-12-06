from fastapi import APIRouter
from . import bot, dash, misc

router = APIRouter()
for route in (bot, dash, misc):
    router.include_router(route.router)
