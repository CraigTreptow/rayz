from __future__ import annotations

import math
from abc import ABC, abstractmethod

from rayz.color import Color
from rayz.matrix import Matrix


class Pattern(ABC):
    def __init__(self) -> None:
        self.transform = Matrix.identity(4)

    def set_transform(self, m: Matrix) -> None:
        self.transform = m

    @abstractmethod
    def pattern_at(self, point) -> Color: ...

    def pattern_at_shape(self, shape, world_point) -> Color:
        inv_shape = shape.transform.inverse()
        object_point = inv_shape * world_point
        inv_pattern = self.transform.inverse()
        pattern_point = inv_pattern * object_point
        return self.pattern_at(pattern_point)


class StripePattern(Pattern):
    def __init__(self, a: Color, b: Color) -> None:
        super().__init__()
        self.a = a
        self.b = b

    def pattern_at(self, point) -> Color:
        return self.a if int(math.floor(point.x)) % 2 == 0 else self.b


class GradientPattern(Pattern):
    def __init__(self, a: Color, b: Color) -> None:
        super().__init__()
        self.a = a
        self.b = b

    def pattern_at(self, point) -> Color:
        distance = self.b - self.a
        fraction = point.x - math.floor(point.x)
        return self.a + distance * fraction


class RingPattern(Pattern):
    def __init__(self, a: Color, b: Color) -> None:
        super().__init__()
        self.a = a
        self.b = b

    def pattern_at(self, point) -> Color:
        distance = math.sqrt(point.x**2 + point.z**2)
        return self.a if int(math.floor(distance)) % 2 == 0 else self.b


class CheckersPattern(Pattern):
    def __init__(self, a: Color, b: Color) -> None:
        super().__init__()
        self.a = a
        self.b = b

    def pattern_at(self, point) -> Color:
        total = int(math.floor(point.x)) + int(math.floor(point.y)) + int(math.floor(point.z))
        return self.a if total % 2 == 0 else self.b


class TestPattern(Pattern):
    def pattern_at(self, point) -> Color:
        return Color(point.x, point.y, point.z)


def stripe_pattern(a: Color, b: Color) -> StripePattern:
    return StripePattern(a, b)


def gradient_pattern(a: Color, b: Color) -> GradientPattern:
    return GradientPattern(a, b)


def ring_pattern(a: Color, b: Color) -> RingPattern:
    return RingPattern(a, b)


def checkers_pattern(a: Color, b: Color) -> CheckersPattern:
    return CheckersPattern(a, b)


def test_pattern() -> TestPattern:
    return TestPattern()
