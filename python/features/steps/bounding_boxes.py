import math
import re

import pytest
from behave import given, then, use_step_matcher, when

from rayz.bounds import Bounds
from rayz.cone import Cone
from rayz.cube import Cube
from rayz.cylinder import Cylinder
from rayz.math_parser import parse_math
from rayz.plane import Plane
from rayz.ray import Ray
from rayz.shape import TestShape
from rayz.sphere import Sphere
from rayz.transformations import rotation_x, rotation_y, rotation_z, scaling, translation
from rayz.triangle import Triangle
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

_TRANSFORM_FUNCS = {
    "scaling": scaling,
    "translation": translation,
    "rotation_x": rotation_x,
    "rotation_y": rotation_y,
    "rotation_z": rotation_z,
}


def _parse_val(s: str) -> float:
    s = s.strip()
    if s == "∞":
        return math.inf
    if s == "-∞":
        return -math.inf
    return parse_math(s)


def _eval_single_transform(context, expr: str):
    expr = expr.strip()
    m = re.fullmatch(r"(scaling|translation|rotation_x|rotation_y|rotation_z)\((.+)\)", expr)
    if m:
        func = _TRANSFORM_FUNCS[m.group(1)]
        args = [parse_math(a.strip()) for a in m.group(2).split(",")]
        return func(*args)
    return getattr(context, expr)


def _eval_compound_transform(context, expr: str):
    parts = _split_on_star(expr)
    result = _eval_single_transform(context, parts[0])
    for part in parts[1:]:
        result = result * _eval_single_transform(context, part)
    return result


def _split_on_star(expr: str) -> list:
    """Split on * that are outside parentheses."""
    parts = []
    depth = 0
    current = []
    for ch in expr:
        if ch == "(":
            depth += 1
            current.append(ch)
        elif ch == ")":
            depth -= 1
            current.append(ch)
        elif ch == "*" and depth == 0:
            parts.append("".join(current).strip())
            current = []
        else:
            current.append(ch)
    if current:
        parts.append("".join(current).strip())
    return parts


def _assert_point_approx(expected_x, expected_y, expected_z, actual):
    tol = 1e-4
    for exp, act in [(expected_x, actual.x), (expected_y, actual.y), (expected_z, actual.z)]:
        if math.isinf(exp):
            assert act == exp
        else:
            assert act == pytest.approx(exp, abs=tol)


# ---------------------------------------------------------------------------
# Given: box creation
# ---------------------------------------------------------------------------


@given(r"box ← bounds\(\)")
def step_given_empty_bounds(context):
    context.box = Bounds()


@given(r"box ← bounds\(min: point\((.+),\s*(.+),\s*(.+)\), max: point\((.+),\s*(.+),\s*(.+)\)\)")
def step_given_bounds_with_min_max(context, min_x, min_y, min_z, max_x, max_y, max_z):
    context.box = Bounds(
        Point(_parse_val(min_x), _parse_val(min_y), _parse_val(min_z)),
        Point(_parse_val(max_x), _parse_val(max_y), _parse_val(max_z)),
    )


@given(r"(box\d+) ← bounds\(min: point\((.+),\s*(.+),\s*(.+)\), max: point\((.+),\s*(.+),\s*(.+)\)\)")
def step_given_named_bounds(context, var, min_x, min_y, min_z, max_x, max_y, max_z):
    setattr(
        context,
        var,
        Bounds(
            Point(_parse_val(min_x), _parse_val(min_y), _parse_val(min_z)),
            Point(_parse_val(max_x), _parse_val(max_y), _parse_val(max_z)),
        ),
    )


@given(r"shape ← sphere\(\)")
def step_given_sphere(context):
    context.shape = Sphere()


@given(r"shape ← plane\(\)")
def step_given_plane(context):
    context.shape = Plane()


@given(r"shape ← cube\(\)")
def step_given_cube(context):
    context.shape = Cube()


@given(r"shape ← cylinder\(\)")
def step_given_cylinder(context):
    context.shape = Cylinder()


@given(r"shape ← cone\(\)")
def step_given_cone(context):
    context.shape = Cone()


@given(
    r"shape ← triangle\(p1: point\((.+),\s*(.+),\s*(.+)\),"
    r" p2: point\((.+),\s*(.+),\s*(.+)\),"
    r" p3: point\((.+),\s*(.+),\s*(.+)\)\)"
)
def step_given_triangle(context, x1, y1, z1, x2, y2, z2, x3, y3, z3):
    context.shape = Triangle(
        Point(parse_math(x1), parse_math(y1), parse_math(z1)),
        Point(parse_math(x2), parse_math(y2), parse_math(z2)),
        Point(parse_math(x3), parse_math(y3), parse_math(z3)),
    )


@given(r"matrix ← (.+) \* (.+)")
def step_given_matrix_compound(context, expr1, expr2):
    context.matrix = _eval_single_transform(context, expr1) * _eval_single_transform(context, expr2)


@given(rf"set_transform\(({_V[1:-1]}),\s*(.+)\)")
def step_given_set_transform_compound(context, var, expr):
    getattr(context, var).set_transform(_eval_compound_transform(context, expr))


@given(r"direction ← normalize\(<(.+),\s*(.+),\s*(.+)>\)")
def step_given_direction_normalize(context, x, y, z):
    v = Vector(parse_math(x), parse_math(y), parse_math(z))
    context.direction = v.normalize()


@given(rf"r ← ray\(point\({_A},\s*{_A},\s*{_A}\),\s*{_V}\)")
def step_given_ray_with_direction_var(context, ox, oy, oz, dir_var):
    context.r = Ray(
        Point(parse_math(ox), parse_math(oy), parse_math(oz)),
        getattr(context, dir_var),
    )


@given(rf"r ← ray\({_V},\s*{_V}\)")
def step_given_ray_from_vars(context, orig_var, dir_var):
    context.r = Ray(getattr(context, orig_var), getattr(context, dir_var))


@given(r"child ← test_shape\(\)")
def step_given_child_test_shape(context):
    context.child = TestShape()


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(r"box ← bounds_of\(shape\)")
def step_when_bounds_of_shape(context):
    context.box = context.shape.bounds()


@when(r"(box\d+) ← transform\(box, matrix\)")
def step_when_transform_box(context, var):
    setattr(context, var, context.box.transform(context.matrix))


@when(r"(box\d+) ← merge\((box\d+),\s*(box\d+)\)")
def step_when_merge_boxes(context, result_var, box1_var, box2_var):
    setattr(context, result_var, getattr(context, box1_var).merge(getattr(context, box2_var)))


@when(rf"xs ← intersect\({_V},\s*{_V}\)")
def step_when_intersect(context, shape_var, ray_var):
    context.xs = getattr(context, shape_var).intersect(getattr(context, ray_var))


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(r"box\.min = point\((.+),\s*(.+),\s*(.+)\)")
def step_then_box_min(context, x, y, z):
    _assert_point_approx(_parse_val(x), _parse_val(y), _parse_val(z), context.box.min)


@then(r"box\.max = point\((.+),\s*(.+),\s*(.+)\)")
def step_then_box_max(context, x, y, z):
    _assert_point_approx(_parse_val(x), _parse_val(y), _parse_val(z), context.box.max)


@then(r"(box\d+)\.min = point\((.+),\s*(.+),\s*(.+)\)")
def step_then_named_box_min(context, var, x, y, z):
    _assert_point_approx(_parse_val(x), _parse_val(y), _parse_val(z), getattr(context, var).min)


@then(r"(box\d+)\.max = point\((.+),\s*(.+),\s*(.+)\)")
def step_then_named_box_max(context, var, x, y, z):
    _assert_point_approx(_parse_val(x), _parse_val(y), _parse_val(z), getattr(context, var).max)


@then(r"box contains point\((.+),\s*(.+),\s*(.+)\)")
def step_then_box_contains_point(context, x, y, z):
    p = Point(_parse_val(x), _parse_val(y), _parse_val(z))
    assert context.box.contains_point(p)


@then(r"box does not contain point\((.+),\s*(.+),\s*(.+)\)")
def step_then_box_not_contains_point(context, x, y, z):
    p = Point(_parse_val(x), _parse_val(y), _parse_val(z))
    assert not context.box.contains_point(p)


@then(r"box contains bounds\(min: point\((.+),\s*(.+),\s*(.+)\), max: point\((.+),\s*(.+),\s*(.+)\)\)")
def step_then_box_contains_bounds(context, min_x, min_y, min_z, max_x, max_y, max_z):
    b = Bounds(
        Point(_parse_val(min_x), _parse_val(min_y), _parse_val(min_z)),
        Point(_parse_val(max_x), _parse_val(max_y), _parse_val(max_z)),
    )
    assert context.box.contains_bounds(b)


@then(
    r"box does not contain bounds\(min: point\((.+),\s*(.+),\s*(.+)\),"
    r" max: point\((.+),\s*(.+),\s*(.+)\)\)"
)
def step_then_box_not_contains_bounds(context, min_x, min_y, min_z, max_x, max_y, max_z):
    b = Bounds(
        Point(_parse_val(min_x), _parse_val(min_y), _parse_val(min_z)),
        Point(_parse_val(max_x), _parse_val(max_y), _parse_val(max_z)),
    )
    assert not context.box.contains_bounds(b)


@then(r"intersects\(box, r\) = (true|false)")
def step_then_intersects(context, result):
    assert context.box.intersects(context.r) == (result == "true")


@then(rf"{_V}\.saved_ray is nothing")
def step_then_saved_ray_nothing(context, var):
    assert getattr(context, var).saved_ray is None


@then(rf"{_V}\.saved_ray is not nothing")
def step_then_saved_ray_not_nothing(context, var):
    assert getattr(context, var).saved_ray is not None
