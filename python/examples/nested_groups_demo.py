"""Nested Groups Demo: hierarchical transformations via world_to_object / normal_to_world."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.cylinder import Cylinder
from rayz.group import Group
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import rotation_y, rotation_z, scaling, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Nested Groups Demo ===")
    print("  Demonstrating hierarchical transformations (world_to_object / normal_to_world)")

    w = World()
    w.light = PointLight(Point(-10, 10, -10), Color(1, 1, 1))

    # Reflective checkerboard floor
    floor = Plane()
    floor.material.pattern = CheckersPattern(Color(0.9, 0.9, 0.9), Color(0.1, 0.1, 0.1))
    floor.material.reflective = 0.2
    w.objects.append(floor)

    # --- Solar system: Sun + Earth + Moon (6 levels) ---
    sun = Sphere()
    sun.material.color = Color(1, 0.9, 0.1)
    sun.material.ambient = 0.8
    sun.material.diffuse = 0.9
    sun.set_transform(scaling(1.5, 1.5, 1.5))
    w.objects.append(sun)

    earth_orbit = Group()
    earth_orbit.set_transform(rotation_y(math.pi / 4))
    earth_pos = Group()
    earth_pos.set_transform(translation(5, 0, 0))
    earth_rot = Group()
    earth_rot.set_transform(rotation_y(math.pi / 3))

    earth = Sphere()
    earth.material.color = Color(0.1, 0.3, 0.8)
    earth.material.diffuse = 0.7
    earth.material.specular = 0.3
    earth.set_transform(scaling(0.8, 0.8, 0.8))

    moon_orbit = Group()
    moon_orbit.set_transform(rotation_y(-math.pi / 6))
    moon_pos = Group()
    moon_pos.set_transform(translation(1.5, 0.3, 0))

    moon = Sphere()
    moon.material.color = Color(0.7, 0.7, 0.7)
    moon.material.diffuse = 0.6
    moon.set_transform(scaling(0.3, 0.3, 0.3))

    moon_pos.add_child(moon)
    moon_orbit.add_child(moon_pos)
    earth_rot.add_child(earth)
    earth_rot.add_child(moon_orbit)
    earth_pos.add_child(earth_rot)
    earth_orbit.add_child(earth_pos)
    w.objects.append(earth_orbit)

    # --- Mars + Phobos (5 levels) ---
    mars_orbit = Group()
    mars_orbit.set_transform(rotation_y(-math.pi / 3))
    mars_pos = Group()
    mars_pos.set_transform(translation(-7, 0, 2))

    mars = Sphere()
    mars.material.color = Color(0.9, 0.3, 0.1)
    mars.material.diffuse = 0.7
    mars.set_transform(scaling(0.6, 0.6, 0.6))

    phobos_orbit = Group()
    phobos_orbit.set_transform(rotation_y(math.pi / 2))
    phobos_pos = Group()
    phobos_pos.set_transform(translation(1.2, 0.2, 0))

    phobos = Sphere()
    phobos.material.color = Color(0.5, 0.5, 0.4)
    phobos.set_transform(scaling(0.2, 0.2, 0.2))

    phobos_pos.add_child(phobos)
    phobos_orbit.add_child(phobos_pos)
    mars_pos.add_child(mars)
    mars_pos.add_child(phobos_orbit)
    mars_orbit.add_child(mars_pos)
    w.objects.append(mars_orbit)

    # --- Space station: hub + 4 arms (3 levels) ---
    station = Group()
    station.set_transform(translation(0, 3, -8) * rotation_y(math.pi / 6))

    hub = Sphere()
    hub.material.color = Color(0.8, 0.8, 0.9)
    hub.material.reflective = 0.6
    hub.material.specular = 0.9
    hub.material.shininess = 300
    hub.set_transform(scaling(0.5, 0.5, 0.5))
    station.add_child(hub)

    for i in range(4):
        angle = (math.pi / 2) * i
        arm_group = Group()
        arm_group.set_transform(rotation_y(angle))
        arm_pos = Group()
        arm_pos.set_transform(translation(1, 0, 0))

        arm = Cylinder()
        arm.minimum = 0
        arm.maximum = 1.5
        arm.closed = True
        arm.material.color = Color(0.6, 0.6, 0.7)
        arm.material.specular = 0.5
        arm.set_transform(scaling(0.1, 1, 0.1) * rotation_z(math.pi / 2))

        end_sphere = Sphere()
        end_sphere.material.color = Color(0.3, 0.6, 0.9)
        end_sphere.material.reflective = 0.3
        end_sphere.set_transform(translation(1.5, 0, 0) * scaling(0.3, 0.3, 0.3))

        arm_pos.add_child(arm)
        arm_pos.add_child(end_sphere)
        arm_group.add_child(arm_pos)
        station.add_child(arm_group)

    w.objects.append(station)

    camera = Camera(800, 600, math.pi / 3)
    camera.transform = view_transform(Point(0, 8, -15), Point(0, 1, 0), Vector(0, 1, 0))

    print("  Scene: sun/earth/moon (6 levels), Mars/Phobos (5 levels), space station (3 levels)")
    print("  Rendering 800x600...")
    canvas = camera.render_parallel(w)

    out = os.path.join(os.path.dirname(__file__), "nested_groups_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Correct rendering confirms world_to_object / normal_to_world cascade")
    print("  properly through multiple levels of parent group transforms.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
