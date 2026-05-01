import pytest
from behave import then, use_step_matcher, when

from rayz.intersection import intersection_with_uv, prepare_computations
from rayz.math_parser import parse_math
from rayz.smooth_triangle import SmoothTriangle
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@when(rf"{_V} ← smooth_triangle\({_V},\s*{_V},\s*{_V},\s*{_V},\s*{_V},\s*{_V}\)")
def step_when_smooth_triangle(context, var, p1, p2, p3, n1, n2, n3):
    setattr(
        context,
        var,
        SmoothTriangle(
            getattr(context, p1),
            getattr(context, p2),
            getattr(context, p3),
            getattr(context, n1),
            getattr(context, n2),
            getattr(context, n3),
        ),
    )


@then(rf"{_V}\.n1 = {_V}")
def step_then_smooth_n1(context, shape, nvar):
    assert getattr(context, shape).n1 == getattr(context, nvar)


@then(rf"{_V}\.n2 = {_V}")
def step_then_smooth_n2(context, shape, nvar):
    assert getattr(context, shape).n2 == getattr(context, nvar)


@then(rf"{_V}\.n3 = {_V}")
def step_then_smooth_n3(context, shape, nvar):
    assert getattr(context, shape).n3 == getattr(context, nvar)


@then(rf"xs\[(\d+)\]\.u = {_A}")
def step_then_xs_u(context, idx, val):
    assert context.xs[int(idx)].u == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"xs\[(\d+)\]\.v = {_A}")
def step_then_xs_v(context, idx, val):
    assert context.xs[int(idx)].v == pytest.approx(parse_math(val), abs=1e-5)


@when(rf"{_V} ← intersection_with_uv\({_A},\s*{_V},\s*{_A},\s*{_A}\)")
def step_when_intersection_with_uv(context, var, t, obj_var, u, v):
    setattr(
        context,
        var,
        intersection_with_uv(parse_math(t), getattr(context, obj_var), parse_math(u), parse_math(v)),
    )


@when(rf"n ← normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\),\s*{_V}\)")
def step_when_normal_at_with_hit(context, shape_var, x, y, z, hit_var):
    context.n = getattr(context, shape_var).normal_at(
        Point(parse_math(x), parse_math(y), parse_math(z)),
        getattr(context, hit_var),
    )


@when(rf"comps ← prepare_computations\({_V},\s*{_V},\s*{_V}\)")
def step_when_prepare_computations_3vars(context, i_var, r_var, xs_var):
    context.comps = prepare_computations(
        getattr(context, i_var), getattr(context, r_var), getattr(context, xs_var)
    )


@then(rf"comps\.normalv = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_comps_normalv(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.comps.normalv.x == pytest.approx(expected.x, abs=1e-5)
    assert context.comps.normalv.y == pytest.approx(expected.y, abs=1e-5)
    assert context.comps.normalv.z == pytest.approx(expected.z, abs=1e-5)
