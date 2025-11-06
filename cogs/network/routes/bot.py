from fastapi import APIRouter, Request, HTTPException

router = APIRouter(prefix="/bot", tags=["bot"])

@router.get("/status")
async def status(request: Request):
    bot = getattr(request.app.state, "bot", None)
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    total_guilds = len(bot.guilds)
    total_users = sum((g.member_count or 0) for g in bot.guilds)
    uptime_seconds = int(getattr(bot, "uptime2", 0))

    shards_data = []
    shards_mapping = getattr(bot, "shards", None)

    if shards_mapping and len(shards_mapping) > 0:
        for shard in shards_mapping.values():
            sid = int(getattr(shard, "id", 0))
            guilds_in_shard = [g for g in bot.guilds if g.shard_id == sid]
            users_in_shard = sum((g.member_count or 0) for g in guilds_in_shard)
            latency = getattr(shard, "latency", None)
            ping_ms = round((latency if latency is not None else bot.latency) * 1000, 2)
            shards_data.append({
                "id": sid,
                "ping_ms": ping_ms,
                "guilds": len(guilds_in_shard),
                "users": users_in_shard,
            })
    else:
        # Unsharded fallback
        shards_data.append({
            "id": 0,
            "ping_ms": round(bot.latency * 1000, 2),
            "guilds": total_guilds,
            "users": total_users,
        })

    return {
        "uptime_seconds": uptime_seconds,
        "total_guilds": total_guilds,
        "total_users": total_users,
        "shards": shards_data,
    }

@router.get("/commands")
async def commands(request: Request):
    bot = getattr(request.app.state, "bot", None)
    if bot is None:
        raise HTTPException(status_code=503, detail="Bot is not ready")

    items = []
    for command in bot.tree.walk_commands():
        type_name = getattr(getattr(command, "type", None), "name", str(getattr(command, "type", "unknown")))
        items.append({
            "name": command.name,
            "description": command.description or "",
            "type": str(type_name).lower(),
        })
    
    return {"commands": items}