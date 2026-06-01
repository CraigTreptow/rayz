from __future__ import annotations

import math

from rayz.color import Color
from rayz.tuple import Point, Vector


class Spotlight:
    def __init__(
        self,
        position: Point,
        intensity: Color,
        direction: Vector,
        cone_angle: float,
        fade_angle: float | None = None,
    ) -> None:
        self.position = position
        self.intensity = intensity
        self.direction = direction.normalize()
        self.cone_angle = cone_angle
        self.fade_angle = fade_angle if fade_angle is not None else cone_angle

    def intensity_at(self, point, world) -> float:
        light_to_point = (point - self.position).normalize()
        cos_angle = self.direction.dot(light_to_point)
        cos_outer = math.cos(self.cone_angle)
        cos_inner = math.cos(self.fade_angle)

        if cos_angle < cos_outer:
            return 0.0

        if cos_angle >= cos_inner:
            return 0.0 if world.is_shadowed_from(point, self.position) else 1.0

        fade_factor = (cos_angle - cos_outer) / (cos_inner - cos_outer)
        return 0.0 if world.is_shadowed_from(point, self.position) else fade_factor

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Spotlight):
            return NotImplemented
        return (
            self.position == other.position
            and self.intensity == other.intensity
            and self.direction == other.direction
            and self.cone_angle == other.cone_angle
            and self.fade_angle == other.fade_angle
        )
