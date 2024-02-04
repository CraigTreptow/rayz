import rayz.util as U
# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end

def subtract(a: tuple, b: tuple) -> tuple:
    """
    Subtracts two tuples.  The second tuple is subtracted from the first.
    e.g. a - b --> subtract(a, b)
    """
    r0 = a[0] - b[0]
    r1 = a[1] - b[1]
    r2 = a[2] - b[2]
    r3 = a[3] - b[3]
    return new_tuple(x = r0, y = r1, z = r2, w = r3)

def add(a: tuple, b: tuple) -> tuple:
    """
    Adds two tuples.
    e.g. a + b --> add(a, b)
    """
    r0 = a[0] + b[0]
    r1 = a[1] + b[1]
    r2 = a[2] + b[2]
    r3 = a[3] + b[3]
    return new_tuple(x = r0, y = r1, z = r2, w = r3)

def new_tuple(x: float, y: float, z: float, w: float) -> tuple:
    """
    Creates a tuple with the given attributes in (x, y, z, w).
    e.g. new_tuple(x: 1.0, y: 2.0, z: 3.0, w: 4.0) --> (1.0, 2.0, 3.0 4.0)
    """
    return (x, y, z, w)

def new_point(x: float, y: float, z: float) -> tuple:
    """
    Creates a point with the given attributes in (x, y, z).
    e.g. new_point(x: 1.0, y: 2.0, z: 3.0) --> (1.0, 2.0, 3.0, 1.0)
    """
    return (x, y, z, 1.0)

def new_vector(x: float, y: float, z: float) -> tuple:
    """
    Creates a vector with the given attributes in (x, y, z).
    e.g. new_vector(x: 1.0, y: 2.0, z: 3.0) --> (1.0, 2.0, 3.0, 0.0)
    """
    return (x, y, z, 0.0)

def is_point(t: tuple) -> bool:
    return t[3] == 1.0

def is_vector(t: tuple) -> bool:
    return t[3] == 0.0

def equal(a: tuple, b: tuple) -> bool:
    """
    Compares two tuples for equality, based on the values.
    e.g. equal(a: (1.0, 2.0, 3.0, 1.0), b: (1.0, 2.0, 3.0, 0.0) --> False
    """
    return U.equal(a[0], b[0]) and U.equal(a[1], b[1]) and U.equal(a[2], b[2]) and U.equal(a[3], b[3])