from __future__ import annotations

from typing import Optional
from lava_lyra import Queue as DefaultQueue
from lava_lyra.objects import Track


class Queue(DefaultQueue):
    history: Optional[Queue]

    def __init__(
        self,
        max_size: Optional[int] = None,
        *,
        overflow: bool = True,
        history: bool = True,
    ):
        super().__init__(max_size, overflow=overflow)
        self.history = None
        if history:
            self.history = Queue(history=False)

    def get(self) -> Track:
        track = super().get()
        if self.history:
            self.history.put(track)

        return track
