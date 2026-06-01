"""Bounding Boxes Demo: AABB optimization with grouped marbles."""

from __future__ import annotations

import math
import os
import random
import time

from rayz.camera import Camera
from rayz.color import Color
from rayz.group import Group
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Bounding Boxes Demo ===")
    print("  Performance optimization with Axis-Aligned Bounding Boxes")
    print("  Rendering a scene with many grouped objects...")

    floor = Plane()
    floor.material.color = Color(1, 0.9, 0.9)
    floor.material.specular = 0
    floor.material.pattern = CheckersPattern(Color(0.8, 0.8, 0.8), Color(0.2, 0.2, 0.2))

    groups = []
    rng = random.Random(42)  # deterministic seed for reproducibility

    for row in range(4):
        for col in range(4):
            group = Group()
            for i in range(6):
                sphere = Sphere()
                x = (col * 10) - 15 + rng.random() * 4
                y = 0.5 + rng.random() * 2
                z = (row * 10) - 15 + rng.random() * 4
                s = 0.3 + rng.random() * 0.5
                sphere.set_transform(translation(x, y, z) * scaling(s, s, s))

                mod = i % 3
                if mod == 0:  # glass
                    sphere.material.color = Color(0.1, 0.1, 0.1)
                    sphere.material.diffuse = 0.1
                    sphere.material.specular = 0.9
                    sphere.material.shininess = 300
                    sphere.material.reflective = 0.9
                    sphere.material.transparency = 0.9
                    sphere.material.refractive_index = 1.5
                elif mod == 1:  # metallic
                    sphere.material.color = Color(0.7, 0.7, 0.8)
                    sphere.material.diffuse = 0.3
                    sphere.material.specular = 1.0
                    sphere.material.shininess = 300
                    sphere.material.reflective = 0.8
                else:  # coloured
                    sphere.material.color = Color(
                        0.3 + rng.random() * 0.7,
                        0.3 + rng.random() * 0.7,
                        0.3 + rng.random() * 0.7,
                    )
                    sphere.material.diffuse = 0.7
                    sphere.material.specular = 0.3

                group.add_child(sphere)
            groups.append(group)

    w = World()
    w.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))
    w.objects.append(floor)
    for g in groups:
        w.objects.append(g)

    camera = Camera(600, 400, math.pi / 3)
    camera.transform = view_transform(Point(0, 5, -20), Point(0, 1, 0), Vector(0, 1, 0))

    total_spheres = len(groups) * 6
    print(f"  Scene: {total_spheres} spheres in {len(groups)} groups")
    print("  Rendering 600x400...")
    t0 = time.time()
    canvas = camera.render_parallel(w)
    elapsed = time.time() - t0
    print(f"  Rendered in {elapsed:.2f}s")

    out = os.path.join(os.path.dirname(__file__), "bounding_boxes_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Bounding boxes allow the ray tracer to skip entire groups when")
    print("  rays miss their AABB, reducing intersection tests significantly.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
