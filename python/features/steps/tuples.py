import pytest
from behave import given, then, use_step_matcher, when

from rayz.color import Color
from rayz.math_parser import parse_math
from rayz.tuple import Point, Tuple, Vector

use_step_matcher("re")

# Regex fragment matching one math expression argument (float, int, √n/d, π/d, etc.)
_A = r"([^\s,)]+)"
# Regex fragment matching a lowercase variable name
_V = r"([a-z][a-z0-9_]*)"


def _t(x, y, z, w):
    return Tuple(parse_math(x), parse_math(y), parse_math(z), parse_math(w))


def _p(x, y, z):
    return Point(parse_math(x), parse_math(y), parse_math(z))


def _v(x, y, z):
    return Vector(parse_math(x), parse_math(y), parse_math(z))


def _c(r, g, b):
    return Color(parse_math(r), parse_math(g), parse_math(b))


# ---------------------------------------------------------------------------
# Creation steps
# ---------------------------------------------------------------------------


@given(rf"{_V} ← tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_given_tuple(context, var, x, y, z, w):
    setattr(context, var, _t(x, y, z, w))


@given(rf"{_V} ← point\({_A},\s*{_A},\s*{_A}\)")
def step_given_point(context, var, x, y, z):
    setattr(context, var, _p(x, y, z))


@given(rf"{_V} ← vector\({_A},\s*{_A},\s*{_A}\)")
def step_given_vector(context, var, x, y, z):
    setattr(context, var, _v(x, y, z))


@given(rf"{_V} ← color\({_A},\s*{_A},\s*{_A}\)")
def step_given_color(context, var, r, g, b):
    setattr(context, var, _c(r, g, b))


# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------


@when(rf"{_V} ← normalize\({_V}\)")
def step_when_normalize(context, result, src):
    setattr(context, result, getattr(context, src).normalize())


@when(rf"{_V} ← reflect\({_V},\s*{_V}\)")
def step_when_reflect(context, result, v, n):
    setattr(context, result, getattr(context, v).reflect(getattr(context, n)))


# ---------------------------------------------------------------------------
# Component access assertions
# ---------------------------------------------------------------------------


@then(rf"{_V}\.x = {_A}")
def step_then_x(context, var, val):
    assert getattr(context, var).x == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.y = {_A}")
def step_then_y(context, var, val):
    assert getattr(context, var).y == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.z = {_A}")
def step_then_z(context, var, val):
    assert getattr(context, var).z == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.w = {_A}")
def step_then_w(context, var, val):
    assert getattr(context, var).w == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V} is a point")
def step_then_is_point(context, var):
    assert getattr(context, var).is_point()


@then(rf"{_V} is not a point")
def step_then_not_point(context, var):
    assert not getattr(context, var).is_point()


@then(rf"{_V} is a vector")
def step_then_is_vector(context, var):
    assert getattr(context, var).is_vector()


@then(rf"{_V} is not a vector")
def step_then_not_vector(context, var):
    assert not getattr(context, var).is_vector()


# ---------------------------------------------------------------------------
# Color component assertions
# ---------------------------------------------------------------------------


@then(rf"{_V}\.red = {_A}")
def step_then_red(context, var, val):
    assert getattr(context, var).red == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.green = {_A}")
def step_then_green(context, var, val):
    assert getattr(context, var).green == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.blue = {_A}")
def step_then_blue(context, var, val):
    assert getattr(context, var).blue == pytest.approx(parse_math(val), abs=1e-5)


# ---------------------------------------------------------------------------
# Equality assertions (RHS is a constructor expression)
# ---------------------------------------------------------------------------


@then(rf"{_V} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_eq_tuple(context, var, x, y, z, w):
    assert getattr(context, var) == _t(x, y, z, w)


@then(rf"{_V} = (?:approximately )?vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_eq_vector(context, var, x, y, z):
    assert getattr(context, var) == _v(x, y, z)


@then(rf"{_V} = (?:approximately )?point\({_A},\s*{_A},\s*{_A}\)")
def step_then_eq_point(context, var, x, y, z):
    assert getattr(context, var) == _p(x, y, z)


@then(rf"{_V} = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_eq_color(context, var, r, g, b):
    assert getattr(context, var) == _c(r, g, b)


# ---------------------------------------------------------------------------
# Arithmetic on LHS
# ---------------------------------------------------------------------------


@then(rf"{_V} \+ {_V} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_add_tuple(context, a, b, x, y, z, w):
    assert getattr(context, a) + getattr(context, b) == _t(x, y, z, w)


@then(rf"{_V} - {_V} = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_sub_vector(context, a, b, x, y, z):
    assert getattr(context, a) - getattr(context, b) == _v(x, y, z)


@then(rf"{_V} - {_V} = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_sub_point(context, a, b, x, y, z):
    assert getattr(context, a) - getattr(context, b) == _p(x, y, z)


@then(rf"-{_V} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_neg_tuple(context, var, x, y, z, w):
    assert -getattr(context, var) == _t(x, y, z, w)


@then(rf"{_V} \* {_A} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_mul_scalar_tuple(context, var, scalar, x, y, z, w):
    assert getattr(context, var) * parse_math(scalar) == _t(x, y, z, w)


@then(rf"{_V} / {_A} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_div_scalar_tuple(context, var, divisor, x, y, z, w):
    assert getattr(context, var) / parse_math(divisor) == _t(x, y, z, w)


# ---------------------------------------------------------------------------
# Magnitude, normalize, dot, cross
# ---------------------------------------------------------------------------


@then(rf"magnitude\({_V}\) = {_A}")
def step_then_magnitude(context, var, val):
    assert getattr(context, var).magnitude() == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"normalize\({_V}\) = (?:approximately )?vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_normalize_vector(context, var, x, y, z):
    assert getattr(context, var).normalize() == _v(x, y, z)


@then(rf"dot\({_V},\s*{_V}\) = {_A}")
def step_then_dot(context, a, b, val):
    assert getattr(context, a).dot(getattr(context, b)) == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"cross\({_V},\s*{_V}\) = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_cross(context, a, b, x, y, z):
    assert getattr(context, a).cross(getattr(context, b)) == _v(x, y, z)


# ---------------------------------------------------------------------------
# Color arithmetic
# ---------------------------------------------------------------------------


@then(rf"{_V} \+ {_V} = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_color_add(context, a, b, r, g, bl):
    assert getattr(context, a) + getattr(context, b) == _c(r, g, bl)


@then(rf"{_V} - {_V} = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_color_sub(context, a, b, r, g, bl):
    assert getattr(context, a) - getattr(context, b) == _c(r, g, bl)


@then(rf"{_V} \* {_V} = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_color_mul_color(context, a, b, r, g, bl):
    assert getattr(context, a) * getattr(context, b) == _c(r, g, bl)


@then(rf"{_V} \* {_A} = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_color_mul_scalar(context, var, scalar, r, g, bl):
    assert getattr(context, var) * parse_math(scalar) == _c(r, g, bl)
