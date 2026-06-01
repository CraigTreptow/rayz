from __future__ import annotations

from rayz.shape import Shape
from rayz.tuple import Vector


class Group(Shape):
    def __init__(self) -> None:
        super().__init__()
        self.children: list[Shape] = []

    def add_child(self, shape: Shape) -> None:
        self.children.append(shape)
        shape.parent = self

    def local_intersect(self, ray) -> list:
        if self.children and not self.bounds().intersects(ray):
            return []
        xs = []
        for child in self.children:
            xs.extend(child.intersect(ray))
        return sorted(xs, key=lambda i: i.t)

    def local_normal_at(self, point, hit=None) -> Vector:
        raise RuntimeError("Groups have no surface normals")

    def bounds(self):
        from rayz.bounds import Bounds
        from rayz.tuple import Point
        if not self.children:
            return Bounds(Point(0, 0, 0), Point(0, 0, 0))
        b = Bounds(Point(float("inf"), float("inf"), float("inf")), Point(float("-inf"), float("-inf"), float("-inf")))
        for child in self.children:
            child_bounds = child.bounds().transform(child.transform)
            b = b.merge(child_bounds)
        return b
