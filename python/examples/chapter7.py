"""Chapter 7: Making a Scene — world, camera, and shadows."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import (
    rotation_x,
    rotation_y,
    scaling,
    translation,
    view_transform,
)
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 7: Making a Scene ===\n")

    world = World()
    world.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    floor = Sphere()
    floor.set_transform(scaling(10, 0.01, 10))
    floor.material.color = Color(1, 0.9, 0.9)
    floor.material.specular = 0
    world.objects.append(floor)

    left_wall = Sphere()
    left_wall.set_transform(
        translation(0, 0, 5) * rotation_y(-math.pi / 4) * rotation_x(math.pi / 2) * scaling(10, 0.01, 10)
    )
    left_wall.material = floor.material
    world.objects.append(left_wall)

    right_wall = Sphere()
    right_wall.set_transform(
        translation(0, 0, 5) * rotation_y(math.pi / 4) * rotation_x(math.pi / 2) * scaling(10, 0.01, 10)
    )
    right_wall.material = floor.material
    world.objects.append(right_wall)

    middle = Sphere()
    middle.set_transform(translation(-0.5, 1, 0.5))
    middle.material.color = Color(0.1, 1, 0.5)
    middle.material.diffuse = 0.7
    middle.material.specular = 0.3
    world.objects.append(middle)

    right = Sphere()
    right.set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
    right.material.color = Color(0.5, 1, 0.1)
    right.material.diffuse = 0.7
    right.material.specular = 0.3
    world.objects.append(right)

    left = Sphere()
    left.set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33))
    left.material.color = Color(1, 0.8, 0.1)
    left.material.diffuse = 0.7
    left.material.specular = 0.3
    world.objects.append(left)

    camera = Camera(200, 100, math.pi / 3)
    camera.transform = view_transform(Point(0, 1.5, -5), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x100 scene with shadows...")
    canvas = camera.render_parallel(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter7.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Scene with floor, walls, and three spheres rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
