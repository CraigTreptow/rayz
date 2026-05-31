# python/rayz/bounds.py
from __future__ import annotations

import math

from rayz.tuple import Point


class Bounds:
    def __init__(
        self,
        min: Point | None = None,
        max: Point | None = None,
    ) -> None:
        self.min = min if min is not None else Point(math.inf, math.inf, math.inf)
        self.max = max if max is not None else Point(-math.inf, -math.inf, -math.inf)

    def merge(self, other: Bounds) -> Bounds:
        return Bounds(
            Point(
                builtins_min(self.min.x, other.min.x),
                builtins_min(self.min.y, other.min.y),
                builtins_min(self.min.z, other.min.z),
            ),
            Point(
                builtins_max(self.max.x, other.max.x),
                builtins_max(self.max.y, other.max.y),
                builtins_max(self.max.z, other.max.z),
            ),
        )

    def transform(self, matrix) -> Bounds:
        corners = [
            Point(self.min.x, self.min.y, self.min.z),
            Point(self.min.x, self.min.y, self.max.z),
            Point(self.min.x, self.max.y, self.min.z),
            Point(self.min.x, self.max.y, self.max.z),
            Point(self.max.x, self.min.y, self.min.z),
            Point(self.max.x, self.min.y, self.max.z),
            Point(self.max.x, self.max.y, self.min.z),
            Point(self.max.x, self.max.y, self.max.z),
        ]
        transformed = [matrix * c for c in corners]
        return Bounds(
            Point(
                min(p.x for p in transformed),
                min(p.y for p in transformed),
                min(p.z for p in transformed),
            ),
            Point(
                max(p.x for p in transformed),
                max(p.y for p in transformed),
                max(p.z for p in transformed),
            ),
        )

    def intersects(self, ray) -> bool:
        xtmin, xtmax = self._check_axis(ray.origin.x, ray.direction.x, self.min.x, self.max.x)
        ytmin, ytmax = self._check_axis(ray.origin.y, ray.direction.y, self.min.y, self.max.y)
        ztmin, ztmax = self._check_axis(ray.origin.z, ray.direction.z, self.min.z, self.max.z)
        tmin = max(xtmin, ytmin, ztmin)
        tmax = min(xtmax, ytmax, ztmax)
        return tmin <= tmax

    def contains_point(self, point: Point) -> bool:
        return (
            self.min.x <= point.x <= self.max.x
            and self.min.y <= point.y <= self.max.y
            and self.min.z <= point.z <= self.max.z
        )

    def contains_bounds(self, other: Bounds) -> bool:
        return self.contains_point(other.min) and self.contains_point(other.max)

    def _check_axis(self, origin: float, direction: float, min_val: float, max_val: float):
        from rayz.constants import EPSILON
        if abs(direction) >= EPSILON:
            tmin = (min_val - origin) / direction
            tmax = (max_val - origin) / direction
        else:
            tmin = (min_val - origin) * math.inf
            tmax = (max_val - origin) * math.inf
        if tmin > tmax:
            tmin, tmax = tmax, tmin
        return tmin, tmax


# Avoid shadowing builtins inside the class methods
builtins_min = min
builtins_max = max
