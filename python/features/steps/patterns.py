from behave import given, then, use_step_matcher, when

from rayz.color import Color
from rayz.math_parser import parse_math
from rayz.matrix import Matrix
from rayz.pattern import (
    checkers_pattern,
    gradient_pattern,
    ring_pattern,
    stripe_pattern,
    test_pattern,
)
from rayz.transformations import scaling, translation
from rayz.tuple import Point

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

IDENTITY_MATRIX = Matrix.identity(4)

_TRANSFORM_MAP = {"scaling": scaling, "translation": translation}


def _eval_transform(expr: str):
    import re

    m = re.fullmatch(r"(scaling|translation)\((.+)\)", expr.strip())
    if m:
        args = [parse_math(a.strip()) for a in m.group(2).split(",")]
        return _TRANSFORM_MAP[m.group(1)](*args)
    raise ValueError(f"Unknown transform: {expr!r}")


# ---------------------------------------------------------------------------
# Given
# ---------------------------------------------------------------------------


@given(rf"{_V} ← stripe_pattern\({_V},\s*{_V}\)")
def step_given_stripe_pattern(context, var, a_var, b_var):
    setattr(context, var, stripe_pattern(getattr(context, a_var), getattr(context, b_var)))


@given(rf"{_V} ← gradient_pattern\({_V},\s*{_V}\)")
def step_given_gradient_pattern(context, var, a_var, b_var):
    setattr(context, var, gradient_pattern(getattr(context, a_var), getattr(context, b_var)))


@given(rf"{_V} ← ring_pattern\({_V},\s*{_V}\)")
def step_given_ring_pattern(context, var, a_var, b_var):
    setattr(context, var, ring_pattern(getattr(context, a_var), getattr(context, b_var)))


@given(rf"{_V} ← checkers_pattern\({_V},\s*{_V}\)")
def step_given_checkers_pattern(context, var, a_var, b_var):
    setattr(context, var, checkers_pattern(getattr(context, a_var), getattr(context, b_var)))


@given(rf"{_V} ← test_pattern\(\)")
def step_given_test_pattern(context, var):
    setattr(context, var, test_pattern())


@given(rf"set_pattern_transform\({_V},\s*(.+)\)")
def step_given_set_pattern_transform(context, var, expr):
    getattr(context, var).set_transform(_eval_transform(expr))


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(rf"set_pattern_transform\({_V},\s*(.+)\)")
def step_when_set_pattern_transform(context, var, expr):
    getattr(context, var).set_transform(_eval_transform(expr))


@when(rf"c ← stripe_at_object\({_V},\s*{_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_stripe_at_object(context, pat_var, obj_var, x, y, z):
    pat = getattr(context, pat_var)
    obj = getattr(context, obj_var)
    context.c = pat.pattern_at_shape(obj, Point(parse_math(x), parse_math(y), parse_math(z)))


@when(rf"c ← pattern_at_shape\({_V},\s*{_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_pattern_at_shape(context, pat_var, shape_var, x, y, z):
    pat = getattr(context, pat_var)
    shape = getattr(context, shape_var)
    context.c = pat.pattern_at_shape(shape, Point(parse_math(x), parse_math(y), parse_math(z)))


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(rf"{_V}\.a = {_V}")
def step_then_pattern_a(context, pat_var, color_var):
    assert getattr(context, pat_var).a == getattr(context, color_var)


@then(rf"{_V}\.b = {_V}")
def step_then_pattern_b(context, pat_var, color_var):
    assert getattr(context, pat_var).b == getattr(context, color_var)


@then(rf"stripe_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\) = {_V}")
def step_then_stripe_at_eq_var(context, pat_var, x, y, z, color_var):
    pat = getattr(context, pat_var)
    result = pat.pattern_at(Point(parse_math(x), parse_math(y), parse_math(z)))
    assert result == getattr(context, color_var)


@then(rf"pattern_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\) = {_V}")
def step_then_pattern_at_eq_var(context, pat_var, x, y, z, color_var):
    pat = getattr(context, pat_var)
    result = pat.pattern_at(Point(parse_math(x), parse_math(y), parse_math(z)))
    assert result == getattr(context, color_var)


@then(rf"pattern_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\) = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_pattern_at_eq_color(context, pat_var, px, py, pz, cr, cg, cb):
    pat = getattr(context, pat_var)
    result = pat.pattern_at(Point(parse_math(px), parse_math(py), parse_math(pz)))
    expected = Color(parse_math(cr), parse_math(cg), parse_math(cb))
    assert result == expected, f"{result!r} != {expected!r}"


@then(rf"{_V}\.transform = identity_matrix")
def step_then_pattern_transform_identity(context, var):
    assert getattr(context, var).transform == IDENTITY_MATRIX


@then(rf"{_V}\.transform = translation\({_A},\s*{_A},\s*{_A}\)")
def step_then_pattern_transform_translation(context, var, x, y, z):
    assert getattr(context, var).transform == translation(parse_math(x), parse_math(y), parse_math(z))


@then(rf"c = {_V}")
def step_then_c_eq_var(context, color_var):
    assert context.c == getattr(context, color_var)


@then(rf"c = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_c_eq_color(context, r, g, b):
    expected = Color(parse_math(r), parse_math(g), parse_math(b))
    assert context.c == expected, f"{context.c!r} != {expected!r}"
