"""Benchmark scene for cross-language performance comparison.

Usage (from python/):
    uv run benchmark/scene.py --scene tiny|small|medium --output /path/to/out.ppm

Outputs a single JSON line to stdout with timing results.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import sys
import time

from rayz.camera import Camera
from rayz.color import Color
from rayz.cylinder import Cylinder
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World

_DEV_SCENES: dict[str, tuple[int, int]] = {
    "tiny": (20, 10),
    "small": (40, 20),
    "medium": (60, 30),
}
_PROD_SCENES: dict[str, tuple[int, int]] = {
    "tiny": (200, 100),
    "small": (400, 200),
    "medium": (600, 300),
}
SCENES = _DEV_SCENES if os.environ.get("DEV_MODE") == "true" else _PROD_SCENES


def build_world() -> World:
    world = World()
    world.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(
        Color(0.15, 0.15, 0.15),
        Color(0.85, 0.85, 0.85),
    )
    floor.material.ambient = 0.2
    floor.material.diffuse = 0.8
    floor.material.specular = 0
    floor.material.reflective = 0.3
    world.objects.append(floor)

    glass_sph = Sphere()
    glass_sph.set_transform(translation(-1.5, 1, 0))
    glass_sph.material.color = Color(0.1, 0.1, 0.1)
    glass_sph.material.ambient = 0
    glass_sph.material.diffuse = 0.1
    glass_sph.material.specular = 1.0
    glass_sph.material.shininess = 300
    glass_sph.material.transparency = 0.9
    glass_sph.material.refractive_index = 1.5
    glass_sph.material.reflective = 0.9
    world.objects.append(glass_sph)

    mirror_sph = Sphere()
    mirror_sph.set_transform(translation(1.5, 1, 0))
    mirror_sph.material.color = Color(0.9, 0.9, 0.9)
    mirror_sph.material.specular = 1.0
    mirror_sph.material.shininess = 300
    mirror_sph.material.reflective = 0.8
    world.objects.append(mirror_sph)

    matte_sph = Sphere()
    matte_sph.set_transform(translation(0, 1, 1))
    matte_sph.material.color = Color(0.8, 0.3, 0.3)
    world.objects.append(matte_sph)

    cyl = Cylinder()
    cyl.minimum = 0
    cyl.maximum = 2
    cyl.closed = True
    cyl.set_transform(translation(0, 0, -1) * scaling(0.3, 0.5, 0.3))
    cyl.material.color = Color(0.2, 0.6, 0.2)
    cyl.material.specular = 0.3
    world.objects.append(cyl)

    return world


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scene", required=True, choices=list(SCENES.keys()))
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    width, height = SCENES[args.scene]
    world = build_world()

    camera = Camera(width, height, math.pi / 3)
    camera.transform = view_transform(Point(0, 1.5, -5), Point(0, 1, 0), Vector(0, 1, 0))

    start = time.perf_counter()
    canvas = camera.render(world)
    with open(args.output, "w") as f:
        f.write(canvas.to_ppm())
    elapsed = time.perf_counter() - start

    result = {
        "scene": args.scene,
        "width": width,
        "height": height,
        "elapsed": round(elapsed, 4),
        "pixels_per_second": round(width * height / elapsed),
    }
    sys.stdout.write(json.dumps(result) + "\n")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
