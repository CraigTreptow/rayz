from behave import given, then, use_step_matcher, when

from rayz.math_parser import parse_math
from rayz.plane import Plane
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← plane\(\)")
def step_given_plane(context, var):
    setattr(context, var, Plane())


@when(rf"n1 ← local_normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_local_normal_at_1(context, var, x, y, z):
    context.n1 = getattr(context, var).local_normal_at(Point(parse_math(x), parse_math(y), parse_math(z)))


@when(rf"n2 ← local_normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_local_normal_at_2(context, var, x, y, z):
    context.n2 = getattr(context, var).local_normal_at(Point(parse_math(x), parse_math(y), parse_math(z)))


@when(rf"n3 ← local_normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_local_normal_at_3(context, var, x, y, z):
    context.n3 = getattr(context, var).local_normal_at(Point(parse_math(x), parse_math(y), parse_math(z)))


@when(rf"xs ← local_intersect\({_V},\s*{_V}\)")
def step_when_local_intersect(context, shape_var, ray_var):
    context.xs = getattr(context, shape_var).local_intersect(getattr(context, ray_var))


@then(r"xs is empty")
def step_then_xs_empty(context):
    assert context.xs == []


@then(rf"n1 = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_n1_eq_vector(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.n1 == expected


@then(rf"n2 = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_n2_eq_vector(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.n2 == expected


@then(rf"n3 = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_n3_eq_vector(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.n3 == expected
