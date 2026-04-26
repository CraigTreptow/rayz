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

    def normal_at(self, world_point) -> Vector:
        inv = self.transform.inverse()
        local_point = inv * world_point
        local_normal = self.local_normal_at(local_point)
        world_normal = inv.transpose() * local_normal
        return Vector(world_normal.x, world_normal.y, world_normal.z).normalize()

    @abstractmethod
    def local_intersect(self, ray) -> list:
        ...

    @abstractmethod
    def local_normal_at(self, point) -> Vector:
        ...


class TestShape(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.saved_ray = None

    def local_intersect(self, ray) -> list:
        self.saved_ray = ray
        return []

    def local_normal_at(self, point) -> Vector:
        return Vector(point.x, point.y, point.z)
