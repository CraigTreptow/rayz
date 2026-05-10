"""Chapter 13: Groups — hierarchical scene composition."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cylinder import Cylinder
from rayz.group import Group
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import (
    rotation_x,
    scaling,
    translation,
    view_transform,
)
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 13: Groups ===\n")

    world = World()
    world.light = PointLight(Point(-5, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.9, 0.9, 0.9), Color(0.1, 0.1, 0.1))
    floor.material.reflective = 0.1
    world.objects.append(floor)

    # Tree: trunk (cylinder) + foliage group (spheres)
    trunk = Cylinder()
    trunk.minimum = 0
    trunk.maximum = 1.5
    trunk.closed = True
    trunk.material.color = Color(0.4, 0.2, 0.1)
    trunk.material.specular = 0.1

    foliage = Group()
    for tx, ty, tz, sx in [(0, 2, 0, 0.8), (-0.5, 1.7, 0, 0.6), (0.5, 1.7, 0.2, 0.6), (0, 2.5, 0, 0.5)]:
        s = Sphere()
        s.set_transform(translation(tx, ty, tz) * scaling(sx, sx, sx))
        s.material.color = Color(0.1, 0.5 + sx * 0.3, 0.1)
        s.material.specular = 0.3
        foliage.add_child(s)

    tree = Group()
    tree.add_child(trunk)
    tree.add_child(foliage)
    tree.set_transform(translation(-2, 0, 1))
    world.objects.append(tree)

    # Snowman: 3 spheres + cylinder nose
    snowman = Group()
    for ty, sx in [(0.6, 0.6), (1.5, 0.45), (2.2, 0.3)]:
        s = Sphere()
        s.set_transform(translation(0, ty, 0) * scaling(sx, sx, sx))
        s.material.color = Color(1, 1, 1)
        s.material.specular = 0.9
        s.material.shininess = 300
        snowman.add_child(s)

    nose = Cylinder()
    nose.minimum = 0
    nose.maximum = 0.3
    nose.closed = True
    nose.set_transform(translation(0, 2.2, 0.3) * rotation_x(math.pi / 2) * scaling(0.08, 1, 0.08))
    nose.material.color = Color(1, 0.5, 0)
    nose.material.specular = 0.1
    snowman.add_child(nose)
    snowman.set_transform(translation(2, 0, -1))
    world.objects.append(snowman)

    # Hexagon: 6 colored spheres in a ring
    hexagon = Group()
    for i in range(6):
        angle = i * math.pi / 3
        s = Sphere()
        s.set_transform(translation(math.cos(angle), 0.3, math.sin(angle)) * scaling(0.3, 0.3, 0.3))
        h = i / 6.0
        s.material.color = Color(
            (math.sin(h * math.pi * 2) + 1) / 2,
            (math.sin((h + 0.33) * math.pi * 2) + 1) / 2,
            (math.sin((h + 0.67) * math.pi * 2) + 1) / 2,
        )
        s.material.specular = 0.6
        s.material.reflective = 0.2
        hexagon.add_child(s)
    hexagon.set_transform(translation(0, 0, 3))
    world.objects.append(hexagon)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(0, 3, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x150 scene with groups (tree, snowman, hexagon)...")
    canvas = camera.render_parallel(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter13.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Groups scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
