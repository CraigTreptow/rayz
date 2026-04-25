from __future__ import annotations


class Ray:
    def __init__(self, origin, direction) -> None:
        self.origin = origin
        self.direction = direction

    def position(self, t: float):
        return self.origin + self.direction * t

    def transform(self, matrix) -> Ray:
        return Ray(matrix * self.origin, matrix * self.direction)
