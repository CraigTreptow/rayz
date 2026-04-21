from __future__ import annotations

import math

from rayz.constants import EPSILON


class Tuple:
    """A 4D homogeneous coordinate (x, y, z, w)."""

    def __init__(self, x: float, y: float, z: float, w: float) -> None:
        self.x = float(x)
        self.y = float(y)
        self.z = float(z)
        self.w = float(w)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Tuple):
            return NotImplemented
        return (
            abs(self.x - other.x) < EPSILON
            and abs(self.y - other.y) < EPSILON
            and abs(self.z - other.z) < EPSILON
            and abs(self.w - other.w) < EPSILON
        )

    __hash__ = None  # type: ignore[assignment]

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}({self.x}, {self.y}, {self.z}, {self.w})"

    def __add__(self, other: Tuple) -> Tuple:
        return Tuple(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)

    def __sub__(self, other: Tuple) -> Tuple:
        return Tuple(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w)

    def __mul__(self, scalar: float) -> Tuple:
        return Tuple(self.x * scalar, self.y * scalar, self.z * scalar, self.w * scalar)

    def __truediv__(self, scalar: float) -> Tuple:
        return Tuple(self.x / scalar, self.y / scalar, self.z / scalar, self.w / scalar)

    def __neg__(self) -> Tuple:
        return Tuple(-self.x, -self.y, -self.z, -self.w)

    def magnitude(self) -> float:
        return math.sqrt(self.x**2 + self.y**2 + self.z**2 + self.w**2)

    def normalize(self) -> Tuple:
        mag = self.magnitude()
        return Tuple(self.x / mag, self.y / mag, self.z / mag, self.w / mag)

    def dot(self, other: Tuple) -> float:
        return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w

    def reflect(self, normal: Tuple) -> Tuple:
        return self - normal * 2 * self.dot(normal)

    def is_point(self) -> bool:
        return abs(self.w - 1.0) < EPSILON

    def is_vector(self) -> bool:
        return abs(self.w) < EPSILON


class Point(Tuple):
    """A point in 3D space (w=1.0)."""

    def __init__(self, x: float, y: float, z: float) -> None:
        super().__init__(x, y, z, 1.0)

    def __repr__(self) -> str:
        return f"Point({self.x}, {self.y}, {self.z})"


class Vector(Tuple):
    """A direction/displacement in 3D space (w=0.0)."""

    def __init__(self, x: float, y: float, z: float) -> None:
        super().__init__(x, y, z, 0.0)

    def __repr__(self) -> str:
        return f"Vector({self.x}, {self.y}, {self.z})"

    def normalize(self) -> Vector:
        mag = self.magnitude()
        return Vector(self.x / mag, self.y / mag, self.z / mag)

    def cross(self, other: Vector) -> Vector:
        return Vector(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        )

    def reflect(self, normal: Tuple) -> Tuple:
        return self - normal * 2 * self.dot(normal)
