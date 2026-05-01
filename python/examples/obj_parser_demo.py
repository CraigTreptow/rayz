"""OBJ Parser Demo: load a Wavefront OBJ model and render it."""

from __future__ import annotations

import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.group import Group
from rayz.obj_parser import obj_to_group, parse_obj_file
from rayz.pattern import checkers_pattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.smooth_triangle import SmoothTriangle
from rayz.transformations import rotation_y, scaling, translation, view_transform
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector
from rayz.world import World


def _apply_material(group, material) -> None:
    for child in group.children:
        if isinstance(child, Group):
            _apply_material(child, material)
        else:
            child.material = material


def _count_triangles(group, count=0) -> int:
    for child in group.children:
        if isinstance(child, Group):
            count = _count_triangles(child, count)
        elif isinstance(child, (Triangle, SmoothTriangle)):
            count += 1
    return count


def run() -> None:
    print("\n=== OBJ Parser Demo ===\n")

    obj_path = os.path.join(os.path.dirname(__file__), "tetrahedron.obj")
    with open(obj_path) as f:
        content = f.read()

    parser = parse_obj_file(content)
    model = obj_to_group(parser)
    model.set_transform(rotation_y(0.5) * scaling(1.5, 1.5, 1.5))

    from rayz.material import Material

    mat = Material()
    mat.color = Color(0.8, 0.3, 0.3)
    mat.diffuse = 0.7
    mat.specular = 0.3
    _apply_material(model, mat)

    floor = Plane()
    floor.set_transform(translation(0, -2, 0))
    floor.material.pattern = checkers_pattern(Color(0.15, 0.15, 0.15), Color(0.85, 0.85, 0.85))
    floor.material.ambient = 0.8
    floor.material.diffuse = 0.2
    floor.material.specular = 0.0
    floor.material.reflective = 0.1

    world = World()
    world.light = PointLight(Point(-5, 5, -5), Color(1, 1, 1))
    world.objects.append(model)
    world.objects.append(floor)

    camera = Camera(200, 133, 1.0472)
    camera.transform = view_transform(Point(0, 3, -6), Point(0, 0, 0), Vector(0, 1, 0))

    n_verts = len(parser.vertices) - 1
    n_tris = _count_triangles(model)
    print(f"Loaded model: {n_verts} vertices, {n_tris} triangles")
    print("Rendering 200x133 scene...")
    canvas = camera.render(world)

    out_path = os.path.join(os.path.dirname(__file__), "obj_parser_demo.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("OBJ parser demo rendered.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
