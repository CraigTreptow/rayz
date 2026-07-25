from __future__ import annotations

import math

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

    def local_normal_at(self, point, hit=None) -> Vector:
        ax, ay, az = abs(point.x), abs(point.y), abs(point.z)
        maxc = max(ax, ay, az)
        if maxc == ax:
            return Vector(point.x, 0, 0)
        elif maxc == ay:
            return Vector(0, point.y, 0)
        return Vector(0, 0, point.z)

    def bounds(self):
        from rayz.bounds import Bounds
        from rayz.tuple import Point

        return Bounds(Point(-1, -1, -1), Point(1, 1, 1))


def _check_axis(origin: float, direction: float) -> tuple[float, float]:
    tmin_num = -1 - origin
    tmax_num = 1 - origin
    if abs(direction) >= EPSILON:
        tmin = tmin_num / direction
        tmax = tmax_num / direction
    else:
        # Ray is parallel to this axis's planes. A numerator of exactly
        # zero means the origin sits exactly on that plane, which imposes
        # no constraint from this axis rather than the NaN that
        # `0 * inf` would otherwise produce.
        tmin = -math.inf if tmin_num == 0 else tmin_num * math.inf
        tmax = math.inf if tmax_num == 0 else tmax_num * math.inf
    if tmin > tmax:
        return tmax, tmin
    return tmin, tmax
