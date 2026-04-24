import pytest
from behave import given, then, use_step_matcher, when

from rayz.math_parser import parse_math
from rayz.transformations import (
    rotation_x,
    rotation_y,
    rotation_z,
    scaling,
    shearing,
    translation,
    view_transform,
)
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


def _get(context, name):
    return getattr(context, name)


def _p(x, y, z):
    return Point(parse_math(x), parse_math(y), parse_math(z))


def _v(x, y, z):
    return Vector(parse_math(x), parse_math(y), parse_math(z))


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------


@given(rf"{_V} ← translation\({_A},\s*{_A},\s*{_A}\)")
def step_given_translation(context, var, x, y, z):
    setattr(context, var, translation(parse_math(x), parse_math(y), parse_math(z)))


@given(rf"{_V} ← scaling\({_A},\s*{_A},\s*{_A}\)")
def step_given_scaling(context, var, x, y, z):
    setattr(context, var, scaling(parse_math(x), parse_math(y), parse_math(z)))


@given(rf"{_V} ← rotation_x\(([^)]+)\)")
def step_given_rotation_x(context, var, r):
    setattr(context, var, rotation_x(parse_math(r)))


@given(rf"{_V} ← rotation_y\(([^)]+)\)")
def step_given_rotation_y(context, var, r):
    setattr(context, var, rotation_y(parse_math(r)))


@given(rf"{_V} ← rotation_z\(([^)]+)\)")
def step_given_rotation_z(context, var, r):
    setattr(context, var, rotation_z(parse_math(r)))


@given(rf"{_V} ← shearing\({_A},\s*{_A},\s*{_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_given_shearing(context, var, xy, xz, yx, yz, zx, zy):
    setattr(
        context,
        var,
        shearing(
            parse_math(xy), parse_math(xz),
            parse_math(yx), parse_math(yz),
            parse_math(zx), parse_math(zy),
        ),
    )


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(rf"{_V} ← view_transform\({_V},\s*{_V},\s*{_V}\)")
def step_when_view_transform(context, var, frm, to, up):
    setattr(context, var, view_transform(_get(context, frm), _get(context, to), _get(context, up)))


@when(rf"{_V} ← {_V} \* {_V} \* {_V}")
def step_when_triple_mul(context, result, a, b, c):
    setattr(context, result, _get(context, a) * _get(context, b) * _get(context, c))


@when(rf"{_V} ← {_V} \* {_V}")
def step_when_mul(context, result, a, b):
    setattr(context, result, _get(context, a) * _get(context, b))


# ---------------------------------------------------------------------------
# Then: matrix * var assertions
# ---------------------------------------------------------------------------


@then(rf"{_V} \* {_V} = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_mul_point(context, mat, var, x, y, z):
    result = _get(context, mat) * _get(context, var)
    assert result == _p(x, y, z), f"{result!r} != point({x}, {y}, {z})"


@then(rf"{_V} \* {_V} = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_mul_vector(context, mat, var, x, y, z):
    result = _get(context, mat) * _get(context, var)
    assert result == _v(x, y, z), f"{result!r} != vector({x}, {y}, {z})"


@then(rf"{_V} \* {_V} = {_V}")
def step_then_mul_var(context, mat, operand, expected):
    result = _get(context, mat) * _get(context, operand)
    assert result == _get(context, expected), f"{result!r} != {expected}"


# ---------------------------------------------------------------------------
# Then: variable equality assertions
# ---------------------------------------------------------------------------


@then(rf"{_V} = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_var_is_point(context, var, x, y, z):
    assert _get(context, var) == _p(x, y, z)


@then(rf"{_V} = scaling\({_A},\s*{_A},\s*{_A}\)")
def step_then_var_is_scaling(context, var, x, y, z):
    assert _get(context, var) == scaling(parse_math(x), parse_math(y), parse_math(z))


@then(rf"{_V} = translation\({_A},\s*{_A},\s*{_A}\)")
def step_then_var_is_translation(context, var, x, y, z):
    assert _get(context, var) == translation(parse_math(x), parse_math(y), parse_math(z))
