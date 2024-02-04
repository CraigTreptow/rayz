# type: ignore

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
from behave import *
import rayz.util as U
import rayz.tuple_util as TU

@given('a ← tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    context.a = TU.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))

@given('p ← point({x}, {y}, {z})')
def step_impl(context, x, y, z):
    context.p = TU.new_point(x=float(x), y=float(y), z=float(z))

@given('v ← vector({x}, {y}, {z})')
def step_impl(context, x, y, z):
    context.v = TU.new_vector(x=float(x), y=float(y), z=float(z))

# THEN

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
