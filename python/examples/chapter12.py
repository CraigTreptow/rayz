"""Chapter 12: Cylinders — table with legs, glass, metal, and candle cylinders."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cylinder import Cylinder
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.transformations import rotation_y, rotation_z, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 12: Cylinders ===\n")

    world = World()
    world.light = PointLight(Point(10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.5, 0.5, 0.5), Color(0.75, 0.75, 0.75))
    floor.material.reflective = 0.1
    world.objects.append(floor)

    for tx, tz in [(-2, 1.5), (2, 1.5), (-2, -1.5), (2, -1.5)]:
        leg = Cylinder()
        leg.minimum = 0
        leg.maximum = 3
        leg.closed = True
        leg.set_transform(translation(tx, 0, tz) * scaling(0.15, 1, 0.15))
        leg.material.color = Color(0.6, 0.4, 0.2)
        leg.material.diffuse = 0.8
        leg.material.specular = 0.3
        world.objects.append(leg)

    table_top = Cylinder()
    table_top.minimum = 0
    table_top.maximum = 0.2
    table_top.closed = True
    table_top.set_transform(translation(0, 3, 0) * scaling(2.5, 1, 2))
    table_top.material.color = Color(0.7, 0.45, 0.25)
    table_top.material.ambient = 0.1
    table_top.material.diffuse = 0.7
    table_top.material.specular = 0.4
    table_top.material.shininess = 50
    world.objects.append(table_top)

    glass = Cylinder()
    glass.minimum = 0
    glass.maximum = 1.5
    glass.set_transform(translation(-1, 3.2, 0) * scaling(0.4, 1, 0.4))
    glass.material.color = Color(0.8, 0.9, 1.0)
    glass.material.ambient = 0.0
    glass.material.diffuse = 0.1
    glass.material.specular = 1.0
    glass.material.shininess = 300
    glass.material.reflective = 0.9
    glass.material.transparency = 0.9
    glass.material.refractive_index = 1.5
    world.objects.append(glass)

    metal = Cylinder()
    metal.minimum = 0
    metal.maximum = 0.8
    metal.closed = True
    metal.set_transform(translation(1, 3.2, 0.5) * rotation_y(math.pi / 6) * scaling(0.3, 1, 0.3))
    metal.material.color = Color(0.7, 0.7, 0.7)
    metal.material.ambient = 0.1
    metal.material.diffuse = 0.6
    metal.material.specular = 0.9
    metal.material.shininess = 200
    metal.material.reflective = 0.8
    world.objects.append(metal)

    colored = Cylinder()
    colored.minimum = 0
    colored.maximum = 2
    colored.closed = True
    colored.set_transform(translation(0.5, 3.2, -0.8) * rotation_z(math.pi / 8) * scaling(0.15, 1, 0.15))
    colored.material.color = Color(0.8, 0.2, 0.3)
    colored.material.ambient = 0.2
    colored.material.diffuse = 0.8
    colored.material.specular = 0.3
    world.objects.append(colored)

    candle = Cylinder()
    candle.minimum = 0
    candle.maximum = 1.2
    candle.closed = True
    candle.set_transform(translation(-4, 0, -3) * scaling(0.2, 1, 0.2))
    candle.material.color = Color(0.9, 0.9, 0.8)
    candle.material.ambient = 0.3
    candle.material.diffuse = 0.6
    world.objects.append(candle)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(8, 6, -8), Point(0, 3, 0), Vector(0, 1, 0))

    print("Rendering 200x150 scene with cylinders...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter12.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Cylinders scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
