from __future__ import annotations

import math

from rayz.constants import EPSILON
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Vector


class Cylinder(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.minimum = -math.inf
        self.maximum = math.inf
        self.closed = False

    def local_intersect(self, ray) -> list:
        dx, dz = ray.direction.x, ray.direction.z
        a = dx * dx + dz * dz
        xs = []

        if abs(a) >= EPSILON:
            b = 2 * ray.origin.x * dx + 2 * ray.origin.z * dz
            c = ray.origin.x**2 + ray.origin.z**2 - 1
            disc = b * b - 4 * a * c
            if disc >= 0:
                t0 = (-b - math.sqrt(disc)) / (2 * a)
                t1 = (-b + math.sqrt(disc)) / (2 * a)
                if t0 > t1:
                    t0, t1 = t1, t0
                y0 = ray.origin.y + t0 * ray.direction.y
                if self.minimum < y0 < self.maximum:
                    xs.append(Intersection(t0, self))
                y1 = ray.origin.y + t1 * ray.direction.y
                if self.minimum < y1 < self.maximum:
                    xs.append(Intersection(t1, self))

        self._intersect_caps(ray, xs)
        return xs

    def local_normal_at(self, point) -> Vector:
        dist = point.x**2 + point.z**2
        if dist < 1 and point.y >= self.maximum - EPSILON:
            return Vector(0, 1, 0)
        if dist < 1 and point.y <= self.minimum + EPSILON:
            return Vector(0, -1, 0)
        return Vector(point.x, 0, point.z)

    def _check_cap(self, ray, t: float) -> bool:
        x = ray.origin.x + t * ray.direction.x
        z = ray.origin.z + t * ray.direction.z
        return x * x + z * z <= 1

    def _intersect_caps(self, ray, xs: list) -> None:
        if not self.closed or abs(ray.direction.y) < EPSILON:
            return
        t = (self.minimum - ray.origin.y) / ray.direction.y
        if self._check_cap(ray, t):
            xs.append(Intersection(t, self))
        t = (self.maximum - ray.origin.y) / ray.direction.y
        if self._check_cap(ray, t):
            xs.append(Intersection(t, self))
