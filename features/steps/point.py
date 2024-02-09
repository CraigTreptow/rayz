# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
from rayz.toople import *
from rayz.point import *
from rayz.vector import *

@given('{p} ← point({x}, {y}, {z})')
def step_impl(context, p, x, y, z):
    new_point = Point(x=float(x), y=float(y), z=float(z))

    match p:
        case 'p':
            context.p = new_point
        case 'p1':
            context.p1 = new_point
        case 'p2':
            context.p2 = new_point

# THEN #######################################################################

@then('{a} - {b} = point({x}, {y}, {z})')
def step_impl(context, a, b, x, y, z):
    expected = Point(x=float(x), y=float(y), z=float(z))
    result = None

    if (a == 'p' and b == 'v'):
        result = context.p - context.v

    assert (result == expected) is True
