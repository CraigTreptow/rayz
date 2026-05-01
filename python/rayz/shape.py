from __future__ import annotations

from abc import ABC, abstractmethod

from rayz.material import Material
from rayz.matrix import Matrix
from rayz.tuple import Vector


class Shape(ABC):
    def __init__(self) -> None:
        self.transform = Matrix.identity(4)
        self.material = Material()
        self.parent = None

    def set_transform(self, m: Matrix) -> None:
        self.transform = m

    def intersect(self, ray) -> list:
        local_ray = ray.transform(self.transform.inverse())
        return self.local_intersect(local_ray)

    def world_to_object(self, point):
        p = point
        if self.parent is not None:
            p = self.parent.world_to_object(p)
        return self.transform.inverse() * p

    def normal_to_world(self, normal) -> Vector:
        inv = self.transform.inverse()
        n = inv.transpose() * normal
        n = Vector(n.x, n.y, n.z).normalize()
        if self.parent is not None:
            n = self.parent.normal_to_world(n)
        return n

    def normal_at(self, world_point, hit=None) -> Vector:
        local_point = self.world_to_object(world_point)
        local_normal = self.local_normal_at(local_point, hit)
        return self.normal_to_world(local_normal)

    @abstractmethod
    def local_intersect(self, ray) -> list: ...

    @abstractmethod
    def local_normal_at(self, point, hit=None) -> Vector: ...


class TestShape(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.saved_ray = None

    def local_intersect(self, ray) -> list:
        self.saved_ray = ray
        return []

    def local_normal_at(self, point, hit=None) -> Vector:
        return Vector(point.x, point.y, point.z)
