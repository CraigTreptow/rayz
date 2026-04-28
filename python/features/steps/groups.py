from behave import given, then, use_step_matcher, when

from rayz.group import Group
from rayz.math_parser import parse_math
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← group\(\)")
def step_given_group(context, var):
    setattr(context, var, Group())


@given(rf"add_child\({_V},\s*{_V}\)")
def step_given_add_child(context, group_var, shape_var):
    getattr(context, group_var).add_child(getattr(context, shape_var))


@when(rf"add_child\({_V},\s*{_V}\)")
def step_when_add_child(context, group_var, shape_var):
    getattr(context, group_var).add_child(getattr(context, shape_var))


@when(rf"p ← world_to_object\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_world_to_object(context, shape_var, x, y, z):
    context.p = getattr(context, shape_var).world_to_object(
        Point(parse_math(x), parse_math(y), parse_math(z))
    )


@when(rf"n ← normal_to_world\({_V},\s*vector\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_normal_to_world(context, shape_var, x, y, z):
    context.n = getattr(context, shape_var).normal_to_world(
        Vector(parse_math(x), parse_math(y), parse_math(z))
    )


@then(r"g is empty")
def step_then_group_empty(context):
    assert context.g.children == []


@then(r"g is not empty")
def step_then_group_not_empty(context):
    assert context.g.children != []


@then(rf"{_V} includes {_V}")
def step_then_group_includes(context, group_var, shape_var):
    assert getattr(context, shape_var) in getattr(context, group_var).children


@then(rf"{_V}\.parent = {_V}")
def step_then_parent_eq(context, shape_var, parent_var):
    assert getattr(context, shape_var).parent is getattr(context, parent_var)
