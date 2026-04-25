import pytest
from behave import given, then, use_step_matcher, when

from rayz.intersection import Intersection, hit, intersections
from rayz.math_parser import parse_math
from rayz.sphere import Sphere

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"
_I = r"(\d+)"


# ---------------------------------------------------------------------------
# Given: sphere and intersection setup
# ---------------------------------------------------------------------------


@given(rf"{_V} ← sphere\(\)")
def step_given_sphere(context, var):
    setattr(context, var, Sphere())


@given(rf"{_V} ← intersection\({_A},\s*{_V}\)")
def step_given_intersection(context, var, t, obj_var):
    setattr(context, var, Intersection(parse_math(t), getattr(context, obj_var)))


@given(rf"{_V} ← intersections\((.+)\)")
def step_given_intersections(context, var, args):
    items = [getattr(context, a.strip()) for a in args.split(",")]
    setattr(context, var, intersections(*items))


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(rf"{_V} ← intersection\({_A},\s*{_V}\)")
def step_when_intersection(context, var, t, obj_var):
    setattr(context, var, Intersection(parse_math(t), getattr(context, obj_var)))


@when(rf"{_V} ← intersections\((.+)\)")
def step_when_intersections(context, var, args):
    items = [getattr(context, a.strip()) for a in args.split(",")]
    setattr(context, var, intersections(*items))


@when(rf"{_V} ← hit\({_V}\)")
def step_when_hit(context, var, xs_var):
    setattr(context, var, hit(getattr(context, xs_var)))


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(rf"{_V}\.t = {_A}")
def step_then_intersection_t(context, var, val):
    assert getattr(context, var).t == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.object = {_V}")
def step_then_intersection_object(context, var, obj_var):
    assert getattr(context, var).object is getattr(context, obj_var)


@then(rf"{_V}\.count = {_I}")
def step_then_xs_count(context, var, n):
    assert len(getattr(context, var)) == int(n)


@then(rf"{_V}\[{_I}\]\.t = {_A}")
def step_then_xs_item_t(context, var, idx, val):
    assert getattr(context, var)[int(idx)].t == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\[{_I}\]\.object = {_V}")
def step_then_xs_item_object(context, xs_var, idx, obj_var):
    assert getattr(context, xs_var)[int(idx)].object is getattr(context, obj_var)


@then(rf"{_V} is nothing")
def step_then_is_nothing(context, var):
    assert getattr(context, var) is None
