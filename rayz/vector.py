import math
from rayz.toople import *

class Vector(Toople):
    def __init__(self, x:float=0.0, y:float=0.0, z:float=0.0) -> None:
        super().__init__(x=x, y=y, z=z, w=0.0)

    def __str__(self) -> str:
        return f"Vector({self.x}, {self.y}, {self.z}, {self.w})"

    def magnitude(self) -> float:
        return math.sqrt(self.x**2 + self.y**2 + self.z**2)

    def normalize(self) -> 'Vector':
        mag = self.magnitude()
        nx = self.x / mag
        ny = self.y / mag
        nz = self.z / mag
        return Vector(x=nx, y=ny, z=nz)