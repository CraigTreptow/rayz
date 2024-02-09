# type: ignore
from behave import *
import math

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
from rayz.toople import *
from rayz.point import *
from rayz.vector import *

@given('{v} ← vector({x}, {y}, {z})')
def step_impl(context, v, x, y, z):
    new_vector = Vector(x=float(x), y=float(y), z=float(z))

    match v:
        case 'v':
            context.v = new_vector
        case 'v1':
            context.v1 = new_vector
        case 'v2':
            context.v2 = new_vector
        case 'zero':
            context.zero = Vector(x=0.0, y=0.0, z=0.0)

# WHEN #######################################################################

@when('norm ← normalize(v)')
def step_impl(context):
    context.norm = context.v.normalize()

# THEN #######################################################################

@then('{a} - {b} = vector({x}, {y}, {z})')
def step_impl(context, a, b, x, y, z):
    expected = Vector(x=float(x), y=float(y), z=float(z))
    result = None

    if (a == 'p1' and b == 'p2'):
        result = context.p1 - context.p2

    if (a == 'v1' and b == 'v2'):
        result = context.v1 - context.v2

    if (a == 'zero' and b == 'v'):
        result = context.zero - context.v

    assert (result == expected) is True

@then('v = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    new = Toople(x=float(x), y=float(y), z=float(z), w=float(w))
    assert (context.v == new) is True

@then('magnitude({v}) = {result}')
def step_impl(context, v, result):
    match v:
        case 'v':
            v = context.v
        case 'norm':
            v = context.norm

    match result:
        case '1':
            assert (v.magnitude() == 1) is True
        case '√14':
            assert (v.magnitude() == math.sqrt(14)) is True

@then('normalize(v) = vector({x}, {y}, {z})')
def step_impl(context, x, y, z):
    expected = Vector(x=float(x), y=float(y), z=float(z))

    assert (context.v.normalize() == expected) is True

@then('normalize(v) = approximately vector({x}, {y}, {z})')
def step_impl(context, x, y, z):
    expected = Vector(x=float(x), y=float(y), z=float(z))

    assert (context.v.normalize() == expected) is True