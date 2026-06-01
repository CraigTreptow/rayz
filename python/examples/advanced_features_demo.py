"""Advanced Features Demo: torus, normal perturbation, reflective materials."""

from __future__ import annotations

import math
import os

from rayz.camera import Camera
from rayz.color import Color
from rayz.normal_perturbations import quilted, sine_wave
from rayz.pattern import CheckersPattern
from rayz.plane import Plane
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.torus import Torus
from rayz.transformations import rotation_x, translation, view_transform
from rayz.tuple import Point, Vector
from rayz.world import World


def run() -> None:
    print("\n=== Advanced Features Demo ===")
    print("  Showcasing: Torus primitive, Normal Perturbation, Reflective Materials")

    w = World()
    w.light = PointLight(Point(-5, 10, -5), Color(1, 1, 1))

    # Checkerboard floor
    floor = Plane()
    floor.material.pattern = CheckersPattern(Color(0.5, 0.5, 0.5), Color(0.8, 0.8, 0.8))
    floor.material.specular = 0
    floor.material.reflective = 0.1
    w.objects.append(floor)

    # Red sphere with sine-wave normal perturbation (left)
    sphere1 = Sphere()
    sphere1.set_transform(translation(-2, 1, 0))
    sphere1.material.color = Color(1, 0.3, 0.3)
    sphere1.material.specular = 0.8
    sphere1.material.normal_perturbation = sine_wave(frequency=10, amplitude=0.15)
    w.objects.append(sphere1)

    # Green torus (centre)
    torus = Torus(major_radius=0.6, minor_radius=0.2)
    torus.set_transform(translation(0, 1.2, 0) * rotation_x(math.pi / 2))
    torus.material.color = Color(0.3, 1, 0.3)
    torus.material.specular = 0.8
    torus.material.reflective = 0.4
    w.objects.append(torus)

    # Blue sphere with quilted normal perturbation (right)
    sphere2 = Sphere()
    sphere2.set_transform(translation(2, 1, 0))
    sphere2.material.color = Color(0.3, 0.3, 1)
    sphere2.material.specular = 0.8
    sphere2.material.normal_perturbation = quilted(frequency=8, amplitude=0.2)
    w.objects.append(sphere2)

    camera = Camera(400, 200, math.pi / 3, samples_per_pixel=1)
    camera.transform = view_transform(Point(0, 3.5, -8), Point(0, 1, 0), Vector(0, 1, 0))

    print("  Rendering 400x200...")
    canvas = camera.render(w)

    out = os.path.join(os.path.dirname(__file__), "advanced_features_demo.ppm")
    with open(out, "w") as f:
        f.write(canvas.to_ppm())
    print(f"  Saved to {out}")
    print()
    print("  Features demonstrated:")
    print("    - Torus primitive (green donut)")
    print("    - Normal perturbation: sine_wave (red sphere), quilted (blue sphere)")
    print("    - Reflective materials")
    print("    - Checkerboard floor pattern")
    print()
    print("  Also available (not rendered to keep times down):")
    print("    - AreaLight (soft shadows via grid sampling)")
    print("    - Spotlight (cone beam with fade angle)")
    print("    - Anti-aliasing (samples_per_pixel > 1)")
    print("    - Focal blur (aperture_size > 0, focal_distance)")
    print("    - Motion blur (motion_blur=True, shape.motion_transform)")
    print("    - TextureMap (planar/cylindrical/spherical UV mapping)")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
