import aiohttp, logging
from fastapi import APIRouter, Depends, Request, HTTPException
from fastapi.responses import JSONResponse
from ..middleware.auth import verify_auth

router = APIRouter(prefix="/music", tags=["Music"])
log = logging.getLogger(__name__)

@router.get("/playing/{user_id}", dependencies=[Depends(verify_auth)])
async def currently_playing(request: Request, user_id: int):
    """Get currently playing track info for a specific user (FastAPI version)"""
    bot = request.app.state.bot
    audio_cog = bot.get_cog("Audio") if bot else None
    if not audio_cog:
        return JSONResponse({"error": "Audio cog not loaded"}, status_code=503)

    async def get_track_info(track):
        title = track.title
        artist = track.author

        if "feat." in title.lower():
            title = title.split("feat.")[0].strip()

        title = (
            title.replace("(Official Music Video)", "")
            .replace("(Official Video)", "")
            .replace("(Official Audio)", "")
            .replace("(Lyric Video)", "")
            .replace("(Lyrics)", "")
            .replace("[Official Video]", "")
            .strip()
        )

        if " - " in title:
            parts = title.split(" - ", 1)
            if len(parts) == 2:
                artist, title = parts

        artist = artist.strip()

        # Deezer lookup
        try:
            async with aiohttp.ClientSession() as session:
                search_url = "https://api.deezer.com/search"
                params = {"q": f'artist:"{artist}" track:"{title}"'}
                async with session.get(search_url, params=params) as resp:
                    if resp.status == 200:
                        data = await resp.json()
                        if data.get('data'):
                            track_data = data['data'][0]
                            return {
                                "title": track.title,
                                "artist": artist,
                                "album": track_data['album']['title'],
                                "album_art": track_data['album']['cover_xl'],
                                "uri": track.uri,
                                "length": track.length,
                                "is_stream": track.is_stream,
                                "requester_id": str(track.requester.id) if track.requester else None
                            }
        except Exception as e:
            log.error(f"Deezer lookup failed: {e}")

        return {
            "title": track.title,
            "artist": artist,
            "album": None,
            "album_art": None,
            "uri": track.uri,
            "length": track.length,
            "is_stream": track.is_stream,
            "requester_id": str(track.requester.id) if track.requester else None
        }

    playing_data = None
    try:
        for guild in bot.guilds:
            voice_client = getattr(guild, "voice_client", None)
            if not voice_client or not getattr(voice_client, "is_playing", False):
                continue

            voice_members = voice_client.channel.members
            if any(m.id == user_id for m in voice_members):
                track = getattr(voice_client, "current", None)
                if track:
                    current_track_info = await get_track_info(track)
                    queue = [t for t in getattr(voice_client, "queue", [])]
                    queue_data = []
                    for t in queue[:10]:
                        queue_data.append(await get_track_info(t))

                    playing_data = {
                        "current": {
                            **current_track_info,
                            "position": getattr(voice_client, "position", 0)
                        },
                        "queue": queue_data,
                        "queue_length": len(getattr(voice_client, "queue", [])),
                        "guild_id": str(guild.id),
                        "channel_id": str(voice_client.channel.id),
                        "voice_state": {
                            "volume": getattr(voice_client, "volume", 100),
                            "paused": getattr(voice_client, "is_paused", False),
                            "loop_mode": str(getattr(getattr(voice_client, "queue", None), "loop_mode", "NONE")),
                            "auto_play": getattr(voice_client, "auto_play", False)
                        }
                    }
                    break

        if playing_data:
            return JSONResponse(playing_data)
        else:
            return JSONResponse({"error": "User not in any voice channel with active playback"}, status_code=404)
    except ValueError:
        return JSONResponse({"error": "Invalid user ID"}, status_code=400)
    except Exception as e:
        log.error(f"Error getting currently playing info: {e}", exc_info=True)
        return JSONResponse({"error": "Internal server error"}, status_code=500)