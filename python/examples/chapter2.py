"""Chapter 2: Projectile trajectory rendered to a PPM canvas."""

import os

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.environment import Environment
from rayz.projectile import Projectile
from rayz.tuple import Point, Vector


def tick(env: Environment, proj: Projectile) -> Projectile:
    return Projectile(
        position=proj.position + proj.velocity,
        velocity=proj.velocity + env.gravity + env.wind,
    )


def run() -> None:
    projectile = Projectile(
        position=Point(0.0, 1.0, 0.0),
        velocity=Vector(1.0, 1.8, 0.0).normalize() * 11.25,
    )
    environment = Environment(
        gravity=Vector(0.0, -0.1, 0.0),
        wind=Vector(-0.01, 0.0, 0.0),
    )
    canvas = Canvas(width=900, height=550)
    red = Color(1.0, 0.0, 0.0)

    print("Calculating projectile trajectory...", end="", flush=True)
    tick_count = 0
    while projectile.position.y > 0:
        x = round(projectile.position.x)
        y = round(projectile.position.y)
        if 0 <= x < canvas.width and 0 <= y < canvas.height:
            canvas.write_pixel(col=x, row=y, color=red)
        projectile = tick(environment, projectile)
        tick_count += 1
    print(f" done ({tick_count} ticks).")

    out_path = os.path.join(os.path.dirname(__file__), "chapter2.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
