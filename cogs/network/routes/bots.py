import logging
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from typing import List, Dict
from discord.ext.commands import FlagConverter, Group
from ..models.bots import BotStatus

log = logging.getLogger(__name__)

router = APIRouter(prefix="/bot")

@router.get("/status", response_model=BotStatus)
async def status(request: Request):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    shard_data = []
    total_guilds = 0
    total_users = 0

    for shard in bot.shards.values():
        guilds_in_shard = [g for g in bot.guilds if g.shard_id == shard.id]
        guild_count = len(guilds_in_shard)
        user_count = sum(g.member_count for g in guilds_in_shard)
        
        total_guilds += guild_count
        total_users += user_count

        shard_data.append({
            "id": shard.id,
            "guilds": guild_count,
            "users": user_count,
            "ping": round(shard.latency * 1000, 2),
            "status": "closed" if shard.is_closed() else "connected",
        })

    avg_ping = sum(s['ping'] for s in shard_data) / len(shard_data) if shard_data else 0

    response_data = {
        "shards": shard_data,
        "total_guilds": total_guilds,
        "total_users": total_users,
        "total_shards": bot.shard_count,
        "avg_ping": round(avg_ping, 2),
        "uptime": int(bot.uptime2) if hasattr(bot, 'uptime2') else 0,
    }

    return JSONResponse(content=response_data)


@router.get("/commands")
async def commands(request: Request):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    def get_flags(param):
        try:
            if isinstance(param.annotation, type) and issubclass(param.annotation, FlagConverter):
                flags = param.annotation.get_flags()
                return {
                    "required": [
                        {"name": name, "description": flag.description}
                        for name, flag in flags.items()
                        if not flag.default
                    ],
                    "optional": [
                        {"name": name, "description": flag.description}
                        for name, flag in flags.items()
                        if flag.default
                    ],
                }
        except Exception:
            pass
        return None

    def get_donator(command):
        if getattr(command, "checks", None):
            for check in command.checks:
                if getattr(check, "__name__", "") == "predicate" and getattr(check, "__qualname__", "").startswith("donator"):
                    return True
        return False

    def get_permissions(command):
        try:
            perms = [perm.lower().replace("n/a", "None").replace("_", " ") for perm in command.permissions]
            if "antinuke" in command.qualified_name.lower():
                perms.extend(["antinuke admin", "guild owner"])
            if len(perms) > 1:
                perms = [p for p in perms if p.lower() not in ("none", "n/a")]
            return perms
        except Exception:
            perms = []
            for check in getattr(command, "checks", []) or []:
                # try to extract permissions from closure cells (best-effort)
                closure = getattr(check, "__closure__", None)
                if closure:
                    for cell in closure:
                        try:
                            contents = getattr(cell, "cell_contents", None)
                            if isinstance(contents, dict):
                                perms.extend(contents.keys())
                        except Exception:
                            continue
            if "antinuke" in getattr(command, "qualified_name", "").lower():
                perms.extend(["antinuke admin", "guild owner"])
            if perms:
                perms = [perm.replace("_", " ").title() for perm in perms]
            return perms or ["N/A"]

    def clean_type(annotation):
        try:
            if hasattr(annotation, "__name__"):
                return annotation.__name__
            s = str(annotation)
            if s.startswith("typing.Optional"):
                return "Optional[" + clean_type(annotation.__args__[0]) + "]"
            if s.startswith("<"):
                return annotation.__class__.__name__
            return s
        except Exception:
            return str(annotation)

    def format_parameters(command):
        params = []
        for name, param in getattr(command, "clean_params", {}).items():
            default = None if param.default == param.empty else str(param.default)
            params.append({
                "name": name,
                "type": clean_type(param.annotation),
                "default": default,
                "flags": get_flags(param),
                "optional": param.default != param.empty
            })
        return params

    IGNORED_CATEGORIES = {
        "Jishaku", "Network", "API", "Owner", "Status", "Listeners", "Hog"
    }

    commands_info: List[Dict] = []
    categories = sorted(list({cog.qualified_name for cog in bot.cogs.values() if cog.qualified_name not in IGNORED_CATEGORIES and "cogs" in getattr(cog, "__module__", "")}))

    for cog in bot.cogs.values():
        if cog.qualified_name in IGNORED_CATEGORIES:
            continue

        for command in cog.get_commands():
            if isinstance(command, Group):
                commands_info.append({
                    "name": command.qualified_name,
                    "description": command.description or getattr(command, "help", None) or "No description",
                    "aliases": getattr(command, "aliases", []),
                    "parameters": format_parameters(command),
                    "category": command.cog.qualified_name if command.cog else "No Category",
                    "permissions": get_permissions(command),
                    "donator": get_donator(command),
                })

                seen = {command.qualified_name}
                for sub in command.walk_commands():
                    if sub.qualified_name in seen:
                        continue
                    seen.add(sub.qualified_name)
                    commands_info.append({
                        "name": sub.qualified_name,
                        "description": sub.description or getattr(sub, "help", None) or "No description",
                        "aliases": getattr(sub, "aliases", []),
                        "parameters": format_parameters(sub),
                        "category": sub.cog.qualified_name if sub.cog else "No Category",
                        "permissions": get_permissions(sub),
                        "donator": get_donator(sub),
                    })
            else:
                commands_info.append({
                    "name": command.qualified_name,
                    "description": command.description or getattr(command, "help", None) or "No description",
                    "aliases": getattr(command, "aliases", []),
                    "parameters": format_parameters(command),
                    "category": command.cog.qualified_name if command.cog else "No Category",
                    "permissions": get_permissions(command),
                    "donator": get_donator(command),
                })

    return JSONResponse(content={"categories": categories, "commands": commands_info})

@router.get("/avatar")
async def avatar(request: Request):
    bot = request.app.state.bot
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    avatar_url = bot.user.avatar if bot.user.avatar else None
    return StreamingResponse(content=avatar_url.read(), media_type="image/png", status_code=200)