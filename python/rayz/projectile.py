from __future__ import annotations

from rayz.tuple import Point, Vector


class Projectile:
    """A projectile with a position and velocity."""

    def __init__(self, position: Point, velocity: Vector) -> None:
        self.position = position
        self.velocity = velocity
