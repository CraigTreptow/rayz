from __future__ import annotations

from rayz.color import Color
from rayz.constants import EPSILON


class Material:
    def __init__(
        self,
        color: Color | None = None,
        ambient: float = 0.1,
        diffuse: float = 0.9,
        specular: float = 0.9,
        shininess: float = 200.0,
        reflective: float = 0.0,
        transparency: float = 0.0,
        refractive_index: float = 1.0,
    ) -> None:
        self.color = color if color is not None else Color(1, 1, 1)
        self.ambient = ambient
        self.diffuse = diffuse
        self.specular = specular
        self.shininess = shininess
        self.reflective = reflective
        self.transparency = transparency
        self.refractive_index = refractive_index

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Material):
            return NotImplemented
        return (
            self.color == other.color
            and abs(self.ambient - other.ambient) < EPSILON
            and abs(self.diffuse - other.diffuse) < EPSILON
            and abs(self.specular - other.specular) < EPSILON
            and abs(self.shininess - other.shininess) < EPSILON
            and abs(self.reflective - other.reflective) < EPSILON
            and abs(self.transparency - other.transparency) < EPSILON
            and abs(self.refractive_index - other.refractive_index) < EPSILON
        )

    __hash__ = None  # type: ignore[assignment]

    def __repr__(self) -> str:
        return (
            f"Material(color={self.color!r}, ambient={self.ambient}, diffuse={self.diffuse}, "
            f"specular={self.specular}, shininess={self.shininess})"
        )
