import rayz.util as U
# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end

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

def equal(a: tuple, b: tuple) -> bool:
    return U.equal(a[0], b[0]) and U.equal(a[1], b[1]) and U.equal(a[2], b[2]) and U.equal(a[3], b[3])