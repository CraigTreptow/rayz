"""Chapter 10: Reflection and Refraction — mirrors, glass, and the Schlick effect."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere, glass_sphere
from rayz.transformations import rotation_x, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 10: Reflection and Refraction ===\n")

    world = World()
    world.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.15, 0.15, 0.15), Color(0.85, 0.85, 0.85))
    floor.material.ambient = 0.2
    floor.material.diffuse = 0.8
    floor.material.specular = 0
    floor.material.reflective = 0.4
    world.objects.append(floor)

    back_wall = Plane()
    back_wall.set_transform(rotation_x(math.pi / 2) * translation(0, 0, 5))
    back_wall.material.color = Color(0.15, 0.15, 0.25)
    back_wall.material.ambient = 0.2
    back_wall.material.diffuse = 0.7
    back_wall.material.specular = 0.3
    back_wall.material.shininess = 200
    back_wall.material.reflective = 0.5
    world.objects.append(back_wall)

    middle = glass_sphere()
    middle.set_transform(translation(-0.5, 1, 0.5))
    middle.material.color = Color(0.1, 0.1, 0.1)
    middle.material.diffuse = 0.1
    middle.material.ambient = 0
    middle.material.specular = 1.0
    middle.material.shininess = 300
    middle.material.reflective = 1.0
    world.objects.append(middle)

    right = Sphere()
    right.set_transform(translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
    right.material.color = Color(0.3, 0.3, 0.3)
    right.material.diffuse = 0.1
    right.material.ambient = 0
    right.material.specular = 1.0
    right.material.shininess = 300
    right.material.reflective = 0.9
    world.objects.append(right)

    left = glass_sphere()
    left.set_transform(translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33))
    left.material.color = Color(0.1, 0.2, 0.1)
    left.material.diffuse = 0.1
    left.material.ambient = 0
    left.material.specular = 1.0
    left.material.shininess = 300
    left.material.reflective = 0.9
    left.material.transparency = 0.9
    left.material.refractive_index = 1.5
    world.objects.append(left)

    inner = glass_sphere()
    inner.set_transform(translation(-0.5, 1, 0.5) * scaling(0.5, 0.5, 0.5))
    inner.material.refractive_index = 1.0000034
    world.objects.append(inner)

    camera = Camera(200, 100, math.pi / 3)
    camera.transform = view_transform(Point(0, 1.5, -5), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x100 scene with mirrors and glass...")
    canvas = camera.render_parallel(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter10.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Reflection and refraction scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
