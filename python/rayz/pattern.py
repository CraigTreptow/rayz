from __future__ import annotations

import math

from rayz.color import Color


class StripePattern:
    def __init__(self, a: Color, b: Color) -> None:
        self.a = a
        self.b = b

    def pattern_at(self, point) -> Color:
        return self.a if int(math.floor(point.x)) % 2 == 0 else self.b

    def pattern_at_shape(self, shape, world_point) -> Color:
        return self.pattern_at(world_point)


def stripe_pattern(a: Color, b: Color) -> StripePattern:
    return StripePattern(a, b)
