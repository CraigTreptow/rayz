from dataclasses import dataclass

@dataclass
class Toople:
    x: float = 0
    y: float = 0
    z: float = 0
    w: float = 0

    def is_point(self) -> bool:
        return self.w == 1.0

    def is_vector(self) -> bool:
        return self.w == 0.0
