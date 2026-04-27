"""Chapter 8: Patterns and Planes — surfaces with patterns on infinite planes."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.pattern import checkers_pattern, gradient_pattern, ring_pattern, stripe_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import rotation_x, rotation_z, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 8: Patterns and Planes ===\n")

    world = World()
    world.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(1, 1, 1), Color(0.2, 0.2, 0.2))
    floor.material.specular = 0
    world.objects.append(floor)

    back_wall = Plane()
    back_wall.set_transform(rotation_x(math.pi / 2) * translation(0, 0, 5))
    back_wall.material.pattern = gradient_pattern(Color(0.5, 0.7, 1), Color(0.1, 0.1, 0.3))
    back_wall.material.pattern.set_transform(rotation_z(math.pi / 2) * scaling(2, 2, 2))
    back_wall.material.specular = 0
    world.objects.append(back_wall)

    middle = Sphere()
    middle.set_transform(translation(-0.5, 1, 0.5))
    middle.material.pattern = ring_pattern(Color(0.1, 1, 0.5), Color(0.9, 0.1, 0.9))
    middle.material.pattern.set_transform(scaling(0.2, 0.2, 0.2))
    middle.material.diffuse = 0.7
    middle.material.specular = 0.3
    world.objects.append(middle)

    right = Sphere()
    right.set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
    right.material.pattern = stripe_pattern(Color(1, 0.2, 0.2), Color(1, 1, 0.2))
    right.material.pattern.set_transform(scaling(0.2, 0.2, 0.2) * rotation_z(math.pi / 4))
    right.material.diffuse = 0.7
    right.material.specular = 0.3
    world.objects.append(right)

    left = Sphere()
    left.set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33))
    left.material.pattern = gradient_pattern(Color(1, 0.8, 0.1), Color(0.1, 0.2, 1))
    left.material.pattern.set_transform(translation(-1, 0, 0) * scaling(2, 2, 2))
    left.material.diffuse = 0.7
    left.material.specular = 0.3
    world.objects.append(left)

    camera = Camera(200, 100, math.pi / 3)
    camera.transform = view_transform(Point(0, 1.5, -5), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x100 scene with patterns on planes...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter8.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Patterns on planes rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
