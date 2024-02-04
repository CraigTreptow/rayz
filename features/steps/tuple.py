# type: ignore

from behave import *
import rayz.util as U

@given('a ← tuple({x}, {y}, {z}, {w})')
def step_impl(context, x, y, z, w):
    context.a = U.new_tuple(x=x, y=y, z=z, w=w)

@then('a.{x} = {v}')
def step_impl(context, x, v):
    match context.a:
        case 'x':
            assert a[0] == v
        case 'y':
            assert a[1] == v
        case 'z':
            assert a[2] == v
        case 'w':
            assert a[3] == v

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
