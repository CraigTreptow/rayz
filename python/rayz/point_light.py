from __future__ import annotations

from rayz.color import Color
from rayz.tuple import Point


class PointLight:
    def __init__(self, position: Point, intensity: Color) -> None:
        self.position = position
        self.intensity = intensity

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, PointLight):
            return NotImplemented
        return self.position == other.position and self.intensity == other.intensity

    def __repr__(self) -> str:
        return f"PointLight(position={self.position!r}, intensity={self.intensity!r})"
