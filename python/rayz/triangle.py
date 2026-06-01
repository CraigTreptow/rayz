from __future__ import annotations

from rayz.constants import EPSILON
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Vector


class Triangle(Shape):
    def __init__(self, p1, p2, p3) -> None:
        super().__init__()
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        d1 = p2 - p1
        d2 = p3 - p1
        self.e1 = Vector(d1.x, d1.y, d1.z)
        self.e2 = Vector(d2.x, d2.y, d2.z)
        self.normal = self.e2.cross(self.e1).normalize()

    def local_intersect(self, ray) -> list:
        dir = Vector(ray.direction.x, ray.direction.y, ray.direction.z)
        dir_cross_e2 = dir.cross(self.e2)
        det = self.e1.dot(dir_cross_e2)
        if abs(det) < EPSILON:
            return []
        f = 1.0 / det
        p1_to_origin = ray.origin - self.p1
        p1o = Vector(p1_to_origin.x, p1_to_origin.y, p1_to_origin.z)
        u = f * p1o.dot(dir_cross_e2)
        if u < 0 or u > 1:
            return []
        origin_cross_e1 = p1o.cross(self.e1)
        v = f * dir.dot(origin_cross_e1)
        if v < 0 or (u + v) > 1:
            return []
        t = f * self.e2.dot(origin_cross_e1)
        return self._make_intersections(t, u, v)

    def _make_intersections(self, t, u, v) -> list:
        return [Intersection(t, self)]

    def local_normal_at(self, point, hit=None) -> Vector:
        return self.normal

    def bounds(self):
        from rayz.bounds import Bounds
        from rayz.tuple import Point
        min_x = min(self.p1.x, self.p2.x, self.p3.x)
        min_y = min(self.p1.y, self.p2.y, self.p3.y)
        min_z = min(self.p1.z, self.p2.z, self.p3.z)
        max_x = max(self.p1.x, self.p2.x, self.p3.x)
        max_y = max(self.p1.y, self.p2.y, self.p3.y)
        max_z = max(self.p1.z, self.p2.z, self.p3.z)
        return Bounds(Point(min_x, min_y, min_z), Point(max_x, max_y, max_z))

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Triangle):
            return NotImplemented
        return self.p1 == other.p1 and self.p2 == other.p2 and self.p3 == other.p3
