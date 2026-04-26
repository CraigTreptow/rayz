"""Chapter 6: Light and Shading — Phong reflection model."""

from __future__ import annotations

import os

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.intersection import hit, intersect
from rayz.lighting import lighting
from rayz.point_light import PointLight
from rayz.ray import Ray
from rayz.sphere import Sphere
from rayz.tuple import Point, Vector


def run() -> None:
    print("\n=== Chapter 6: Light and Shading ===\n")

    sphere = Sphere()
    sphere.material.color = Color(1, 0.2, 1)

    light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    canvas_size = 200
    canvas = Canvas(canvas_size, canvas_size)

    ray_origin = Point(0, 0, -5)
    wall_z = 10.0
    wall_size = 7.0
    pixel_size = wall_size / canvas_size
    half = wall_size / 2.0

    print(f"Rendering {canvas_size}x{canvas_size} Phong-shaded sphere...")
    for row in range(canvas_size):
        world_y = half - pixel_size * row
        for col in range(canvas_size):
            world_x = -half + pixel_size * col
            target = Point(world_x, world_y, wall_z)
            diff = target - ray_origin
            direction = Vector(diff.x, diff.y, diff.z).normalize()
            r = Ray(ray_origin, direction)
            xs = intersect(sphere, r)
            h = hit(xs)
            if h is not None:
                point = r.position(h.t)
                normal = h.object.normal_at(point)
                eye = -r.direction
                color = lighting(h.object.material, light, point, eye, normal)
                canvas.write_pixel(col=col, row=row, color=color)

    out_path = os.path.join(os.path.dirname(__file__), "chapter6.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Shaded sphere with Phong lighting rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
