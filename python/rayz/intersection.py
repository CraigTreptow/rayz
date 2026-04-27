from __future__ import annotations

from rayz.constants import EPSILON


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


def prepare_computations(intersection: Intersection, ray, xs=None):
    from rayz.computations import Computations

    t = intersection.t
    obj = intersection.object
    point = ray.position(t)
    eyev = -ray.direction
    normalv = obj.normal_at(point)

    inside = False
    if normalv.dot(eyev) < 0:
        inside = True
        normalv = -normalv

    over_point = point + normalv * EPSILON
    under_point = point - normalv * EPSILON
    reflectv = ray.direction.reflect(normalv)

    n1, n2 = 1.0, 1.0
    if xs is not None:
        containers: list = []
        for i in xs:
            if i == intersection:
                n1 = containers[-1].material.refractive_index if containers else 1.0
            if i.object in containers:
                containers.remove(i.object)
            else:
                containers.append(i.object)
            if i == intersection:
                n2 = containers[-1].material.refractive_index if containers else 1.0
                break

    return Computations(
        t,
        obj,
        point,
        eyev,
        normalv,
        inside,
        over_point,
        reflectv,
        n1=n1,
        n2=n2,
        under_point=under_point,
    )
