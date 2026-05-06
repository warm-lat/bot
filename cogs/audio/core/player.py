from __future__ import annotations

import asyncio
from contextlib import suppress
from logging import getLogger
from typing import TYPE_CHECKING, Optional
from colorama import Fore

from discord import Color, Embed, HTTPException, Message
from lava_lyra import LoopMode, Player, QueueEmpty, Track, Equalizer, Timescale
from .queue import Queue
from tools.formatter import shorten

from .panel import Panel

if TYPE_CHECKING:
    from ..audio import Context

log = getLogger("warm/audio")


class Client(Player):
    queue: Queue
    auto_queue: Queue
    timeout_task: Optional[asyncio.Task]
    controller: Optional[Message]
    context: Optional[Context]

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.queue = Queue()
        self.auto_queue = Queue()
        self.timeout_task = None
        self.message = None
        self.context = None
        self.controller = None

    async def set_context(self, ctx: Context):
        self.context = ctx

    def insert(self, track: Track, bump=False) -> Queue:
        if bump:
            self.queue.put_at_front(track)
        else:
            self.queue.put(track)

        return self.queue

    async def player_timeout(self):
        await asyncio.sleep(180)
        if self.is_connected and not self.is_playing:
            await self.destroy()
            if self.context:
                await self.context.send(
                    "I've left the voice channel due to inactivity."
                )

    async def do_next(self) -> Optional[Track]:
        if not self.channel:
            return

        if self.is_paused:
            await self.set_pause(False)

        if self.controller and self.queue.loop_mode != LoopMode.TRACK:
            with suppress(HTTPException):
                await self.controller.delete()

        try:
            track = self.queue.get()
        except QueueEmpty:
            if self.timeout_task:
                self.timeout_task.cancel()

            self.timeout_task = asyncio.create_task(self.player_timeout())
            return None

        await self.play(track)
        if self.context and self.queue.loop_mode != LoopMode.TRACK:
            embed = Embed(
                description=f"Now playing [**{shorten(track.title)}**]({track.uri}) via {track.requester.mention if track.requester else self.channel.mention}",
                color=Color.dark_embed(),
            )
            kwargs = {"embed": embed, "view": None}
            if self.context.settings.play_panel:
                kwargs["view"] = Panel(self.context)
            self.controller = await self.context.channel.send(**kwargs)

    async def set_pause(self, pause: bool) -> bool:
        status = await super().set_pause(pause)
        await self.refresh_panel()
        return status

    async def refresh_panel(self):
        if self.controller and self.context and self.context.settings.play_panel:
            with suppress(HTTPException):
                await self.controller.edit(view=Panel(self.context))

    async def destroy(self) -> None:
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

        if self.controller:
            with suppress(HTTPException):
                await self.controller.delete()

        if self.timeout_task:
            self.timeout_task.cancel()

        return await super().destroy()

    async def set_filter(self, filter_obj=None):
        if filter_obj is None:
            await self.reset_filters()
        else:
            await self.add_filter(filter_obj, fast_apply=True)
        return self

    async def set_equalizer(self, bands=None):
        if not bands:
            await self.reset_filters()
            return self

        eq = Equalizer(tag="equalizer", levels=bands)
        await self.add_filter(eq, fast_apply=True)
        return self

    async def set_timescale(self, *, speed=1.0, pitch=1.0, rate=1.0):
        ts = Timescale(tag="timescale", speed=speed, pitch=pitch, rate=rate)
        await self.add_filter(ts, fast_apply=True)
        return self
