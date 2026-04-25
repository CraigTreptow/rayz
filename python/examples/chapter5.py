"""Chapter 5: Ray-sphere intersections — silhouette rendering."""

from __future__ import annotations

import os

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.intersection import hit, intersect
from rayz.ray import Ray
from rayz.sphere import Sphere
from rayz.tuple import Point, Vector


def run() -> None:
    print("\n=== Chapter 5: Ray-Sphere Intersections ===\n")

    sphere = Sphere()
    canvas_size = 200
    canvas = Canvas(canvas_size, canvas_size)
    red = Color(1.0, 0.0, 0.0)

    ray_origin = Point(0, 0, -5)
    wall_z = 10.0
    wall_size = 7.0
    pixel_size = wall_size / canvas_size
    half = wall_size / 2.0

    print(f"Casting {canvas_size}x{canvas_size} rays at a unit sphere...")
    for row in range(canvas_size):
        world_y = half - pixel_size * row
        for col in range(canvas_size):
            world_x = -half + pixel_size * col
            target = Point(world_x, world_y, wall_z)
            diff = target - ray_origin
            direction = Vector(diff.x, diff.y, diff.z).normalize()
            r = Ray(ray_origin, direction)
            xs = intersect(sphere, r)
            if hit(xs) is not None:
                canvas.write_pixel(col=col, row=row, color=red)

    out_path = os.path.join(os.path.dirname(__file__), "chapter5.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Sphere silhouette rendered via ray casting.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
