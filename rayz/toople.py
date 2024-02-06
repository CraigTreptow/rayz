import rayz.util as U

class Toople:
    def __init__(self, x:float=0.0, y:float=0.0, z:float=0.0, w:float=0.0):
        self.x = x
        self.y = y
        self.z = z
        self.w = w

    def __str__(self):
        return f"Toople({self.x}, {self.y}, {self.z}, {self.w})"

    def __eq__(self, other):
        return U.equal(self.x, other.x) and U.equal(self.y, other.y) and U.equal(self.z, other.z) and U.equal(self.w, other.w)

    def __add__(self, other):
        return Toople(x=self.x + other.x, y=self.y + other.y, z=self.z + other.z, w=self.w + other.w)

    def __sub__(self, other):
        return Toople(x=self.x - other.x, y=self.y - other.y, z=self.z - other.z, w=self.w - other.w)

    def is_point(self):
        return self.w == 1.0

    def is_vector(self):
        return self.w == 0.0