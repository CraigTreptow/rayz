from __future__ import annotations

from rayz.shape import Shape
from rayz.tuple import Vector


class CSG(Shape):
    def __init__(self, operation: str, left: Shape, right: Shape) -> None:
        super().__init__()
        self.operation = operation
        self.left = left
        self.right = right
        left.parent = self
        right.parent = self

    def includes(self, shape) -> bool:
        return _includes(self.left, shape) or _includes(self.right, shape)

    def local_intersect(self, ray) -> list:
        left_xs = self.left.intersect(ray)
        right_xs = self.right.intersect(ray)
        xs = sorted(left_xs + right_xs, key=lambda i: i.t)
        return filter_intersections(self, xs)

    def local_normal_at(self, point, hit=None) -> Vector:
        raise RuntimeError("CSG shapes have no surface normal")


def _includes(shape, target) -> bool:
    if hasattr(shape, "includes"):
        return shape.includes(target)
    if hasattr(shape, "left"):
        return _includes(shape.left, target) or _includes(shape.right, target)
    return shape is target


def intersection_allowed(op: str, lhit: bool, inl: bool, inr: bool) -> bool:
    if op == "union":
        return (lhit and not inr) or (not lhit and not inl)
    if op == "intersection":
        return (lhit and inr) or (not lhit and inl)
    if op == "difference":
        return (lhit and not inr) or (not lhit and inl)
    return False


def filter_intersections(csg: CSG, xs: list) -> list:
    inl, inr = False, False
    result = []
    for i in xs:
        lhit = _includes(csg.left, i.object)
        if intersection_allowed(csg.operation, lhit, inl, inr):
            result.append(i)
        if lhit:
            inl = not inl
        else:
            inr = not inr
    return result
