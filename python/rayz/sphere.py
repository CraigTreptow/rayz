from __future__ import annotations

import math

from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Point, Vector


class Sphere(Shape):
    def local_intersect(self, ray) -> list:
        sphere_to_ray = ray.origin - Point(0, 0, 0)
        a = ray.direction.dot(ray.direction)
        b = 2 * ray.direction.dot(sphere_to_ray)
        c = sphere_to_ray.dot(sphere_to_ray) - 1.0
        disc = b * b - 4 * a * c
        if disc < 0:
            return []
        t1 = (-b - math.sqrt(disc)) / (2 * a)
        t2 = (-b + math.sqrt(disc)) / (2 * a)
        return [Intersection(t1, self), Intersection(t2, self)]

    def local_normal_at(self, point, hit=None) -> Vector:
        return point - Point(0, 0, 0)

    def bounds(self):
        from rayz.bounds import Bounds
        return Bounds(Point(-1, -1, -1), Point(1, 1, 1))


def glass_sphere() -> Sphere:
    s = Sphere()
    s.material.transparency = 1.0
    s.material.refractive_index = 1.5
    return s
