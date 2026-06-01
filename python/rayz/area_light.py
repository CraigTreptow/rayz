from __future__ import annotations

from typing import Callable

from rayz.color import Color
from rayz.tuple import Point


class AreaLight:
    def __init__(
        self,
        corner: Point,
        full_uvec,
        full_vvec,
        usteps: int,
        vsteps: int,
        intensity: Color,
        jitter_by: Callable[[], float] | None = None,
    ) -> None:
        self.corner = corner
        self.usteps = usteps
        self.vsteps = vsteps
        self.samples = usteps * vsteps
        self.intensity = intensity
        self.jitter_by = jitter_by
        self.uvec = full_uvec / usteps
        self.vvec = full_vvec / vsteps

    def point_on_light(self, u: float, v: float) -> Point:
        return self.corner + self.uvec * (u + 0.5) + self.vvec * (v + 0.5)

    def _jitter(self) -> float:
        return self.jitter_by() if self.jitter_by is not None else 0.0

    def intensity_at(self, point, world) -> float:
        total = 0.0
        for v in range(self.vsteps):
            for u in range(self.usteps):
                light_pos = self.point_on_light(u + self._jitter(), v + self._jitter())
                if not world.is_shadowed_from(point, light_pos):
                    total += 1.0
        return total / self.samples

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, AreaLight):
            return NotImplemented
        return (
            self.corner == other.corner
            and self.uvec == other.uvec
            and self.vvec == other.vvec
            and self.usteps == other.usteps
            and self.vsteps == other.vsteps
            and self.intensity == other.intensity
        )
