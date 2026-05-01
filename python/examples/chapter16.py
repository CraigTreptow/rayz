"""Chapter 16: Constructive Solid Geometry (CSG)."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.csg import CSG
from rayz.cube import Cube
from rayz.cylinder import Cylinder
from rayz.pattern import checkers_pattern, gradient_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import rotation_x, rotation_y, rotation_z, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 16: Constructive Solid Geometry ===\n")

    world = World()
    world.light = PointLight(Point(-5, 5, -8), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.8, 0.8, 0.8), Color(0.2, 0.2, 0.2))
    floor.material.reflective = 0.2
    floor.material.specular = 0.0
    world.objects.append(floor)

    back_wall = Plane()
    back_wall.set_transform(rotation_x(math.pi / 2) * translation(0, 0, 5))
    back_wall.material.pattern = gradient_pattern(Color(0.3, 0.4, 0.6), Color(0.1, 0.2, 0.3))
    back_wall.material.specular = 0.0
    world.objects.append(back_wall)

    # Carved cube: cube minus sphere
    cube1 = Cube()
    cube1.material.color = Color(0.9, 0.7, 0.2)
    carved = CSG("difference", cube1, Sphere())
    carved.set_transform(translation(-3, 1.5, 0) * rotation_y(math.pi / 6))
    world.objects.append(carved)

    # Lens: two spheres intersected
    ls = Sphere()
    ls.set_transform(translation(-0.5, 0, 0))
    rs = Sphere()
    rs.set_transform(translation(0.5, 0, 0))
    for s in (ls, rs):
        s.material.transparency = 0.9
        s.material.refractive_index = 1.5
        s.material.color = Color(0.8, 0.9, 1.0)
        s.material.ambient = 0.0
        s.material.diffuse = 0.1
        s.material.specular = 0.9
        s.material.shininess = 300
    lens = CSG("intersection", ls, rs)
    lens.set_transform(translation(0, 1, 0) * rotation_y(math.pi / 8))
    world.objects.append(lens)

    # Hollow sphere: outer minus inner
    outer = Sphere()
    outer.material.color = Color(0.8, 0.2, 0.2)
    inner = Sphere()
    inner.set_transform(scaling(0.7, 0.7, 0.7))
    hollow = CSG("difference", outer, inner)
    hollow.set_transform(translation(3, 1.2, 0))
    world.objects.append(hollow)

    # Die: cube with pip holes
    die_cube = Cube()
    die_cube.material.color = Color(1, 1, 1)
    die = die_cube
    for tx, ty, tz in [(0, 0, 1.1), (-0.4, 1.1, -0.4), (0.4, 1.1, -0.4), (-0.4, 1.1, 0.4), (0.4, 1.1, 0.4)]:
        pip = Sphere()
        pip.set_transform(translation(tx, ty, tz) * scaling(0.2, 0.2, 0.2))
        die = CSG("difference", die, pip)
    die.set_transform(translation(-1.5, 0.55, -2) * rotation_y(math.pi / 5))
    world.objects.append(die)

    # Rounded cylinder: cylinder union two hemisphere caps
    cyl = Cylinder()
    cyl.minimum = -0.5
    cyl.maximum = 0.5
    cyl.material.color = Color(0.3, 0.7, 0.3)
    top_cap = Sphere()
    top_cap.set_transform(translation(0, 0.5, 0) * scaling(1, 0.5, 1))
    top_cap.material = cyl.material
    bot_cap = Sphere()
    bot_cap.set_transform(translation(0, -0.5, 0) * scaling(1, 0.5, 1))
    bot_cap.material = cyl.material
    rounded = CSG("union", CSG("union", cyl, top_cap), bot_cap)
    rounded.set_transform(translation(1.5, 0.75, -2) * rotation_z(math.pi / 6))
    world.objects.append(rounded)

    # Wedge-cut sphere
    ws = Sphere()
    ws.material.color = Color(0.6, 0.3, 0.8)
    ws.material.reflective = 0.2
    wedge = Cube()
    wedge.set_transform(rotation_y(math.pi / 4) * scaling(2, 2, 0.3))
    cut = CSG("difference", ws, wedge)
    cut.set_transform(translation(0, 1, -3) * rotation_y(-math.pi / 8))
    world.objects.append(cut)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(0, 2, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x150 CSG scene (carved cube, lens, hollow sphere, die, rounded cyl, wedge sphere)...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter16.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("CSG scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
