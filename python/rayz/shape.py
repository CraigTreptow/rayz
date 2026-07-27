# python/rayz/shape.py
from __future__ import annotations

from abc import ABC, abstractmethod

from rayz.material import Material
from rayz.matrix import Matrix
from rayz.tuple import Vector


class Shape(ABC):
    def __init__(self) -> None:
        self._transform = Matrix.identity(4)
        self._transform_inverse = Matrix.identity(4)
        self._transform_inverse_transpose = Matrix.identity(4)
        self.material = Material()
        self.parent = None
        # Callable[[float], Matrix] | None. If ever set to a lambda/closure,
        # it won't survive ProcessPoolExecutor pickling in render_parallel —
        # use a module-level function (see normal_perturbations.py's pattern)
        # if motion blur needs to work with the parallel renderer.
        self.motion_transform = None

    @property
    def transform(self) -> Matrix:
        return self._transform

    def set_transform(self, m: Matrix) -> None:
        self._transform = m
        self._transform_inverse = m.inverse()
        self._transform_inverse_transpose = m.inverse().transpose()
        self.invalidate_bounds_cache()

    def invalidate_bounds_cache(self) -> None:
        # No-op for shapes that don't cache their own bounds (only Group/CSG
        # do), but keeps propagating up so an ancestor Group/CSG's cache is
        # cleared whenever any descendant's transform changes.
        if self.parent is not None:
            self.parent.invalidate_bounds_cache()

    def intersect(self, ray) -> list:
        if self.motion_transform is not None:
            effective_inverse = (self.motion_transform(ray.time) * self._transform).inverse()
        else:
            effective_inverse = self._transform_inverse
        local_ray = ray.transform(effective_inverse)
        return self.local_intersect(local_ray)

    def world_to_object(self, point):
        p = point
        if self.parent is not None:
            p = self.parent.world_to_object(p)
        return self._transform_inverse * p

    def normal_to_world(self, normal) -> Vector:
        n = self._transform_inverse_transpose * normal
        n = Vector(n.x, n.y, n.z).normalize()
        if self.parent is not None:
            n = self.parent.normal_to_world(n)
        return n

    def normal_at(self, world_point, hit=None) -> Vector:
        local_point = self.world_to_object(world_point)
        local_normal = self.local_normal_at(local_point, hit)
        if self.material.normal_perturbation is not None:
            perturbation = self.material.normal_perturbation(local_point)
            local_normal = Vector(
                local_normal.x + perturbation.x,
                local_normal.y + perturbation.y,
                local_normal.z + perturbation.z,
            ).normalize()
        return self.normal_to_world(local_normal)

    def includes(self, shape) -> bool:
        return self is shape

    @abstractmethod
    def local_intersect(self, ray) -> list: ...

    @abstractmethod
    def local_normal_at(self, point, hit=None) -> Vector: ...

    @abstractmethod
    def bounds(self): ...


class TestShape(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.saved_ray = None

    def local_intersect(self, ray) -> list:
        self.saved_ray = ray
        return []

    def local_normal_at(self, point, hit=None) -> Vector:
        return Vector(point.x, point.y, point.z)

    def bounds(self):
        from rayz.bounds import Bounds
        from rayz.tuple import Point

        return Bounds(Point(-1, -1, -1), Point(1, 1, 1))
