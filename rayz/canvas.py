# import rayz.util as U
from rayz.color import *
from rayz.util import *

class Canvas:
    def __init__(self, width:int=0, height:int=0)  -> None:
        self.width = width
        self.height = height
        self.grid = [[Color(red=0, green=0, blue=0) for _ in range(self.width)] for _ in range(self.height)]

    def pixel_at(self, row:int, column:int) -> Color:
        if column > self.width - 1:
          raise ColumnIndexTooLarge(f"Column index({column}) greater than {self.width - 1}")

        if row > self.height - 1:
          raise RowIndexTooLarge(f"Row index({row}) greater than {self.height - 1}")

        return self.grid[row][column]

    def write_pixel(self, row:int, column:int, color:Color) -> None:
        if column > self.width - 1:
          raise ColumnIndexTooLarge(f"Column index({column}) greater than {self.width - 1}")

        if row > self.height - 1:
          raise RowIndexTooLarge(f"Row index({row}) greater than {self.height - 1}")

        self.grid[row][column] = color

    def __str__(self) -> str:
        result = ""
        for r in range(self.height):
            for c in range(self.width):
                result += f"[{r},{c}]-{self.pixel_at(row=r, column=c)} "

            result += "\n"

        return result
