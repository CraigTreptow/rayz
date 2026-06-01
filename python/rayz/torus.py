# python/rayz/torus.py
from __future__ import annotations

import math

from rayz.bounds import Bounds
from rayz.intersection import Intersection
from rayz.shape import Shape
from rayz.tuple import Point, Vector


class Torus(Shape):
    def __init__(self, major_radius: float = 1.0, minor_radius: float = 0.25) -> None:
        super().__init__()
        self.major_radius = major_radius
        self.minor_radius = minor_radius

    def local_intersect(self, ray) -> list:
        ox, oy, oz = ray.origin.x, ray.origin.y, ray.origin.z
        dx, dy, dz = ray.direction.x, ray.direction.y, ray.direction.z

        R, r = self.major_radius, self.minor_radius
        sum_d_sq = dx * dx + dy * dy + dz * dz
        e = ox * ox + oy * oy + oz * oz - R * R - r * r
        f = ox * dx + oy * dy + oz * dz
        four_R_sq = 4.0 * R * R

        a = sum_d_sq * sum_d_sq
        b = 4.0 * sum_d_sq * f
        c = 2.0 * sum_d_sq * e + 4.0 * f * f + four_R_sq * (dz * dz)
        d = 4.0 * f * e + 2.0 * four_R_sq * oz * dz
        e_coef = e * e - four_R_sq * (r * r - oz * oz)

        roots = self._solve_quartic(a, b, c, d, e_coef)
        return [Intersection(t, self) for t in roots if t > 0]

    def local_normal_at(self, local_point, hit=None) -> Vector:
        x, y, z = local_point.x, local_point.y, local_point.z
        dist = math.sqrt(x * x + z * z)
        if dist > 0:
            mx = x * self.major_radius / dist
            mz = z * self.major_radius / dist
        else:
            mx, mz = self.major_radius, 0.0
        return Vector(x - mx, y, z - mz).normalize()

    def bounds(self) -> Bounds:
        extent = self.major_radius + self.minor_radius
        return Bounds(
            Point(-extent, -self.minor_radius, -extent),
            Point(extent, self.minor_radius, extent),
        )

    def _solve_quartic(self, a: float, b: float, c: float, d: float, e: float) -> list[float]:
        if a == 0:
            return []
        b /= a; c /= a; d /= a; e /= a

        z1 = complex(1, 1)
        z2 = complex(-1, 1)
        z3 = complex(-1, -1)
        z4 = complex(1, -1)

        tolerance = 1e-10
        for _ in range(100):
            p1 = z1**4 + b*z1**3 + c*z1**2 + d*z1 + e
            p2 = z2**4 + b*z2**3 + c*z2**2 + d*z2 + e
            p3 = z3**4 + b*z3**3 + c*z3**2 + d*z3 + e
            p4 = z4**4 + b*z4**3 + c*z4**2 + d*z4 + e
            nz1 = z1 - p1 / ((z1-z2) * (z1-z3) * (z1-z4))
            nz2 = z2 - p2 / ((z2-z1) * (z2-z3) * (z2-z4))
            nz3 = z3 - p3 / ((z3-z1) * (z3-z2) * (z3-z4))
            nz4 = z4 - p4 / ((z4-z1) * (z4-z2) * (z4-z3))
            if (abs(nz1-z1) < tolerance and abs(nz2-z2) < tolerance
                    and abs(nz3-z3) < tolerance and abs(nz4-z4) < tolerance):
                break
            z1, z2, z3, z4 = nz1, nz2, nz3, nz4

        return [z.real for z in (z1, z2, z3, z4) if abs(z.imag) < tolerance]
