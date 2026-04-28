from behave import given, then, use_step_matcher, when

from rayz.cube import Cube
from rayz.math_parser import parse_math
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← cube\(\)")
def step_given_cube(context, var):
    setattr(context, var, Cube())


@given(rf"p ← point\({_A},\s*{_A},\s*{_A}\)")
def step_given_p_point(context, x, y, z):
    context.p = Point(parse_math(x), parse_math(y), parse_math(z))


@when(rf"xs ← local_intersect\({_V},\s*{_V}\)")
def step_when_local_intersect(context, shape_var, ray_var):
    context.xs = getattr(context, shape_var).local_intersect(getattr(context, ray_var))


@when(rf"normal ← local_normal_at\({_V},\s*{_V}\)")
def step_when_local_normal_at(context, shape_var, point_var):
    context.normal = getattr(context, shape_var).local_normal_at(getattr(context, point_var))


@then(rf"normal = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_normal_eq_vector(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.normal == expected, f"{context.normal!r} != {expected!r}"
