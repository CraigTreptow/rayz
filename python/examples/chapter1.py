"""Chapter 1: Projectile physics simulation."""

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
        velocity=Vector(1.0, 1.0, 0.0).normalize(),
    )
    environment = Environment(
        gravity=Vector(0.0, -0.1, 0.0),
        wind=Vector(-0.01, 0.0, 0.0),
    )

    print("Shooting projectile...")
    tick_count = 0
    while projectile.position.y > 0:
        x, y = projectile.position.x, projectile.position.y
        print(f"  Tick {tick_count:03d}: x={x:07.3f}  y={y:07.3f}")
        projectile = tick(environment, projectile)
        tick_count += 1
    print(f"Projectile hit the ground after {tick_count - 1} ticks.")
    print("\n" + "=" * 60 + "\n")


if __name__ == "__main__":
    run()
