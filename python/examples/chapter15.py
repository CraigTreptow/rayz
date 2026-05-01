"""Chapter 15: Triangles."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import rotation_y, scaling, translation, view_transform
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 15: Triangles ===\n")

    world = World()
    world.light = PointLight(Point(10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.5, 0.5, 0.5), Color(0.75, 0.75, 0.75))
    floor.material.reflective = 0.1
    world.objects.append(floor)

    # Pyramid: 4 coloured triangular faces
    h, b = 2.0, 1.5
    p1, p2 = Point(-b, 0, -b), Point(b, 0, -b)
    p3, p4 = Point(b, 0, b), Point(-b, 0, b)
    apex = Point(0, h, 0)

    pyramid_offset = translation(-3, 0, 0)
    for verts, color in [
        ((p1, p2, apex), Color(1, 0.3, 0.3)),
        ((p2, p3, apex), Color(0.3, 1, 0.3)),
        ((p3, p4, apex), Color(0.3, 0.3, 1)),
        ((p4, p1, apex), Color(1, 1, 0.3)),
    ]:
        face = Triangle(*verts)
        face.set_transform(pyramid_offset)
        face.material.color = color
        face.material.ambient = 0.2
        face.material.diffuse = 0.7
        face.material.specular = 0.3
        world.objects.append(face)

    # Octahedron: 8 triangles
    s = 1.2
    top, bot = Point(0, s, 0), Point(0, -s, 0)
    fr, bk = Point(0, 0, s), Point(0, 0, -s)
    lft, rgt = Point(-s, 0, 0), Point(s, 0, 0)
    oct_xf = translation(0, 1.5, 0) * rotation_y(math.pi / 4)
    oct_faces = [
        (top, fr, rgt),
        (top, rgt, bk),
        (top, bk, lft),
        (top, lft, fr),
        (bot, rgt, fr),
        (bot, bk, rgt),
        (bot, lft, bk),
        (bot, fr, lft),
    ]
    for i, (a, b_, c) in enumerate(oct_faces):
        face = Triangle(a, b_, c)
        face.set_transform(oct_xf)
        t = i / 8
        face.material.color = Color(0.2 + t * 0.6, 0.2, 0.8 - t * 0.4)
        face.material.specular = 0.5
        world.objects.append(face)

    # Tetrahedron: 4 triangles
    ts = 1.3
    tp1, tp2 = Point(0, 0, -ts), Point(-ts, 0, ts)
    tp3, tapex = Point(ts, 0, ts), Point(0, ts * math.sqrt(3), 0)
    tet_xf = translation(3, 0, 0)
    for verts, color in [
        ((tp1, tp2, tp3), Color(0.9, 0.9, 0.2)),
        ((tp1, tp3, tapex), Color(0.2, 0.9, 0.9)),
        ((tp2, tp1, tapex), Color(0.9, 0.2, 0.9)),
        ((tp3, tp2, tapex), Color(0.9, 0.9, 0.9)),
    ]:
        face = Triangle(*verts)
        face.set_transform(tet_xf)
        face.material.color = color
        face.material.ambient = 0.2
        face.material.diffuse = 0.7
        face.material.specular = 0.3
        world.objects.append(face)

    sphere = Sphere()
    sphere.set_transform(translation(0, 1, -3) * scaling(0.8, 0.8, 0.8))
    sphere.material.color = Color(0.7, 0.7, 0.7)
    sphere.material.reflective = 0.3
    world.objects.append(sphere)

    camera = Camera(200, 150, math.pi / 3)
    camera.transform = view_transform(Point(8, 5, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x150 scene with triangles (pyramid, octahedron, tetrahedron)...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter15.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Triangles scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
