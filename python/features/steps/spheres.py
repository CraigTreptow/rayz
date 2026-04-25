import re

import pytest
from behave import given, then, use_step_matcher, when

from rayz.intersection import intersect
from rayz.material import Material
from rayz.math_parser import parse_math
from rayz.matrix import Matrix
from rayz.ray import Ray
from rayz.sphere import Sphere, glass_sphere
from rayz.transformations import (
    rotation_x,
    rotation_y,
    rotation_z,
    scaling,
    shearing,
    translation,
)
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"
_I = r"(\d+)"

IDENTITY_MATRIX = Matrix.identity(4)

_TRANSFORM_FUNCS = {
    "scaling": scaling,
    "translation": translation,
    "rotation_x": rotation_x,
    "rotation_y": rotation_y,
    "rotation_z": rotation_z,
    "shearing": shearing,
}


def _eval_transform(context, expr: str) -> Matrix:
    """Evaluate a matrix expression: variable name or transform function call."""
    expr = expr.strip()
    m = re.fullmatch(r"(scaling|translation|rotation_x|rotation_y|rotation_z|shearing)\((.+)\)", expr)
    if m:
        func = _TRANSFORM_FUNCS[m.group(1)]
        args = [parse_math(a.strip()) for a in m.group(2).split(",")]
        return func(*args)
    return getattr(context, expr)


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------


@given(rf"{_V} ← sphere\(\)")
def step_given_sphere(context, var):
    setattr(context, var, Sphere())


@given(rf"{_V} ← glass_sphere\(\)")
def step_given_glass_sphere(context, var):
    setattr(context, var, glass_sphere())


@given(rf"{_V} ← material\(\)")
def step_given_material(context, var):
    setattr(context, var, Material())


@given(rf"{_V} ← ray\(point\({_A},\s*{_A},\s*{_A}\),\s*vector\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_ray(context, var, ox, oy, oz, dx, dy, dz):
    setattr(
        context,
        var,
        Ray(
            Point(parse_math(ox), parse_math(oy), parse_math(oz)),
            Vector(parse_math(dx), parse_math(dy), parse_math(dz)),
        ),
    )


# Chained matrix: m ← expr1 * expr2
@given(r"([A-Za-z][A-Za-z0-9_]*) ← (.+) \* (.+)")
def step_given_matrix_mul_expr(context, var, expr1, expr2):
    m1 = _eval_transform(context, expr1)
    m2 = _eval_transform(context, expr2)
    setattr(context, var, m1 * m2)


# set_transform with variable or inline expression
@given(rf"set_transform\({_V},\s*(.+)\)")
def step_given_set_transform(context, var, expr):
    getattr(context, var).set_transform(_eval_transform(context, expr))


# m.ambient ← value
@given(rf"{_V}\.ambient ← {_A}")
def step_given_set_ambient(context, var, val):
    getattr(context, var).ambient = parse_math(val)


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(rf"xs ← intersect\({_V},\s*{_V}\)")
def step_when_intersect(context, shape_var, ray_var):
    context.xs = intersect(getattr(context, shape_var), getattr(context, ray_var))


@when(rf"set_transform\({_V},\s*(.+)\)")
def step_when_set_transform(context, var, expr):
    getattr(context, var).set_transform(_eval_transform(context, expr))


@when(rf"n ← normal_at\({_V},\s*point\({_A},\s*{_A},\s*{_A}\)\)")
def step_when_normal_at(context, shape_var, x, y, z):
    context.n = getattr(context, shape_var).normal_at(Point(parse_math(x), parse_math(y), parse_math(z)))


@when(rf"m ← {_V}\.material")
def step_when_get_material(context, var):
    context.m = getattr(context, var).material


@when(rf"{_V}\.material ← {_V}")
def step_when_set_material(context, shape_var, mat_var):
    getattr(context, shape_var).material = getattr(context, mat_var)


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(rf"{_V}\.transform = identity_matrix")
def step_then_transform_is_identity(context, var):
    assert getattr(context, var).transform == IDENTITY_MATRIX


@then(rf"{_V}\.transform = {_V}")
def step_then_transform_eq_var(context, shape_var, mat_var):
    assert getattr(context, shape_var).transform == getattr(context, mat_var)


@then(rf"xs\.count = {_I}")
def step_then_xs_count(context, n):
    assert len(context.xs) == int(n)


@then(rf"xs\[{_I}\] = {_A}")
def step_then_xs_item_t_shorthand(context, idx, val):
    assert context.xs[int(idx)].t == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"xs\[{_I}\]\.t = {_A}")
def step_then_xs_item_t(context, idx, val):
    assert context.xs[int(idx)].t == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"xs\[{_I}\]\.object = {_V}")
def step_then_xs_item_object(context, idx, obj_var):
    assert context.xs[int(idx)].object is getattr(context, obj_var)


@then(rf"n = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_n_eq_vector(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.n == expected, f"{context.n!r} != vector({x},{y},{z})"


@then(r"n = normalize\(n\)")
def step_then_n_is_normalized(context):
    n = context.n
    assert n == Vector(n.x, n.y, n.z).normalize()


@then(r"m = material\(\)")
def step_then_m_is_default_material(context):
    assert context.m == Material()


@then(rf"{_V}\.material = {_V}")
def step_then_shape_material_eq_var(context, shape_var, mat_var):
    assert getattr(context, shape_var).material == getattr(context, mat_var)


@then(rf"{_V}\.material\.transparency = {_A}")
def step_then_material_transparency(context, var, val):
    assert getattr(context, var).material.transparency == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.material\.refractive_index = {_A}")
def step_then_material_refractive_index(context, var, val):
    assert getattr(context, var).material.refractive_index == pytest.approx(parse_math(val), abs=1e-5)
