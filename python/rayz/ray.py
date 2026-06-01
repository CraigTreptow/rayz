from __future__ import annotations


class Ray:
    def __init__(self, origin, direction, time: float = 0.0) -> None:
        self.origin = origin
        self.direction = direction
        self.time = time

    def position(self, t: float):
        return self.origin + self.direction * t

    def transform(self, matrix) -> Ray:
        return Ray(matrix * self.origin, matrix * self.direction, time=self.time)
