from __future__ import annotations

from rayz.color import Color

_MAX_COLOR = 255
_SCALE = _MAX_COLOR + 1  # 256, matching the book's scaling formula


class Canvas:
    """A 2D grid of pixels. Origin is bottom-left; row 0 is the bottom row."""

    def __init__(self, width: int, height: int) -> None:
        self.width = width
        self.height = height
        black = Color(0.0, 0.0, 0.0)
        self.pixels: list[list[Color]] = [[black] * width for _ in range(height)]

    def write_pixel(self, col: int, row: int, color: Color) -> None:
        if not (0 <= row < self.height):
            raise ValueError(f"write_pixel: row {row} out of bounds")
        if not (0 <= col < self.width):
            raise ValueError(f"write_pixel: col {col} out of bounds")
        self.pixels[row][col] = color

    def pixel_at(self, col: int, row: int) -> Color:
        if not (0 <= row < self.height):
            raise ValueError(f"pixel_at: row {row} out of bounds")
        if not (0 <= col < self.width):
            raise ValueError(f"pixel_at: col {col} out of bounds")
        return self.pixels[row][col]

    def to_ppm(self) -> str:
        lines = ["P3", f"{self.width} {self.height}", str(_MAX_COLOR)]
        # Rows top-to-bottom in the file (high row index first), cols right-to-left.
        for row in range(self.height - 1, -1, -1):
            values: list[str] = []
            for col in range(self.width - 1, -1, -1):
                pixel = self.pixels[row][col]
                values.append(str(min(_MAX_COLOR, max(0, round(pixel.red * _SCALE)))))
                values.append(str(min(_MAX_COLOR, max(0, round(pixel.green * _SCALE)))))
                values.append(str(min(_MAX_COLOR, max(0, round(pixel.blue * _SCALE)))))
            lines.append(" ".join(values))
        lines.append("")  # PPM files end with a newline
        return "\n".join(lines)
