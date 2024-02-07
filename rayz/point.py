from rayz.toople import *

class Point(Toople):
    def __init__(self, x:float=0.0, y:float=0.0, z:float=0.0) -> 'Point':
        super().__init__(x=x, y=y, z=z, w=1.0)
    
    def __str__(self) -> str:
        return f"Point({self.x}, {self.y}, {self.z}, {self.w})"
