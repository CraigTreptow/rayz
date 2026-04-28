from __future__ import annotations

from rayz.constants import EPSILON
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Vector


class Cube(Shape):
    def local_intersect(self, ray) -> list:
        xtmin, xtmax = _check_axis(ray.origin.x, ray.direction.x)
        ytmin, ytmax = _check_axis(ray.origin.y, ray.direction.y)
        ztmin, ztmax = _check_axis(ray.origin.z, ray.direction.z)

        tmin = max(xtmin, ytmin, ztmin)
        tmax = min(xtmax, ytmax, ztmax)

        if tmin > tmax:
            return []
        return [Intersection(tmin, self), Intersection(tmax, self)]

    def local_normal_at(self, point) -> Vector:
        ax, ay, az = abs(point.x), abs(point.y), abs(point.z)
        maxc = max(ax, ay, az)
        if maxc == ax:
            return Vector(point.x, 0, 0)
        elif maxc == ay:
            return Vector(0, point.y, 0)
        return Vector(0, 0, point.z)


def _check_axis(origin: float, direction: float) -> tuple[float, float]:
    tmin_num = -1 - origin
    tmax_num = 1 - origin
    if abs(direction) >= EPSILON:
        tmin = tmin_num / direction
        tmax = tmax_num / direction
    else:
        tmin = tmin_num * float("inf")
        tmax = tmax_num * float("inf")
    if tmin > tmax:
        return tmax, tmin
    return tmin, tmax
