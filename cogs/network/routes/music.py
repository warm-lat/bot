import aiohttp, logging, config, asyncio
from fastapi import APIRouter, Depends, Request, HTTPException, Query
from fastapi.responses import JSONResponse
from ..middleware.auth import verify_auth
from ..models.music import TrackRecommendation
from typing import List, Optional

router = APIRouter(prefix="/music", include_in_schema=False)

log = logging.getLogger(__name__)

@router.get("/playing/{user_id}", dependencies=[Depends(verify_auth)])
async def currently_playing(request: Request, user_id: int):
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
    

@router.get(
    "/autoplay", 
    dependencies=[Depends(verify_auth)], 
    response_model=List[TrackRecommendation]
)
async def get_autoplay_recommendations(
    title: str = Query(..., description="The title of the track."),
    author: str = Query(..., description="The author of the track."),
    algorithm: str = Query("DYNAMIC", description="The recommendation algorithm to use."),
    limit: int = Query(10, ge=1, le=25, description="Number of recommendations to return."),
):
    """
    Provides a list of track recommendations based on a seed track.
    It fetches similar tracks from Last.fm and enriches them with data from Deezer.
    """
    if not config.AUTHORIZATION.LASTFM.KEY:
        raise HTTPException(status_code=503, detail="Last.fm API key is not configured.")
    
    lastfm_params = {
        "method": "track.getsimilar",
        "artist": author,
        "track": title,
        "api_key": config.AUTHORIZATION.LASTFM.KEY,
        "format": "json",
        "limit": limit,
    }
    
    try:
        async with aiohttp.ClientSession() as session:
            # 1. Get similar tracks from Last.fm
            async with session.get("https://ws.audioscrobbler.com/2.0/", params=lastfm_params) as response:
                if response.status != 200:
                    log.error(f"Last.fm API error: {response.status} - {await response.text()}")
                    raise HTTPException(status_code=502, detail="Error fetching recommendations from Last.fm")

                data = await response.json()
                similar_tracks = data.get("similartracks", {}).get("track", [])

                if not similar_tracks:
                    return []

            # 2. Asynchronously enrich Last.fm results with Deezer data
            tasks = [
                find_best_match(session, track['name'], track['artist']['name'])
                for track in similar_tracks
            ]
            results = await asyncio.gather(*tasks)
            
            # Filter out any None results and return
            return [rec for rec in results if rec]

    except aiohttp.ClientError as e:
        log.error(f"HTTP client error in autoplay: {e}")
        raise HTTPException(status_code=502, detail="Could not connect to external music services.")
    except Exception as e:
        log.error(f"Unexpected error in autoplay endpoint: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="An internal error occurred.")


async def find_best_match(session: aiohttp.ClientSession, title: str, author: str) -> Optional[TrackRecommendation]:
    """
    Find the best matching track on Deezer. If not found, fallback to Last.fm data.
    """
    # First, try searching on Deezer
    search_query = f"{author} {title}"
    params = {'q': search_query, 'limit': 1}
    try:
        async with session.get("https://api.deezer.com/search", params=params) as resp:
            if resp.status == 200:
                data = await resp.json()
                if data.get('data'):
                    track_data = data['data'][0]
                    return TrackRecommendation(
                        title=track_data.get('title_short', title),
                        author=track_data.get('artist', {}).get('name', author),
                        uri=track_data.get('link'),
                        sourceName='deezer',
                        artwork=track_data.get('album', {}).get('cover_xl')
                    )
    except Exception as e:
        log.warning(f"Deezer search failed for '{search_query}': {e}")
    
    # Fallback to Last.fm data if Deezer search fails or returns no results
    return TrackRecommendation(
        title=title,
        author=author,
        sourceName='lastfm' # Indicates this is a fallback
    )