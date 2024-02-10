import rayz.util as U

class Toople:
    def __init__(self, x:float=0.0, y:float=0.0, z:float=0.0, w:float=0.0)  -> None:
        self.x = x
        self.y = y
        self.z = z
        self.w = w

    def __str__(self) -> str:
        return f"Toople({self.x}, {self.y}, {self.z}, {self.w})"

    def __eq__(self, other:'Toople') -> bool:
        return U.equal(self.x, other.x) and U.equal(self.y, other.y) and U.equal(self.z, other.z) and U.equal(self.w, other.w)

    def __add__(self, other:'Toople') -> 'Toople':
        return Toople(x=self.x + other.x, y=self.y + other.y, z=self.z + other.z, w=self.w + other.w)

    def __sub__(self, other:'Toople') -> 'Toople':
        return Toople(x=self.x - other.x, y=self.y - other.y, z=self.z - other.z, w=self.w - other.w)

    def __neg__(self) -> 'Toople':
        nx = self.x * -1
        ny = self.y * -1
        nz = self.z * -1
        nw = self.w * -1
        return Toople(x=nx, y=ny, z=nz, w=nw)

    def scalar_mult(self, scalar:float) -> 'Toople':
        nx = self.x * scalar
        ny = self.y * scalar
        nz = self.z * scalar
        nw = self.w * scalar
        return Toople(x=nx, y=ny, z=nz, w=nw)

    def scalar_div(self, scalar:float) -> 'Toople':
        nx = self.x / scalar
        ny = self.y / scalar
        nz = self.z / scalar
        nw = self.w / scalar
        return Toople(x=nx, y=ny, z=nz, w=nw)

    def is_point(self) -> bool:
        return self.w == 1.0

    def is_vector(self) -> bool:
        return self.w == 0.0