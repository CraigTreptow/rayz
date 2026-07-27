from __future__ import annotations

from rayz.shape import Shape
from rayz.tuple import Vector


class CSG(Shape):
    def __init__(self, operation: str, left: Shape, right: Shape) -> None:
        super().__init__()
        self.operation = operation
        self.left = left
        self.right = right
        self._bounds_cache = None
        left.parent = self
        right.parent = self

    def invalidate_bounds_cache(self) -> None:
        self._bounds_cache = None
        super().invalidate_bounds_cache()

    def includes(self, shape) -> bool:
        return self.left.includes(shape) or self.right.includes(shape)

    def local_intersect(self, ray) -> list:
        if not self.bounds().intersects(ray):
            return []
        left_xs = self.left.intersect(ray)
        right_xs = self.right.intersect(ray)
        xs = sorted(left_xs + right_xs, key=lambda i: i.t)
        return filter_intersections(self, xs)

    def local_normal_at(self, point, hit=None) -> Vector:
        raise RuntimeError("CSG shapes have no surface normal")

    def bounds(self):
        if self._bounds_cache is None:
            l_bounds = self.left.bounds().transform(self.left.transform)
            r_bounds = self.right.bounds().transform(self.right.transform)
            self._bounds_cache = l_bounds.merge(r_bounds)
        return self._bounds_cache


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
        lhit = csg.left.includes(i.object)
        if intersection_allowed(csg.operation, lhit, inl, inr):
            result.append(i)
        if lhit:
            inl = not inl
        else:
            inr = not inr
    return result
