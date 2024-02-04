def new_tuple(x: float, y: float, z: float, w: float) -> tuple:
    return (x,y,z,w)

def new_point(x: float, y: float, z: float) -> tuple:
    return (x,y,z,1.0)

def new_vector(x: float, y: float, z: float) -> tuple:
    return (x,y,z,0.0)

def is_point(t: tuple) -> bool:
    return t[3] == 1.0

def is_vector(t: tuple) -> bool:
    return t[3] == 0.0
