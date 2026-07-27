from __future__ import annotations

from rayz.shape import Shape
from rayz.tuple import Vector


class Group(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.children: list[Shape] = []
        self._bounds_cache = None

    def add_child(self, shape: Shape) -> None:
        self.children.append(shape)
        shape.parent = self
        self.invalidate_bounds_cache()

    def invalidate_bounds_cache(self) -> None:
        self._bounds_cache = None
        super().invalidate_bounds_cache()

    def local_intersect(self, ray) -> list:
        if self.children and not self.bounds().intersects(ray):
            return []
        xs = []
        for child in self.children:
            xs.extend(child.intersect(ray))
        return sorted(xs, key=lambda i: i.t)

    def local_normal_at(self, point, hit=None) -> Vector:
        raise RuntimeError("Groups have no surface normals")

    def includes(self, shape) -> bool:
        return any(child.includes(shape) for child in self.children)

    def bounds(self):
        if self._bounds_cache is None:
            from rayz.bounds import Bounds

            b = Bounds()
            for child in self.children:
                child_bounds = child.bounds().transform(child.transform)
                b = b.merge(child_bounds)
            self._bounds_cache = b
        return self._bounds_cache
