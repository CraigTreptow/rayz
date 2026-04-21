from __future__ import annotations

from rayz.constants import EPSILON


class Color:
    """An RGB color with floating-point components."""

    def __init__(self, red: float, green: float, blue: float) -> None:
        self.red = float(red)
        self.green = float(green)
        self.blue = float(blue)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Color):
            return NotImplemented
        return (
            abs(self.red - other.red) < EPSILON
            and abs(self.green - other.green) < EPSILON
            and abs(self.blue - other.blue) < EPSILON
        )

    __hash__ = None  # type: ignore[assignment]

    def __repr__(self) -> str:
        return f"Color({self.red}, {self.green}, {self.blue})"

    def __add__(self, other: Color) -> Color:
        return Color(self.red + other.red, self.green + other.green, self.blue + other.blue)

    def __sub__(self, other: Color) -> Color:
        return Color(self.red - other.red, self.green - other.green, self.blue - other.blue)

    def __mul__(self, other: float | Color) -> Color:
        if isinstance(other, Color):
            return Color(self.red * other.red, self.green * other.green, self.blue * other.blue)
        return Color(self.red * other, self.green * other, self.blue * other)

    def __rmul__(self, scalar: float) -> Color:
        return self.__mul__(scalar)
