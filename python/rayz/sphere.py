from __future__ import annotations

import math

from rayz.intersection import Intersection
from rayz.material import Material
from rayz.matrix import Matrix
from rayz.tuple import Point, Vector


class Sphere:
    def __init__(self) -> None:
        self.transform = Matrix.identity(4)
        self.material = Material()

    def set_transform(self, m: Matrix) -> None:
        self.transform = m

    def intersect(self, ray) -> list[Intersection]:
        ray2 = ray.transform(self.transform.inverse())
        sphere_to_ray = ray2.origin - Point(0, 0, 0)
        a = ray2.direction.dot(ray2.direction)
        b = 2 * ray2.direction.dot(sphere_to_ray)
        c = sphere_to_ray.dot(sphere_to_ray) - 1.0
        disc = b * b - 4 * a * c
        if disc < 0:
            return []
        t1 = (-b - math.sqrt(disc)) / (2 * a)
        t2 = (-b + math.sqrt(disc)) / (2 * a)
        return [Intersection(t1, self), Intersection(t2, self)]

    def normal_at(self, world_point) -> Vector:
        inv = self.transform.inverse()
        obj_point = inv * world_point
        obj_normal = obj_point - Point(0, 0, 0)
        raw = inv.transpose() * obj_normal
        return Vector(raw.x, raw.y, raw.z).normalize()

    def __repr__(self) -> str:
        return f"Sphere(transform={self.transform!r})"


def glass_sphere() -> Sphere:
    s = Sphere()
    s.material.transparency = 1.0
    s.material.refractive_index = 1.5
    return s
