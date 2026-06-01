# python/rayz/camera.py
from __future__ import annotations

import math
import os
import random
from concurrent.futures import ProcessPoolExecutor

from rayz.canvas import Canvas
from rayz.matrix import Matrix
from rayz.tuple import Point


def _render_chunk(args: tuple) -> list[tuple[int, int, object]]:
    camera, world, rows = args
    from rayz.color import Color
    from rayz.ray import Ray

    inv = camera._transform_inverse
    hw = camera._half_width
    hh = camera._half_height
    ps = camera.pixel_size
    fd = camera.focal_distance
    spp = camera.samples_per_pixel
    ap = camera.aperture_size
    mb = camera.motion_blur

    results = []
    for y in rows:
        for x in range(camera.hsize):
            if spp == 1 and ap == 0.0 and not mb:
                xoffset = (x + 0.5) * ps
                yoffset = (y + 0.5) * ps
                pixel = inv * Point(hw - xoffset, hh - yoffset, -fd)
                origin = inv * Point(0, 0, 0)
                direction = (pixel - origin).normalize()
                color = world.color_at(Ray(origin, direction, time=0.0))
            else:
                total_r = total_g = total_b = 0.0
                for _ in range(spp):
                    px_off = random.random()
                    py_off = random.random()
                    ax = (random.random() * 2 - 1) * ap if ap > 0 else 0.0
                    ay = (random.random() * 2 - 1) * ap if ap > 0 else 0.0
                    t = random.random() if mb else 0.0
                    xoffset = (x + px_off) * ps
                    yoffset = (y + py_off) * ps
                    pixel = inv * Point(hw - xoffset, hh - yoffset, -fd)
                    origin = inv * Point(ax, ay, 0)
                    direction = (pixel - origin).normalize()
                    c = world.color_at(Ray(origin, direction, time=t))
                    total_r += c.red
                    total_g += c.green
                    total_b += c.blue
                color = Color(total_r / spp, total_g / spp, total_b / spp)
            results.append((y, x, color))
    return results


class Camera:
    def __init__(
        self,
        hsize: int,
        vsize: int,
        field_of_view: float,
        samples_per_pixel: int = 1,
        aperture_size: float = 0.0,
        focal_distance: float = 1.0,
        motion_blur: bool = False,
    ) -> None:
        self.hsize = hsize
        self.vsize = vsize
        self.field_of_view = field_of_view
        self.samples_per_pixel = samples_per_pixel
        self.aperture_size = aperture_size
        self.focal_distance = focal_distance
        self.motion_blur = motion_blur
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

    def ray_for_pixel(
        self,
        px: int,
        py: int,
        pixel_offset_x: float = 0.5,
        pixel_offset_y: float = 0.5,
        aperture_offset_x: float = 0.0,
        aperture_offset_y: float = 0.0,
        time: float = 0.0,
    ):
        from rayz.ray import Ray

        xoffset = (px + pixel_offset_x) * self.pixel_size
        yoffset = (py + pixel_offset_y) * self.pixel_size
        world_x = self._half_width - xoffset
        world_y = self._half_height - yoffset

        inv = self._transform_inverse
        canvas_z = -self.focal_distance
        pixel = inv * Point(world_x, world_y, canvas_z)
        ax = aperture_offset_x * self.aperture_size
        ay = aperture_offset_y * self.aperture_size
        origin = inv * Point(ax, ay, 0)
        direction = (pixel - origin).normalize()
        return Ray(origin, direction, time=time)

    def _render_pixel(self, x: int, y: int, world):
        from rayz.color import Color

        if self.samples_per_pixel == 1 and self.aperture_size == 0.0 and not self.motion_blur:
            return world.color_at(self.ray_for_pixel(x, y))

        total_r = total_g = total_b = 0.0
        for _ in range(self.samples_per_pixel):
            ax = (random.random() * 2 - 1) if self.aperture_size > 0 else 0.0
            ay = (random.random() * 2 - 1) if self.aperture_size > 0 else 0.0
            t = random.random() if self.motion_blur else 0.0
            ray = self.ray_for_pixel(
                x,
                y,
                pixel_offset_x=random.random(),
                pixel_offset_y=random.random(),
                aperture_offset_x=ax,
                aperture_offset_y=ay,
                time=t,
            )
            c = world.color_at(ray)
            total_r += c.red
            total_g += c.green
            total_b += c.blue
        spp = self.samples_per_pixel
        return Color(total_r / spp, total_g / spp, total_b / spp)

    def render(self, world) -> Canvas:
        image = Canvas(self.hsize, self.vsize)
        for y in range(self.vsize):
            for x in range(self.hsize):
                color = self._render_pixel(x, y, world)
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
