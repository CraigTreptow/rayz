# type: ignore

from behave import *
from rayz.toople import Toople

@given('a ← tuple(4.3, -4.2, 3.1, 1.0)')
def step_impl(context):
    context.a = Toople(x=4.3, y=-4.2, z=3.1, w=1.0)

@then('a.x = 4.3')
def step_impl(context):
    a = context.a
    assert a.x == 4.3

@then('a.y = -4.2')
def step_impl(context):
    assert context.a.y == -4.2

@then('a.z = 3.1')
def step_impl(context):
    assert context.a.z == 3.1

@then('a.w = 1.0')
def step_impl(context):
    assert context.a.w == 1.0

@then('a is a point')
def step_impl(context):
    assert context.a.is_point() is True


@then('a is not a vector')
def step_impl(context):
    assert context.a.is_vector() is False
