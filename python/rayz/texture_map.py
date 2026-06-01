# python/rayz/texture_map.py
from __future__ import annotations

import math
from typing import Callable

from rayz.color import Color
from rayz.pattern import Pattern
from rayz.tuple import Point, Vector


class PPMImage:
    def __init__(self, width: int, height: int) -> None:
        self.width = width
        self.height = height
        self._pixels: list[list[Color | None]] = [[None] * width for _ in range(height)]

    def pixel_at(self, x: int, y: int) -> Color:
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            return Color(0, 0, 0)
        return self._pixels[y][x] or Color(0, 0, 0)

    def set_pixel(self, x: int, y: int, color: Color) -> None:
        if 0 <= x < self.width and 0 <= y < self.height:
            self._pixels[y][x] = color

    @classmethod
    def load_ppm(cls, filename: str) -> PPMImage:
        with open(filename) as f:
            raw = f.read()
        lines = [ln.strip() for ln in raw.splitlines() if ln.strip() and not ln.strip().startswith("#")]
        assert lines[0] == "P3", f"Unsupported PPM format: {lines[0]}"
        width, height = map(int, lines[1].split())
        max_color = int(lines[2])
        values = list(map(int, " ".join(lines[3:]).split()))
        image = cls(width, height)
        for i, (r, g, b) in enumerate(zip(values[::3], values[1::3], values[2::3])):
            image.set_pixel(i % width, i // width, Color(r / max_color, g / max_color, b / max_color))
        return image

    @classmethod
    def checkerboard(cls, width: int, height: int, checks: int) -> PPMImage:
        """Programmatic checkerboard — useful for demos without an image file."""
        img = cls(width, height)
        cell_w = max(1, width // checks)
        cell_h = max(1, height // checks)
        white = Color(1, 1, 1)
        black = Color(0.1, 0.1, 0.1)
        for y in range(height):
            for x in range(width):
                color = white if ((x // cell_w) + (y // cell_h)) % 2 == 0 else black
                img.set_pixel(x, y, color)
        return img


class TextureMap(Pattern):
    def __init__(self, image: PPMImage, uv_map: Callable) -> None:
        super().__init__()
        self.image = image
        self.uv_map = uv_map

    def pattern_at(self, point) -> Color:
        u, v = self.uv_map(point)
        x = round(u * (self.image.width - 1))
        y = round((1.0 - v) * (self.image.height - 1))
        return self.image.pixel_at(x, y)

    @staticmethod
    def planar_map(point) -> tuple[float, float]:
        return point.x % 1.0, point.z % 1.0

    @staticmethod
    def cylindrical_map(point) -> tuple[float, float]:
        theta = math.atan2(point.x, point.z)
        u = (theta + math.pi) / (2 * math.pi)
        return u, point.y % 1.0

    @staticmethod
    def spherical_map(point) -> tuple[float, float]:
        theta = math.atan2(point.x, point.z)
        radius = math.sqrt(point.x**2 + point.y**2 + point.z**2)
        phi = math.acos(point.y / radius) if radius > 0 else 0.0
        u = 1.0 - (theta + math.pi) / (2 * math.pi)
        v = 1.0 - phi / math.pi
        return u, v
