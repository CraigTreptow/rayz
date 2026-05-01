import pytest
from behave import given, then, use_step_matcher

from rayz.math_parser import parse_math
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← triangle\({_V},\s*{_V},\s*{_V}\)")
def step_given_triangle(context, var, p1, p2, p3):
    setattr(context, var, Triangle(getattr(context, p1), getattr(context, p2), getattr(context, p3)))


_P = r"point\(([^\)]+)\)"


def _parse_point(spec: str) -> Point:
    x, y, z = [parse_math(v.strip()) for v in spec.split(",")]
    return Point(x, y, z)


@given(rf"{_V} ← triangle\({_P},\s*{_P},\s*{_P}\)")
def step_given_triangle_inline(context, var, p1, p2, p3):
    setattr(context, var, Triangle(_parse_point(p1), _parse_point(p2), _parse_point(p3)))


@then(rf"{_V}\.p1 = {_V}")
def step_then_triangle_p1(context, shape, pt):
    assert getattr(context, shape).p1 == getattr(context, pt)


@then(rf"{_V}\.p2 = {_V}")
def step_then_triangle_p2(context, shape, pt):
    assert getattr(context, shape).p2 == getattr(context, pt)


@then(rf"{_V}\.p3 = {_V}")
def step_then_triangle_p3(context, shape, pt):
    assert getattr(context, shape).p3 == getattr(context, pt)


@then(rf"{_V}\.e1 = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_triangle_e1(context, var, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, var).e1 == expected


@then(rf"{_V}\.e2 = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_triangle_e2(context, var, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, var).e2 == expected


@then(rf"{_V}\.normal = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_triangle_normal(context, var, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    actual = getattr(context, var).normal
    assert actual.x == pytest.approx(expected.x, abs=1e-5)
    assert actual.y == pytest.approx(expected.y, abs=1e-5)
    assert actual.z == pytest.approx(expected.z, abs=1e-5)


@then(rf"{_V} = {_V}\.normal")
def step_then_var_eq_shape_normal(context, result_var, shape_var):
    assert getattr(context, result_var) == getattr(context, shape_var).normal
