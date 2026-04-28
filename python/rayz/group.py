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
        xs = []
        for child in self.children:
            xs.extend(child.intersect(ray))
        return sorted(xs, key=lambda i: i.t)

    def local_normal_at(self, point) -> Vector:
        raise RuntimeError("Groups have no surface normals")
