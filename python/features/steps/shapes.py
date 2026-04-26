from behave import given, then, use_step_matcher

from rayz.math_parser import parse_math
from rayz.matrix import Matrix
from rayz.shape import TestShape
from rayz.transformations import (
    rotation_x,
    rotation_y,
    rotation_z,
    scaling,
    translation,
)
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

IDENTITY_MATRIX = Matrix.identity(4)

_TRANSFORM_FUNCS = {
    "scaling": scaling,
    "translation": translation,
    "rotation_x": rotation_x,
    "rotation_y": rotation_y,
    "rotation_z": rotation_z,
}


def _eval_transform(context, expr: str) -> Matrix:
    import re
    expr = expr.strip()
    m = re.fullmatch(r"(scaling|translation|rotation_x|rotation_y|rotation_z)\((.+)\)", expr)
    if m:
        func = _TRANSFORM_FUNCS[m.group(1)]
        args = [parse_math(a.strip()) for a in m.group(2).split(",")]
        return func(*args)
    return getattr(context, expr)


@given(rf"{_V} ← test_shape\(\)")
def step_given_test_shape(context, var):
    setattr(context, var, TestShape())


@then(rf"{_V}\.transform = identity_matrix")
def step_then_shape_transform_identity(context, var):
    assert getattr(context, var).transform == IDENTITY_MATRIX


@then(rf"{_V}\.transform = {_V}")
def step_then_shape_transform_eq_var(context, shape_var, mat_var):
    assert getattr(context, shape_var).transform == getattr(context, mat_var)


@then(rf"{_V}\.transform = translation\({_A},\s*{_A},\s*{_A}\)")
def step_then_shape_transform_eq_translation(context, var, x, y, z):
    assert getattr(context, var).transform == translation(parse_math(x), parse_math(y), parse_math(z))


@then(rf"{_V}\.saved_ray\.origin = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_saved_ray_origin(context, var, x, y, z):
    expected = Point(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, var).saved_ray.origin == expected


@then(rf"{_V}\.saved_ray\.direction = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_saved_ray_direction(context, var, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, var).saved_ray.direction == expected


@then(rf"{_V}\.parent is nothing")
def step_then_parent_is_nothing(context, var):
    assert getattr(context, var).parent is None
