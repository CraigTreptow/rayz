"""Chapter 14: Cones."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cone import Cone
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import (
    rotation_z,
    scaling,
    translation,
    view_transform,
)
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 14: Cones ===\n")

    world = World()
    world.light = PointLight(Point(10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.5, 0.5, 0.5), Color(0.75, 0.75, 0.75))
    floor.material.reflective = 0.1
    world.objects.append(floor)

    # Traffic cone (truncated, closed, orange)
    traffic = Cone()
    traffic.minimum = 0
    traffic.maximum = 2
    traffic.closed = True
    traffic.set_transform(translation(-3, 0, -2))
    traffic.material.color = Color(1, 0.5, 0)
    traffic.material.ambient = 0.2
    traffic.material.diffuse = 0.8
    traffic.material.specular = 0.3
    world.objects.append(traffic)

    # Glass cone (transparent, closed)
    glass = Cone()
    glass.minimum = -1
    glass.maximum = 1
    glass.closed = True
    glass.set_transform(translation(0, 1, 0))
    glass.material.color = Color(0.8, 0.9, 1.0)
    glass.material.ambient = 0.0
    glass.material.diffuse = 0.1
    glass.material.specular = 1.0
    glass.material.shininess = 300
    glass.material.reflective = 0.9
    glass.material.transparency = 0.9
    glass.material.refractive_index = 1.5
    world.objects.append(glass)

    # Metal cone (reflective, inverted)
    metal = Cone()
    metal.minimum = 0
    metal.maximum = 1.5
    metal.closed = True
    metal.set_transform(translation(3, 0, -1) * rotation_z(math.pi) * scaling(0.8, 1, 0.8))
    metal.material.color = Color(0.7, 0.7, 0.7)
    metal.material.ambient = 0.1
    metal.material.diffuse = 0.6
    metal.material.specular = 0.9
    metal.material.shininess = 200
    metal.material.reflective = 0.8
    world.objects.append(metal)

    # Ice cream cone (open, inverted) + scoop
    ice_cone = Cone()
    ice_cone.minimum = 0
    ice_cone.maximum = 2
    ice_cone.closed = False
    ice_cone.set_transform(translation(-1.5, 0, 2) * rotation_z(math.pi) * scaling(0.6, 1, 0.6))
    ice_cone.material.color = Color(0.9, 0.7, 0.4)
    ice_cone.material.ambient = 0.2
    ice_cone.material.diffuse = 0.8
    world.objects.append(ice_cone)

    scoop = Sphere()
    scoop.set_transform(translation(-1.5, 2, 2) * scaling(0.6, 0.6, 0.6))
    scoop.material.color = Color(1, 0.7, 0.8)
    scoop.material.ambient = 0.2
    scoop.material.diffuse = 0.7
    world.objects.append(scoop)

    # Hourglass (two cones sharing a tip)
    for tz_sign, min_y, max_y in [(1, 0, 1), (-1, 0, 1)]:
        c = Cone()
        c.minimum = min_y
        c.maximum = max_y
        c.closed = False
        c.set_transform(translation(4, 1, 2) * rotation_z(math.pi * tz_sign) * scaling(0.7, 1, 0.7))
        c.material.color = Color(0.2, 0.6, 0.8)
        c.material.diffuse = 0.7
        c.material.specular = 0.5
        world.objects.append(c)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(8, 5, -8), Point(0, 1.5, 0), Vector(0, 1, 0))

    print("Rendering 200x150 scene with cones...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter14.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Cones scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
