from __future__ import annotations

from rayz.intersection import Intersection
from rayz.triangle import Triangle
from rayz.tuple import Vector


class SmoothTriangle(Triangle):
    def __init__(self, p1, p2, p3, n1, n2, n3) -> None:
        super().__init__(p1, p2, p3)
        self.n1 = n1
        self.n2 = n2
        self.n3 = n3

    def _make_intersections(self, t, u, v) -> list:
        return [Intersection(t, self, u, v)]

    def local_normal_at(self, point, hit=None) -> Vector:
        if hit is not None and hit.u is not None and hit.v is not None:
            return self.n2 * hit.u + self.n3 * hit.v + self.n1 * (1 - hit.u - hit.v)
        return self.normal
