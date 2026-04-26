from __future__ import annotations

import math

from rayz.canvas import Canvas
from rayz.matrix import Matrix
from rayz.tuple import Point


class Camera:
    def __init__(self, hsize: int, vsize: int, field_of_view: float) -> None:
        self.hsize = hsize
        self.vsize = vsize
        self.field_of_view = field_of_view
        self.transform = Matrix.identity(4)
        self._calc_pixel_size()

    def _calc_pixel_size(self) -> None:
        half_view = math.tan(self.field_of_view / 2.0)
        aspect = self.hsize / self.vsize
        if aspect >= 1:
            self._half_width = half_view
            self._half_height = half_view / aspect
        else:
            self._half_width = half_view * aspect
            self._half_height = half_view
        self.pixel_size = (self._half_width * 2) / self.hsize

    def ray_for_pixel(self, px: int, py: int):
        from rayz.ray import Ray

        xoffset = (px + 0.5) * self.pixel_size
        yoffset = (py + 0.5) * self.pixel_size
        world_x = self._half_width - xoffset
        world_y = self._half_height - yoffset

        inv = self.transform.inverse()
        pixel_m = inv * Point(world_x, world_y, -1)
        origin_m = inv * Point(0, 0, 0)
        direction = (pixel_m - origin_m).normalize()
        return Ray(origin_m, direction)

    def render(self, world) -> Canvas:
        image = Canvas(self.hsize, self.vsize)
        for y in range(self.vsize):
            for x in range(self.hsize):
                ray = self.ray_for_pixel(x, y)
                color = world.color_at(ray)
                image.write_pixel(col=x, row=y, color=color)
        return image
