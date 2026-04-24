from __future__ import annotations

from rayz.tuple import Vector


class Environment:
    """Physics environment with gravity and wind forces."""

    def __init__(self, gravity: Vector, wind: Vector) -> None:
        self.gravity = gravity
        self.wind = wind
