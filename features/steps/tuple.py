# type: ignore

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
from behave import *
import rayz.util as U

@given('a ← tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    context.a = U.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))

@given('p ← point({x}, {y}, {z})')
def step_impl(context, x, y, z):
    context.p = U.new_point(x=float(x), y=float(y), z=float(z))

@given('v ← vector({x}, {y}, {z})')
def step_impl(context, x, y, z):
    context.v = U.new_vector(x=float(x), y=float(y), z=float(z))

# THEN

@then('v = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    assert (context.v == U.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))) is True

@then('p = tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    assert (context.p == U.new_tuple(x=float(x), y=float(y), z=float(z), w=float(w))) is True

@then('a.{x} = {v}')
def step_impl(context, x, v):
    a = context.a

    match x:
        case 'x':
            assert (a[0] == float(v)) is True
        case 'y':
            assert (a[1] == float(v)) is True
        case 'z':
            assert (a[2] == float(v)) is True
        case 'w':
            assert (a[3] == float(v)) is True

@then('a is a {type}')
def step_impl(context, type):
    a = context.a

    match a:
        case 'point':
            assert U.is_point(a) is True
        case 'vector':
            assert U.is_vector(a) is True

@then('a is not a {type}')
def step_impl(context, type):
    a = context.a

    match a:
        case 'point':
            assert U.is_point(a) is False
        case 'vector':
            assert U.is_vector(a) is False
