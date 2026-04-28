"""Chapter 11: Cubes — room, table, and boxes."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cube import Cube
from rayz.pattern import checkers_pattern
from rayz.point_light import PointLight
from rayz.transformations import rotation_y, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 11: Cubes ===\n")

    world = World()
    world.light = PointLight(Point(2, 10, -5), Color(0.9, 0.9, 0.9))

    room = Cube()
    room.set_transform(scaling(15, 15, 15))
    room.material.pattern = checkers_pattern(Color(0.15, 0.15, 0.15), Color(0.25, 0.25, 0.25))
    room.material.ambient = 0.3
    room.material.diffuse = 0.7
    room.material.specular = 0.0
    room.material.reflective = 0.1
    world.objects.append(room)

    table_top = Cube()
    table_top.set_transform(translation(0, 3.1, 0) * scaling(3, 0.1, 2))
    table_top.material.color = Color(0.6, 0.3, 0.1)
    table_top.material.ambient = 0.2
    table_top.material.diffuse = 0.7
    table_top.material.specular = 0.3
    table_top.material.shininess = 20
    world.objects.append(table_top)

    for tx, tz in [(-2.7, -1.7), (2.7, -1.7), (-2.7, 1.7), (2.7, 1.7)]:
        leg = Cube()
        leg.set_transform(translation(tx, 1.5, tz) * scaling(0.1, 1.5, 0.1))
        leg.material.color = Color(0.5, 0.25, 0.1)
        leg.material.ambient = 0.2
        leg.material.diffuse = 0.7
        world.objects.append(leg)

    glass_cube = Cube()
    glass_cube.set_transform(translation(0, 3.8, 0) * rotation_y(math.pi / 6) * scaling(0.5, 0.5, 0.5))
    glass_cube.material.color = Color(0.1, 0.1, 0.1)
    glass_cube.material.ambient = 0.0
    glass_cube.material.diffuse = 0.1
    glass_cube.material.specular = 1.0
    glass_cube.material.shininess = 300
    glass_cube.material.reflective = 0.9
    glass_cube.material.transparency = 0.9
    glass_cube.material.refractive_index = 1.5
    world.objects.append(glass_cube)

    metal_cube = Cube()
    metal_cube.set_transform(translation(1.5, 4.0, 1.0) * rotation_y(math.pi / 4) * scaling(0.7, 0.7, 0.7))
    metal_cube.material.color = Color(0.3, 0.3, 0.3)
    metal_cube.material.ambient = 0.1
    metal_cube.material.diffuse = 0.3
    metal_cube.material.specular = 0.9
    metal_cube.material.shininess = 200
    metal_cube.material.reflective = 0.8
    world.objects.append(metal_cube)

    small_cube = Cube()
    small_cube.set_transform(translation(-1.8, 3.6, -0.5) * rotation_y(math.pi / 8) * scaling(0.4, 0.4, 0.4))
    small_cube.material.color = Color(0.8, 0.2, 0.2)
    small_cube.material.ambient = 0.2
    small_cube.material.diffuse = 0.8
    small_cube.material.specular = 0.3
    world.objects.append(small_cube)

    floor_box = Cube()
    floor_box.set_transform(translation(4, 0.6, 3) * rotation_y(math.pi / 5) * scaling(0.6, 0.6, 0.6))
    floor_box.material.color = Color(0.2, 0.4, 0.8)
    floor_box.material.ambient = 0.2
    floor_box.material.diffuse = 0.8
    floor_box.material.specular = 0.2
    world.objects.append(floor_box)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(8, 6, -8), Point(0, 3, 0), Vector(0, 1, 0))

    print("Rendering 200x150 scene with cubes (room, table, boxes)...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter11.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Cubes scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
