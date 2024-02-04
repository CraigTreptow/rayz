# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
import rayz.util as U
import rayz.tuple_util as TU

@given('{t} ← tuple({x}, {y}, {z}, {w})')
def step_impl(context, t, x, y, z, w):
    new_tuple = TU.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))

    match t:
        case 'a':
            context.a = new_tuple
        case 'a1':
            context.a1 = new_tuple
        case 'a2':
            context.a2 = new_tuple

@given('{p} ← point({x}, {y}, {z})')
def step_impl(context, p, x, y, z):
    new_point = TU.new_point(x=float(x), y=float(y), z=float(z))

    match p:
        case 'p':
            context.p = new_point
        case 'p1':
            context.p1 = new_point
        case 'p2':
            context.p2 = new_point

@given('v ← vector({x}, {y}, {z})')
def step_impl(context, x, y, z):
    context.v = TU.new_vector(x=float(x), y=float(y), z=float(z))

# THEN

@then('{a} + {b} = tuple({x}, {y}, {z}, {w})')
def step_impl(context, a, b, x, y, z, w):
    expected = TU.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))
    result = None

    if (a == 'a1' and b == 'a2'):
        result = TU.add(context.a1, context.a2)

    assert TU.equal(result, expected) is True

@then('v = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    new = TU.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))
    assert TU.equal(context.v, new) is True

@then('p = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    new = TU.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))
    assert TU.equal(context.p, new) is True

@then('a.{x} = {v}')
def step_impl(context, x, v):
    a = context.a

    match x:
        case 'x':
            assert U.equal(a[0], float(v)) is True
        case 'y':
            assert U.equal(a[1], float(v)) is True
        case 'z':
            assert U.equal(a[2], float(v)) is True
        case 'w':
            assert U.equal(a[3], float(v)) is True

@then('a is a {type}')
def step_impl(context, type):
    a = context.a

    match a:
        case 'point':
            assert TU.is_point(a) is True
        case 'vector':
            assert TU.is_vector(a) is True

@then('a is not a {type}')
def step_impl(context, type):
    a = context.a

    match a:
        case 'point':
            assert TU.is_point(a) is False
        case 'vector':
            assert TU.is_vector(a) is False

@then('{a} - {b} = vector({x}, {y}, {z})')
def step_impl(context, a, b, x, y, z):
    expected = TU.new_vector(x=float(x), y=float(y), z=float(z))
    result = None

    if (a == 'p1' and b == 'p2'):
        result = TU.subtract(context.p1, context.p2)

    assert TU.equal(result, expected) is True
