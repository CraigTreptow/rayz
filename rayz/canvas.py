# import rayz.util as U
from rayz.color import *
from rayz.util import *

class Canvas:
    def __init__(self, height:int=0, width:int=0)  -> None:
        self.width = width
        self.height = height
        self.grid = [[Color(red=0, green=0, blue=0) for _ in range(self.width)] for _ in reversed(range(self.height))]

    def __str__(self) -> str:
        result = ""
        for y in range(self.height):
            for x in range(self.width):
                result += f"[{x},{y}]-{self.pixel_at(x=x, y=y)} "

            result += "\n"

        return result

    def pixel_at(self, x:int, y:int) -> Color:
        if x > self.width - 1:
          raise ColumnIndexTooLarge(f"Column index({x}) greater than {self.width - 1}")

        if y > self.height - 1:
          raise RowIndexTooLarge(f"Row index({y}) greater than {self.height - 1}")

        return self.grid[y][x]

    def write_pixel(self, x:int, y:int, color:Color) -> None:
        if x > self.width - 1:
          raise ColumnIndexTooLarge(f"Column index({x}) greater than {self.width - 1}")

        if y > self.height - 1:
          raise RowIndexTooLarge(f"Row index({y}) greater than {self.height - 1}")

        self.grid[y][x] = color

    def to_ppm(self) -> str:
        def clamp(value: float, min: int = 0, max: int = 255) -> int:
            n = round(value * max)
            return max if n > max else min if n < min else n

        ppm = f"P3\n{self.width} {self.height}\n255\n"
        for row in self.grid:
            for color in row:
                ppm  = ppm + f"{clamp(color.red)} {clamp(color.green)} {clamp(color.blue)} "
            ppm = ppm.rstrip()
            ppm = ppm + "\n"

        ppm = ppm + "\n"
        return ppm
