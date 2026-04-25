from __future__ import annotations


class Intersection:
    def __init__(self, t: float, obj) -> None:
        self.t = t
        self.object = obj

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Intersection):
            return NotImplemented
        return self.t == other.t and self.object is other.object

    def __repr__(self) -> str:
        return f"Intersection(t={self.t}, object={self.object!r})"


def intersections(*args: Intersection) -> list[Intersection]:
    return list(args)


def hit(xs: list[Intersection]) -> Intersection | None:
    valid = [i for i in xs if i.t >= 0]
    if not valid:
        return None
    return min(valid, key=lambda i: i.t)


def intersect(shape, ray) -> list[Intersection]:
    return shape.intersect(ray)
