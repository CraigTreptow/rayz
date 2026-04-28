import math

from behave import given, then, use_step_matcher, when

from rayz.cylinder import Cylinder
from rayz.math_parser import parse_math
from rayz.ray import Ray
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← cylinder\(\)")
def step_given_cylinder(context, var):
    setattr(context, var, Cylinder())


@given(rf"{_V}\.minimum ← {_A}")
def step_given_cyl_minimum(context, var, val):
    getattr(context, var).minimum = parse_math(val)


@given(rf"{_V}\.maximum ← {_A}")
def step_given_cyl_maximum(context, var, val):
    getattr(context, var).maximum = parse_math(val)


@given(rf"{_V}\.closed ← (true|false)")
def step_given_cyl_closed(context, var, val):
    getattr(context, var).closed = val == "true"


@given(rf"direction ← normalize\(vector\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_direction_normalize(context, x, y, z):
    context.direction = Vector(parse_math(x), parse_math(y), parse_math(z)).normalize()


@given(rf"r ← ray\(point\({_A},\s*{_A},\s*{_A}\),\s*direction\)")
def step_given_ray_with_direction_var(context, x, y, z):
    context.r = Ray(Point(parse_math(x), parse_math(y), parse_math(z)), context.direction)


@when(rf"n ← local_normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_local_normal_at_cyl(context, var, x, y, z):
    context.n = getattr(context, var).local_normal_at(Point(parse_math(x), parse_math(y), parse_math(z)))


@then(rf"{_V}\.minimum = -infinity")
def step_then_minimum_neg_inf(context, var):
    assert getattr(context, var).minimum == -math.inf


@then(rf"{_V}\.maximum = infinity")
def step_then_maximum_inf(context, var):
    assert getattr(context, var).maximum == math.inf


@then(rf"{_V}\.closed = false")
def step_then_closed_false(context, var):
    assert getattr(context, var).closed is False
