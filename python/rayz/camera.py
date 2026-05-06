from __future__ import annotations

import math
import os
from concurrent.futures import ProcessPoolExecutor

from rayz.canvas import Canvas
from rayz.matrix import Matrix
from rayz.tuple import Point


def _render_chunk(args: tuple) -> list[tuple[int, int, object]]:
    """Worker: render a slice of rows and return (y, x, color) triples."""
    camera, world, rows = args
    from rayz.ray import Ray

    results = []
    inv = camera._transform_inverse
    for y in rows:
        for x in range(camera.hsize):
            xoffset = (x + 0.5) * camera.pixel_size
            yoffset = (y + 0.5) * camera.pixel_size
            world_x = camera._half_width - xoffset
            world_y = camera._half_height - yoffset
            pixel_m = inv * Point(world_x, world_y, -1)
            origin_m = inv * Point(0, 0, 0)
            direction = (pixel_m - origin_m).normalize()
            ray = Ray(origin_m, direction)
            color = world.color_at(ray)
            results.append((y, x, color))
    return results


class Camera:
    def __init__(self, hsize: int, vsize: int, field_of_view: float) -> None:
        self.hsize = hsize
        self.vsize = vsize
        self.field_of_view = field_of_view
        self._transform = Matrix.identity(4)
        self._transform_inverse = Matrix.identity(4)
        self._calc_pixel_size()

    @property
    def transform(self) -> Matrix:
        return self._transform

    @transform.setter
    def transform(self, m: Matrix) -> None:
        self._transform = m
        self._transform_inverse = m.inverse()

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

        inv = self._transform_inverse
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
                image.write_pixel(col=x, row=self.vsize - 1 - y, color=color)
        return image

    def render_parallel(self, world, workers: int | None = None) -> Canvas:
        if workers is None:
            workers = os.cpu_count() or 1
        all_rows = list(range(self.vsize))
        chunk_size = max(1, math.ceil(self.vsize / workers))
        chunks = [all_rows[i : i + chunk_size] for i in range(0, self.vsize, chunk_size)]

        image = Canvas(self.hsize, self.vsize)
        with ProcessPoolExecutor(max_workers=workers) as executor:
            for results in executor.map(_render_chunk, [(self, world, chunk) for chunk in chunks]):
                for y, x, color in results:
                    image.write_pixel(col=x, row=self.vsize - 1 - y, color=color)
        return image
