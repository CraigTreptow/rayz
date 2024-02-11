import rayz.util as U

class Color:
    def __init__(self, red:float=0.0, green:float=0.0, blue:float=0.0)  -> None:
        self.red = red
        self.green = green
        self.blue = blue

    def __str__(self) -> str:
        return f"Color(red: {self.red}, green: {self.green}, blue: {self.blue})"

    def __eq__(self, other:object) -> bool:
        if not isinstance(other, Color):
            return NotImplemented

        return U.equal(self.red, other.red) and U.equal(self.green, other.green) and U.equal(self.blue, other.blue)

    def __add__(self, other:'Color') -> 'Color':
        return Color(red=self.red + other.red, green=self.green + other.green, blue=self.blue + other.blue)

    def __sub__(self, other:'Color') -> 'Color':
        return Color(red=self.red - other.red, green=self.green - other.green, blue=self.blue - other.blue)

    def __mul__(self, other:'Color') -> 'Color':
        return Color(red=self.red * other.red, green=self.green * other.green, blue=self.blue * other.blue)

    def scalar_mult(self, scalar:float) -> 'Color':
        n_red = self.red * scalar
        n_green = self.green * scalar
        n_blue = self.blue * scalar
        return Color(red=n_red, green=n_green, blue=n_blue)
