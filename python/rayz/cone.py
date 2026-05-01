from __future__ import annotations

import math

from rayz.constants import EPSILON
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Vector


class Cone(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.minimum = -math.inf
        self.maximum = math.inf
        self.closed = False

    def local_intersect(self, ray) -> list:
        dx, dy, dz = ray.direction.x, ray.direction.y, ray.direction.z
        ox, oy, oz = ray.origin.x, ray.origin.y, ray.origin.z

        a = dx * dx - dy * dy + dz * dz
        b = 2 * ox * dx - 2 * oy * dy + 2 * oz * dz
        c = ox * ox - oy * oy + oz * oz

        xs = []

        if abs(a) < EPSILON:
            if abs(b) >= EPSILON:
                t = -c / (2 * b)
                xs.append(Intersection(t, self))
        else:
            disc = b * b - 4 * a * c
            if disc >= 0:
                t0 = (-b - math.sqrt(disc)) / (2 * a)
                t1 = (-b + math.sqrt(disc)) / (2 * a)
                if t0 > t1:
                    t0, t1 = t1, t0
                y0 = oy + t0 * dy
                if self.minimum < y0 < self.maximum:
                    xs.append(Intersection(t0, self))
                y1 = oy + t1 * dy
                if self.minimum < y1 < self.maximum:
                    xs.append(Intersection(t1, self))

        self._intersect_caps(ray, xs)
        return xs

    def local_normal_at(self, point, hit=None) -> Vector:
        dist = point.x * point.x + point.z * point.z
        if dist < point.y * point.y and point.y >= self.maximum - EPSILON:
            return Vector(0, 1, 0)
        if dist < point.y * point.y and point.y <= self.minimum + EPSILON:
            return Vector(0, -1, 0)
        y = math.sqrt(dist)
        if point.y > 0:
            y = -y
        return Vector(point.x, y, point.z)

    def _check_cap(self, ray, t: float, y: float) -> bool:
        x = ray.origin.x + t * ray.direction.x
        z = ray.origin.z + t * ray.direction.z
        return x * x + z * z <= y * y

    def _intersect_caps(self, ray, xs: list) -> None:
        if not self.closed or abs(ray.direction.y) < EPSILON:
            return
        t = (self.minimum - ray.origin.y) / ray.direction.y
        if self._check_cap(ray, t, self.minimum):
            xs.append(Intersection(t, self))
        t = (self.maximum - ray.origin.y) / ray.direction.y
        if self._check_cap(ray, t, self.maximum):
            xs.append(Intersection(t, self))
