from __future__ import annotations

import asyncio
from contextlib import suppress
from logging import getLogger
from typing import TYPE_CHECKING, Optional, Union, Dict, Any
from colorama import Fore

from discord import Color, Embed, HTTPException, Message
from lava_lyra import LoopMode, Player, QueueEmpty, Track
from .queue import Queue
from tools.formatter import shorten

from .panel import Panel

if TYPE_CHECKING:
    from ..audio import Context

log = getLogger("warm/audio")


class Client(Player):
    """Enhanced music player with NodeLink.js support and advanced features."""
    
    queue: Queue
    auto_queue: Queue
    timeout_task: Optional[asyncio.Task]
    controller: Optional[Message]
    context: Optional[Context]
    
    # NodeLink.js specific features
    _lyrics_cache: Dict[str, str]
    _track_info_cache: Dict[str, Dict[str, Any]]
    _session_stats: Dict[str, Any]

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.queue = Queue()
        self.auto_queue = Queue()
        self.timeout_task = None
        self.message = None
        self.context = None
        self.controller = None
        
        # NodeLink.js enhanced features
        self._lyrics_cache = {}
        self._track_info_cache = {}
        self._session_stats = {
            'tracks_played': 0,
            'total_playtime': 0,
            'commands_used': 0,
            'filters_applied': 0
        }

    async def set_context(self, ctx: Context) -> None:
        """Set the command context for this player."""
        self.context = ctx
        self._session_stats['commands_used'] += 1

    def insert(self, track: Track, bump: bool = False) -> Queue:
        """Insert a track into the queue with optional bump to front."""
        if bump:
            self.queue.put_at_front(track)
        else:
            self.queue.put(track)

        log.info(f"Track added to queue: {track.title} (bump={bump})")
        return self.queue

    async def player_timeout(self) -> None:
        """Handle player inactivity timeout with NodeLink.js optimization."""
        await asyncio.sleep(180)  # 3 minutes
        
        if self.is_connected and not self.is_playing:
            log.info(f"Player timeout for guild {self.guild_id}, destroying connection")
            await self.destroy()
            
            if self.context:
                await self.context.send(
                    "🎵 I've left the voice channel due to inactivity. "
                    "Type `/play` to start music again!"
                )

    async def do_next(self) -> Optional[Track]:
        """Play the next track with enhanced NodeLink.js features."""
        if not self.channel:
            return None

        if self.is_paused:
            await self.set_pause(False)

        # Clean up controller message if not looping track
        if self.controller and self.queue.loop_mode != LoopMode.TRACK:
            with suppress(HTTPException):
                await self.controller.delete()

        try:
            track = self.queue.get()
            self._session_stats['tracks_played'] += 1
            
            # Cache track info for NodeLink.js features
            await self._cache_track_info(track)
            
        except QueueEmpty:
            if self.timeout_task:
                self.timeout_task.cancel()

            self.timeout_task = asyncio.create_task(self.player_timeout())
            return None

        await self.play(track)
        
        # Enhanced now playing message with NodeLink.js features
        if self.context and self.queue.loop_mode != LoopMode.TRACK:
            embed = await self._create_now_playing_embed(track)
            self.controller = await self.context.channel.send(
                embed=embed,
                view=Panel(self.context) if self.context.settings.play_panel else None,
            )
            
        return track

    async def _create_now_playing_embed(self, track: Track) -> Embed:
        """Create an enhanced now playing embed with NodeLink.js features."""
        requester = track.requester.mention if track.requester else self.channel.mention
        
        embed = Embed(
            description=f"🎵 Now playing [**{shorten(track.title)}**]({track.uri}) via {requester}",
            color=Color.dark_embed(),
        )
        
        # Add NodeLink.js specific information if available
        if hasattr(track, 'source') and track.source:
            embed.add_field(name="Source", value=track.source.capitalize(), inline=True)
            
        if hasattr(track, 'duration') and track.duration:
            duration_str = self._format_duration(track.duration)
            embed.add_field(name="Duration", value=duration_str, inline=True)
            
        # Add lyrics preview if available (NodeLink.js feature)
        lyrics = await self.get_lyrics(track.title)
        if lyrics:
            preview = lyrics[:100] + "..." if len(lyrics) > 100 else lyrics
            embed.add_field(name="Lyrics Preview", value=f"*{preview}*", inline=False)
            
        return embed

    async def _cache_track_info(self, track: Track) -> None:
        """Cache track information for enhanced features."""
        track_id = getattr(track, 'identifier', track.title)
        self._track_info_cache[track_id] = {
            'title': track.title,
            'uri': track.uri,
            'source': getattr(track, 'source', 'unknown'),
            'duration': getattr(track, 'duration', 0),
            'requester': track.requester.id if track.requester else None,
            'timestamp': asyncio.get_event_loop().time()
        }

    def _format_duration(self, duration_ms: int) -> str:
        """Format duration in milliseconds to human readable string."""
        seconds = duration_ms // 1000
        minutes, seconds = divmod(seconds, 60)
        hours, minutes = divmod(minutes, 60)
        
        if hours > 0:
            return f"{hours}:{minutes:02d}:{seconds:02d}"
        else:
            return f"{minutes}:{seconds:02d}"

    async def set_pause(self, pause: bool) -> bool:
        """Set pause state and update panel."""
        status = await super().set_pause(pause)
        await self.refresh_panel()
        
        log.info(f"Player {'paused' if pause else 'resumed'} for guild {self.guild_id}")
        return status

    async def refresh_panel(self) -> None:
        """Refresh the control panel with current state."""
        if self.controller and self.context and self.context.settings.play_panel:
            with suppress(HTTPException):
                await self.controller.edit(view=Panel(self.context))

    async def destroy(self) -> None:
        """Destroy the player with cleanup and logging."""
        assert self.guild

        log.info(
            f" {Fore.RESET}".join(
                [
                    f"Destroying {Fore.LIGHTCYAN_EX}session",
                    f"for {Fore.LIGHTMAGENTA_EX}{self.channel}",
                    f"@ {Fore.LIGHTYELLOW_EX}{self.guild}{Fore.RESET}.",
                ]
            )
        )

        # Log session statistics
        log.info(f"Session stats: {self._session_stats}")

        # Clean up UI elements
        if self.controller:
            with suppress(HTTPException):
                await self.controller.delete()

        # Cancel timeout task
        if self.timeout_task:
            self.timeout_task.cancel()

        return await super().destroy()

    async def set_filter(self, filter_type: Optional[Dict[str, Any]] = None) -> 'Client':
        """Apply audio filters with NodeLink.js enhanced support."""
        if filter_type is None:
            filter_type = {}

        await self.node._send(op="filters", **filter_type, guildId=str(self.guild_id))
        self._session_stats['filters_applied'] += 1
        
        log.info(f"Applied filter: {filter_type}")
        return self

    async def set_equalizer(self, bands: Optional[list] = None) -> 'Client':
        """Set equalizer bands with enhanced validation."""
        if not bands:
            return await self.set_filter()

        # Validate bands (NodeLink.js supports 0-15 bands)
        valid_bands = []
        for band in bands:
            if isinstance(band, (list, tuple)) and len(band) == 2:
                band_id, gain = band
                if 0 <= band_id <= 15 and -0.25 <= gain <= 1.0:
                    valid_bands.append((band_id, gain))
                else:
                    log.warning(f"Invalid band settings: {band}")

        payload = [(i, gain) for i, gain in valid_bands]
        return await self.set_filter({"equalizer": {"bands": payload}})

    async def set_timescale(self, *, speed: float = 1.0, pitch: float = 1.0, rate: float = 1.0) -> 'Client':
        """Set timescale with NodeLink.js optimized ranges."""
        # NodeLink.js performs best with these ranges
        speed = max(0.1, min(speed, 3.0))
        pitch = max(0.1, min(pitch, 3.0))
        rate = max(0.1, min(rate, 3.0))
        
        return await self.set_filter({"timescale": {
            "speed": speed,
            "pitch": pitch,
            "rate": rate
        }})

    async def get_lyrics(self, track_title: str) -> Optional[str]:
        """Get lyrics using NodeLink.js built-in lyrics support."""
        # Check cache first
        if track_title in self._lyrics_cache:
            return self._lyrics_cache[track_title]
            
        try:
            # NodeLink.js provides lyrics endpoint
            if hasattr(self.node, 'session') and self.node.session:
                url = f"http://{self.node.host}:{self.node.port}/v4/lyrics"
                params = {'query': track_title}
                
                async with self.node.session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        lyrics = data.get('lyrics')
                        if lyrics:
                            self._lyrics_cache[track_title] = lyrics
                            return lyrics
        except Exception as e:
            log.warning(f"Failed to fetch lyrics: {e}")
            
        return None

    async def get_track_info(self, track_identifier: str) -> Optional[Dict[str, Any]]:
        """Get detailed track information from NodeLink.js."""
        if track_identifier in self._track_info_cache:
            return self._track_info_cache[track_identifier]
            
        try:
            if hasattr(self.node, 'session') and self.node.session:
                url = f"http://{self.node.host}:{self.node.port}/v4/decodetrack"
                params = {'encodedTrack': track_identifier}
                
                async with self.node.session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        self._track_info_cache[track_identifier] = data
                        return data
        except Exception as e:
            log.warning(f"Failed to fetch track info: {e}")
            
        return None

    async def get_server_stats(self) -> Optional[Dict[str, Any]]:
        """Get NodeLink.js server statistics."""
        try:
            if hasattr(self.node, 'session') and self.node.session:
                url = f"http://{self.node.host}:{self.node.port}/v4/stats"
                
                async with self.node.session.get(url) as response:
                    if response.status == 200:
                        return await response.json()
        except Exception as e:
            log.warning(f"Failed to fetch server stats: {e}")
            
        return None

    def get_session_stats(self) -> Dict[str, Any]:
        """Get current session statistics."""
        return self._session_stats.copy()

    async def apply_preset_filter(self, preset_name: str) -> 'Client':
        """Apply predefined filter presets optimized for NodeLink.js."""
        presets = {
            'bass_boost': {"equalizer": {"bands": [(0, 0.6), (1, 0.4), (2, 0.2)]}},
            'treble_boost': {"equalizer": {"bands": [(10, 0.4), (11, 0.5), (12, 0.6)]}},
            'vocal': {"equalizer": {"bands": [(0, -0.2), (1, 0.2), (2, 0.4), (3, 0.4)]}},
            'nightcore': {"timescale": {"speed": 1.2, "pitch": 1.2}},
            'vaporwave': {"timescale": {"speed": 0.8, "pitch": 0.9}},
        }
        
        if preset_name in presets:
            return await self.set_filter(presets[preset_name])
        else:
            raise ValueError(f"Unknown preset: {preset_name}")

    async def set_crossfade(self, duration_ms: int = 5000) -> 'Client':
        """Set crossfade between tracks (NodeLink.js feature)."""
        return await self.set_filter({"crossfade": {"duration": duration_ms}})

    async def set_reverb(self, room_size: float = 0.5, damping: float = 0.5) -> 'Client':
        """Set reverb effect (NodeLink.js enhanced filter)."""
        return await self.set_filter({"reverb": {
            "roomSize": max(0.0, min(room_size, 1.0)),
            "damping": max(0.0, min(damping, 1.0))
        }})