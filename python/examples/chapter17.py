"""Chapter 17: Smooth Triangles."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.smooth_triangle import SmoothTriangle
from rayz.transformations import view_transform
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Chapter 17: Smooth Triangles ===\n")

    world = World()
    world.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    floor = Plane()
    floor.material.pattern = checkers_pattern(Color(0.9, 0.9, 0.9), Color(0.1, 0.1, 0.1))
    floor.material.reflective = 0.1
    world.objects.append(floor)

    # Left: flat-shaded pyramid
    flat_verts = [
        (Point(-3, 0, -1), Point(-4, 0, 1), Point(-3.5, 2, 0), Color(1, 0, 0)),
        (Point(-3, 0, -1), Point(-3.5, 2, 0), Point(-2, 0, -1), Color(0, 1, 0)),
        (Point(-2, 0, -1), Point(-3.5, 2, 0), Point(-4, 0, 1), Color(0, 0, 1)),
        (Point(-4, 0, 1), Point(-2, 0, -1), Point(-3.5, 2, 0), Color(1, 1, 0)),
    ]
    for p1, p2, p3, color in flat_verts:
        t = Triangle(p1, p2, p3)
        t.material.color = color
        t.material.ambient = 0.2
        t.material.diffuse = 0.8
        t.material.specular = 0.4
        t.material.shininess = 50
        world.objects.append(t)

    # Right: smooth-shaded pyramid (same geometry, vertex normals for smooth shading)
    apex_n = Vector(0, 1, 0)
    smooth_verts = [
        (
            Point(3, 0, -1),
            Point(2, 0, 1),
            Point(2.5, 2, 0),
            Vector(0.5, 0, -1).normalize(),
            Vector(-0.5, 0, 1).normalize(),
            apex_n,
            Color(1, 0, 0),
        ),
        (
            Point(3, 0, -1),
            Point(2.5, 2, 0),
            Point(4, 0, -1),
            Vector(0.5, 0, -1).normalize(),
            apex_n,
            Vector(1, 0, 0).normalize(),
            Color(0, 1, 0),
        ),
        (
            Point(4, 0, -1),
            Point(2.5, 2, 0),
            Point(2, 0, 1),
            Vector(1, 0, 0).normalize(),
            apex_n,
            Vector(-0.5, 0, 1).normalize(),
            Color(0, 0, 1),
        ),
        (
            Point(2, 0, 1),
            Point(4, 0, -1),
            Point(2.5, 2, 0),
            Vector(-0.5, 0, 1).normalize(),
            Vector(1, 0, 0).normalize(),
            apex_n,
            Color(1, 1, 0),
        ),
    ]
    for p1, p2, p3, n1, n2, n3, color in smooth_verts:
        st = SmoothTriangle(p1, p2, p3, n1, n2, n3)
        st.material.color = color
        st.material.ambient = 0.2
        st.material.diffuse = 0.8
        st.material.specular = 0.9
        st.material.shininess = 200
        world.objects.append(st)

    camera = Camera(200, 100, math.pi / 3)
    camera.transform = view_transform(Point(0, 3, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("Rendering 200x100 scene: flat (left) vs smooth (right) shaded pyramids...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "chapter17.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Smooth triangles scene rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
