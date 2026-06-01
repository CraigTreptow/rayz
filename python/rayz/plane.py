from __future__ import annotations

from rayz.constants import EPSILON
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Vector


class Plane(Shape):
    def local_intersect(self, ray) -> list:
        if abs(ray.direction.y) < EPSILON:
            return []
        t = -ray.origin.y / ray.direction.y
        return [Intersection(t, self)]

    def local_normal_at(self, point, hit=None) -> Vector:
        return Vector(0, 1, 0)

    def bounds(self):
        import math

        from rayz.bounds import Bounds
        from rayz.tuple import Point
        return Bounds(Point(-math.inf, 0, -math.inf), Point(math.inf, 0, math.inf))
