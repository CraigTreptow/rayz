import math

import pytest
from behave import given, then, use_step_matcher, when

from rayz.constants import EPSILON
from rayz.intersection import Intersection, prepare_computations
from rayz.math_parser import parse_math
from rayz.sphere import glass_sphere
from rayz.transformations import scaling, translation
from rayz.tuple import Vector
from rayz.world import schlick

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

_TRANSFORM_MAP = {"scaling": scaling, "translation": translation}


def _apply_table(obj, table):
    import re as re_

    all_rows = [(table.headings[0], table.headings[1])] + [(row[0], row[1]) for row in table]
    for prop, raw in all_rows:
        prop, raw = prop.strip(), raw.strip()
        if prop == "transform":
            m = re_.fullmatch(r"(scaling|translation)\((.+)\)", raw)
            func = _TRANSFORM_MAP[m.group(1)]
            args = [parse_math(a.strip()) for a in m.group(2).split(",")]
            obj.set_transform(func(*args))
        elif prop == "material.refractive_index":
            obj.material.refractive_index = parse_math(raw)
        elif prop == "material.transparency":
            obj.material.transparency = parse_math(raw)


# ---------------------------------------------------------------------------
# Given: glass sphere with table (uppercase variable names like A, B, C)
# ---------------------------------------------------------------------------


@given(rf"{_V} ← glass_sphere\(\) with:")
def step_given_glass_sphere_with_table(context, var):
    s = glass_sphere()
    _apply_table(s, context.table)
    setattr(context, var, s)


# ---------------------------------------------------------------------------
# Given: direct material property setters
# ---------------------------------------------------------------------------


@given(rf"{_V}\.material\.transparency ← {_A}")
def step_given_transparency(context, var, val):
    getattr(context, var).material.transparency = parse_math(val)


@given(rf"{_V}\.material\.refractive_index ← {_A}")
def step_given_refractive_index(context, var, val):
    getattr(context, var).material.refractive_index = parse_math(val)


@given(rf"{_V}\.material\.pattern ← test_pattern\(\)")
def step_given_material_test_pattern(context, var):
    from rayz.pattern import test_pattern

    getattr(context, var).material.pattern = test_pattern()


# ---------------------------------------------------------------------------
# When: prepare_computations with xs list
# ---------------------------------------------------------------------------


@when(rf"comps ← prepare_computations\({_V},\s*{_V},\s*{_V}\)")
def step_when_prepare_computations_with_xs(context, i_var, ray_var, xs_var):
    context.comps = prepare_computations(
        getattr(context, i_var), getattr(context, ray_var), getattr(context, xs_var)
    )


@when(r"reflectance ← schlick\(comps\)")
def step_when_schlick(context):
    context.reflectance = schlick(context.comps)


# ---------------------------------------------------------------------------
# Then: computations assertions
# ---------------------------------------------------------------------------


@then(rf"comps\.reflectv = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_comps_reflectv(context, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    assert context.comps.reflectv.x == pytest.approx(expected.x, abs=1e-5)
    assert context.comps.reflectv.y == pytest.approx(expected.y, abs=1e-5)
    assert context.comps.reflectv.z == pytest.approx(expected.z, abs=1e-5)


@then(rf"comps\.n1 = {_A}")
def step_then_comps_n1(context, val):
    assert context.comps.n1 == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"comps\.n2 = {_A}")
def step_then_comps_n2(context, val):
    assert context.comps.n2 == pytest.approx(parse_math(val), abs=1e-5)


@then(r"comps\.under_point\.z > EPSILON/2")
def step_then_under_point_z(context):
    assert context.comps.under_point.z > EPSILON / 2


@then(r"comps\.point\.z < comps\.under_point\.z")
def step_then_point_z_lt_under_point_z(context):
    assert context.comps.point.z < context.comps.under_point.z


@then(rf"reflectance = {_A}")
def step_then_reflectance(context, val):
    assert context.reflectance == pytest.approx(parse_math(val), abs=1e-5)


# ---------------------------------------------------------------------------
# Then: material assertions (s.material.* for glass_sphere helper test)
# ---------------------------------------------------------------------------


@then(rf"{_V}\.material\.transparency = {_A}")
def step_then_sphere_transparency(context, var, val):
    assert getattr(context, var).material.transparency == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.material\.refractive_index = {_A}")
def step_then_sphere_refractive_index(context, var, val):
    assert getattr(context, var).material.refractive_index == pytest.approx(parse_math(val), abs=1e-5)


@then(r"c = color\((.+),\s*(.+),\s*(.+)\)")
def step_then_c_eq_color(context, r, g, b):
    c = context.c
    assert c.red == pytest.approx(parse_math(r), abs=1e-4)
    assert c.green == pytest.approx(parse_math(g), abs=1e-4)
    assert c.blue == pytest.approx(parse_math(b), abs=1e-4)
