"""Chapter 4: Transformation matrices — translation, scaling, rotation, shearing, and a clock demo."""

from __future__ import annotations

import math
import os

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.transformations import rotation_y, scaling, shearing, translation
from rayz.tuple import Point, Vector


def _draw_dot(canvas: Canvas, cx: int, cy: int, radius: int, color: Color) -> None:
    for dx in range(-radius, radius + 1):
        for dy in range(-radius, radius + 1):
            if dx * dx + dy * dy <= radius * radius:
                px, py = cx + dx, cy + dy
                if 0 <= px < canvas.width and 0 <= py < canvas.height:
                    canvas.write_pixel(col=px, row=py, color=color)


def _draw_line(canvas: Canvas, x0: int, y0: int, x1: int, y1: int, color: Color) -> None:
    """Bresenham's line algorithm."""
    dx, dy = abs(x1 - x0), abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        if 0 <= x0 < canvas.width and 0 <= y0 < canvas.height:
            canvas.write_pixel(col=x0, row=y0, color=color)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


def demo_translation() -> None:
    print("1. Translation")
    print("-" * 40)
    transform = translation(5, -3, 2)
    p = Point(-3, 4, 5)
    result = transform * p
    print(f"  point(-3, 4, 5) + translation(5, -3, 2) = {result!r}")

    v = Vector(-3, 4, 5)
    v_result = transform * v
    print(f"  vector(-3, 4, 5) + translation (vectors unaffected) = {v_result!r}")
    print()


def demo_scaling() -> None:
    print("2. Scaling and Reflection")
    print("-" * 40)
    transform = scaling(2, 3, 4)
    p = Point(-4, 6, 8)
    result = transform * p
    print(f"  point(-4, 6, 8) * scaling(2, 3, 4) = {result!r}")

    reflect = scaling(-1, 1, 1)
    result2 = reflect * Point(2, 3, 4)
    print(f"  point(2, 3, 4) * scaling(-1, 1, 1) = {result2!r}  (reflection across YZ plane)")
    print()


def demo_rotation() -> None:
    print("3. Rotation")
    print("-" * 40)
    p = Point(0, 0, 1)
    r45 = rotation_y(math.pi / 4)
    r90 = rotation_y(math.pi / 2)
    print(f"  point(0, 0, 1) rotated around Y by π/4: {r45 * p!r}")
    print(f"  point(0, 0, 1) rotated around Y by π/2: {r90 * p!r}")
    print()


def demo_shearing() -> None:
    print("4. Shearing")
    print("-" * 40)
    p = Point(2, 3, 4)
    transform = shearing(1, 0, 0, 0, 0, 0)
    result = transform * p
    print(f"  point(2, 3, 4) * shearing(1,0,0,0,0,0) = {result!r}  (x += y)")
    print()


def demo_chaining() -> None:
    print("5. Chained Transformations")
    print("-" * 40)
    from rayz.transformations import rotation_x

    p = Point(1, 0, 1)
    A = rotation_x(math.pi / 2)
    B = scaling(5, 5, 5)
    C = translation(10, 5, 7)

    p2 = A * p
    p3 = B * p2
    p4 = C * p3
    print(f"  After rotation:    {p2!r}")
    print(f"  After scaling:     {p3!r}")
    print(f"  After translation: {p4!r}")

    T = C * B * A
    chained = T * p
    print(f"  Chained (C*B*A)*p: {chained!r}  (matches: {chained == p4})")
    print()


def demo_analog_clock() -> None:
    print("6. Analog Clock — showing 3:00")
    print("-" * 40)

    canvas = Canvas(width=500, height=500)
    white = Color(1.0, 1.0, 1.0)
    red = Color(1.0, 0.0, 0.0)
    yellow = Color(1.0, 1.0, 0.0)
    cx, cy, radius = 250, 250, 180

    for hour in range(12):
        angle = hour * (math.pi / 6.0)
        twelve = Point(0, 0, radius)
        pos = rotation_y(angle) * twelve
        hx, hy = cx + round(pos.x), cy + round(pos.z)

        color = red if hour == 0 else (yellow if hour % 3 == 0 else white)
        dot_size = 4 if hour % 3 == 0 else 3
        _draw_dot(canvas, hx, hy, dot_size, color)

    # Hour hand at 3:00 (90°)
    hour_tip = rotation_y(math.pi / 2) * Point(0, 0, 100)
    _draw_line(canvas, cx, cy, cx + round(hour_tip.x), cy + round(hour_tip.z), red)

    # Minute hand at 12:00 (0°)
    _draw_line(canvas, cx, cy, cx, cy - 140, white)

    out_path = os.path.join(os.path.dirname(__file__), "chapter4.ppm")
    print(f"  Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("\n" + "=" * 60 + "\n")


def run() -> None:
    print("\n=== Chapter 4: Matrix Transformations ===\n")
    demo_translation()
    demo_scaling()
    demo_rotation()
    demo_shearing()
    demo_chaining()
    demo_analog_clock()


if __name__ == "__main__":
    run()
