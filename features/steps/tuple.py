# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
import rayz.util as U
from rayz.toople import *
from rayz.point import *
from rayz.vector import *

@given('{t} ← tuple({x}, {y}, {z}, {w})')
def step_impl(context, t, x, y, z, w):
    new_tuple = Toople(x=float(x), y=float(y), z=float(z), w=float(w))

    match t:
        case 'a':
            context.a = new_tuple
        case 'a1':
            context.a1 = new_tuple
        case 'a2':
            context.a2 = new_tuple

# THEN #######################################################################

@then('-{a} = tuple({x}, {y}, {z}, {w})')
def step_impl(context, a, x, y, z, w):
    expected = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    result = None

    if (a == 'a'):
        result = -context.a

    assert (result == expected) is True

@then('{a} * {scalar} = tuple({x}, {y}, {z}, {w})')
def step_impl(context, a, scalar, x, y, z, w):
    expected = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    result = None

    if (a == 'a' and scalar == '3.5'):
        result = context.a.scalar_mult(3.5)
    if (a == 'a' and scalar == '0.5'):
        result = context.a.scalar_mult(0.5)

    assert (result == expected) is True

@then('{a} / {scalar} = tuple({x}, {y}, {z}, {w})')
def step_impl(context, a, scalar, x, y, z, w):
    expected = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    result = None

    if (a == 'a' and scalar == '2'):
        result = context.a.scalar_div(2)

    assert (result == expected) is True

@then('{a} + {b} = tuple({x}, {y}, {z}, {w})')
def step_impl(context, a, b, x, y, z, w):
    expected = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    result = None

    if (a == 'a1' and b == 'a2'):
        result = context.a1 + context.a2

    assert (result == expected) is True

@then('p = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    new = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    assert (context.p == new) is True

@then('a.{x} = {v}')
def step_impl(context, x, v):
    a = context.a

    match x:
        case 'x':
            assert U.equal(a.x, float(v)) is True
        case 'y':
            assert U.equal(a.y, float(v)) is True
        case 'z':
            assert U.equal(a.z, float(v)) is True
        case 'w':
            assert U.equal(a.w, float(v)) is True

@then('a is a {type}')
def step_impl(context, type):
    a = context.a

    match type:
        case 'point':
            assert a.is_point() is True
        case 'vector':
            assert a.is_vector() is True

@then('a is not a {type}')
def step_impl(context, type):
    a = context.a

    match type:
        case 'point':
            assert a.is_point() is False
        case 'vector':
            assert a.is_vector() is False
