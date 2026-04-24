"""Chapter 3: Matrix operations — basic ops, inversion, and a clock-face visualization."""

import math
import os

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.matrix import Matrix
from rayz.tuple import Point


def _print_matrix(m: Matrix, rows: int = 4, cols: int = 4, precision: int = 2) -> None:
    for r in range(rows):
        values = [f"{m[r, c]:+{precision + 5}.{precision}f}" for c in range(cols)]
        print(f"  [{' '.join(values)}]")


def demo_basic_operations() -> None:
    print("1. Basic Matrix Operations")
    print("-" * 40)

    m = Matrix([[1, 2, 3, 4], [5, 6, 7, 8], [9, 8, 7, 6], [5, 4, 3, 2]])
    print("Matrix M:")
    _print_matrix(m)

    print("\nTranspose of M:")
    _print_matrix(m.transpose())

    print(f"\nDeterminant of M: {m.determinant():.2f}")

    identity = Matrix.identity(4)
    print(f"\nM * Identity == M: {m * identity == m}")
    print()


def demo_matrix_inversion() -> None:
    print("\n2. Matrix Inversion")
    print("-" * 40)

    m = Matrix([[3, -9, 7, 3], [3, -8, 2, -9], [-4, 4, 4, 1], [-6, 5, -1, 1]])
    print("Matrix A:")
    _print_matrix(m)

    print(f"\nDeterminant: {m.determinant():.2f}")
    print(f"Is invertible: {m.is_invertible()}")

    inv = m.inverse()
    print("\nInverse of A:")
    _print_matrix(inv, precision=5)

    product = m * inv
    print("\nA * inverse(A) ≈ Identity:")
    _print_matrix(product, precision=5)
    print()


def demo_clock_face() -> None:
    print("\n3. Clock Face Visualization")
    print("-" * 40)
    print("Drawing a clock using rotation matrices...")

    canvas = Canvas(width=400, height=400)
    white = Color(1.0, 1.0, 1.0)

    center_x, center_y, radius = 200, 200, 150

    for hour in range(12):
        angle = hour * math.pi / 6.0
        cos_a, sin_a = math.cos(angle), math.sin(angle)

        # Rotation in the XZ plane (Y-axis rotation), viewed from above
        rotation = Matrix(
            [
                [cos_a, 0, sin_a, 0],
                [0, 1, 0, 0],
                [-sin_a, 0, cos_a, 0],
                [0, 0, 0, 1],
            ]
        )

        twelve_oclock = Point(0, 0, radius)
        rotated = rotation * twelve_oclock

        # Map XZ to canvas XY; round to nearest pixel
        canvas_x = center_x + round(rotated.x)
        canvas_y = center_y + round(rotated.z)

        # Draw a 5×5 dot for each hour mark
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                px, py = canvas_x + dx, canvas_y + dy
                if 0 <= px < 400 and 0 <= py < 400:
                    canvas.write_pixel(col=px, row=py, color=white)

    out_path = os.path.join(os.path.dirname(__file__), "chapter3.ppm")
    print(f"Writing {out_path}...", end="", flush=True)
    with open(out_path, "w") as f:
        f.write(canvas.to_ppm())
    print(" done.")
    print("Clock face with 12 hour marks drawn using rotation matrices.")
    print("\n" + "=" * 60 + "\n")


def run() -> None:
    print("\n=== Chapter 3: Matrices ===")
    print("Demonstrating matrix operations and transformations\n")
    demo_basic_operations()
    demo_matrix_inversion()
    demo_clock_face()


if __name__ == "__main__":
    run()
