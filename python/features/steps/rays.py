from behave import given, then, use_step_matcher, when

from rayz.math_parser import parse_math
from rayz.ray import Ray
from rayz.transformations import scaling, translation
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------


@given(rf"{_V} ← ray\(point\({_A},\s*{_A},\s*{_A}\),\s*vector\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_ray_inline(context, var, ox, oy, oz, dx, dy, dz):
    origin = Point(parse_math(ox), parse_math(oy), parse_math(oz))
    direction = Vector(parse_math(dx), parse_math(dy), parse_math(dz))
    setattr(context, var, Ray(origin, direction))


@when(rf"{_V} ← ray\({_V},\s*{_V}\)")
def step_when_ray_vars(context, var, orig, dirn):
    setattr(context, var, Ray(getattr(context, orig), getattr(context, dirn)))


# ---------------------------------------------------------------------------
# Given: named transform matrices (reuse transform factories)
# ---------------------------------------------------------------------------


@given(rf"{_V} ← translation\({_A},\s*{_A},\s*{_A}\)")
def step_given_translation(context, var, x, y, z):
    setattr(context, var, translation(parse_math(x), parse_math(y), parse_math(z)))


@given(rf"{_V} ← scaling\({_A},\s*{_A},\s*{_A}\)")
def step_given_scaling(context, var, x, y, z):
    setattr(context, var, scaling(parse_math(x), parse_math(y), parse_math(z)))


# ---------------------------------------------------------------------------
# When: transform a ray
# ---------------------------------------------------------------------------


@when(rf"{_V} ← transform\({_V},\s*{_V}\)")
def step_when_transform_ray(context, result, ray_var, mat_var):
    setattr(context, result, getattr(context, ray_var).transform(getattr(context, mat_var)))


# ---------------------------------------------------------------------------
# Then: ray component assertions
# ---------------------------------------------------------------------------


@then(rf"{_V}\.origin = {_V}")
def step_then_ray_origin_eq_var(context, ray_var, point_var):
    assert getattr(context, ray_var).origin == getattr(context, point_var)


@then(rf"{_V}\.direction = {_V}")
def step_then_ray_direction_eq_var(context, ray_var, vec_var):
    assert getattr(context, ray_var).direction == getattr(context, vec_var)


@then(rf"{_V}\.origin = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_ray_origin_eq_point(context, ray_var, x, y, z):
    expected = Point(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, ray_var).origin == expected


@then(rf"{_V}\.direction = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_ray_direction_eq_vector(context, ray_var, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, ray_var).direction == expected


@then(rf"position\({_V},\s*{_A}\) = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_position(context, ray_var, t, x, y, z):
    result = getattr(context, ray_var).position(parse_math(t))
    expected = Point(parse_math(x), parse_math(y), parse_math(z))
    assert result == expected, f"position({ray_var}, {t}) = {result!r}, expected {expected!r}"
