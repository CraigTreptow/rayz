import math
from rayz.toople import *

class Vector(Toople):
    def __init__(self, x:float=0.0, y:float=0.0, z:float=0.0) -> None:
        super().__init__(x=x, y=y, z=z, w=0.0)

    def __str__(self) -> str:
        return f"Vector({self.x}, {self.y}, {self.z}, {self.w})"

    def magnitude(self) -> float:
        """
        The distance represented by a vector is called its magnitude, or length.
        It's how far you would travel in a straight line if you were to walk from one end of the vector to the other.
        """
        return math.sqrt(self.x**2 + self.y**2 + self.z**2)

    def normalize(self) -> 'Vector':
        """
        Normalization is the process of taking an arbitrary vector and converting it into a unit vector.
        """
        mag = self.magnitude()
        nx = self.x / mag
        ny = self.y / mag
        nz = self.z / mag
        return Vector(x=nx, y=ny, z=nz)

    def dot(self, other:'Vector') -> float:
        """
        The smaller the dot product, the larger the angle between the vectors.
        For example, given two unit vectors, a dot product of 1 means the vectors are identical,
        and a dot product of -1 means they point in opposite directions.
        """
        return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w

    def cross(self, other:'Vector') -> 'Vector':
        """
        The cross product of two vectors is a third vector that is perpendicular to the original two.
        """
        nx = self.y * other.z - self.z * other.y
        ny = self.z * other.x - self.x * other.z
        nz = self.x * other.y - self.y * other.x
        return Vector(x=nx, y=ny, z=nz)