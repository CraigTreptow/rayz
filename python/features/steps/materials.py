import pytest
from behave import given, then, use_step_matcher, when

from rayz.color import Color
from rayz.lighting import lighting
from rayz.math_parser import parse_math
from rayz.pattern import stripe_pattern
from rayz.point_light import PointLight
from rayz.tuple import Point

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


@given(rf"{_V} ← point_light\(point\({_A},\s*{_A},\s*{_A}\),\s*color\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_point_light_inline(context, var, px, py, pz, ir, ig, ib):
    setattr(
        context,
        var,
        PointLight(
            Point(parse_math(px), parse_math(py), parse_math(pz)),
            Color(parse_math(ir), parse_math(ig), parse_math(ib)),
        ),
    )


@given(rf"{_V}\.diffuse ← {_A}")
def step_given_set_diffuse(context, var, val):
    getattr(context, var).diffuse = parse_math(val)


@given(rf"{_V}\.specular ← {_A}")
def step_given_set_specular(context, var, val):
    getattr(context, var).specular = parse_math(val)


@given(rf"{_V}\.pattern ← stripe_pattern\(color\({_A},\s*{_A},\s*{_A}\),\s*color\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_set_pattern(context, var, r1, g1, b1, r2, g2, b2):
    getattr(context, var).pattern = stripe_pattern(
        Color(parse_math(r1), parse_math(g1), parse_math(b1)),
        Color(parse_math(r2), parse_math(g2), parse_math(b2)),
    )


@given(rf"{_V} ← true")
def step_given_true(context, var):
    setattr(context, var, True)


@when(
    rf"{_V} ← lighting\({_V},\s*{_V},\s*{_V},\s*{_V},\s*{_V}\)"
)
def step_when_lighting_no_shadow(context, result, mat, light, pos, eyev, normalv):
    setattr(
        context,
        result,
        lighting(
            getattr(context, mat),
            getattr(context, light),
            getattr(context, pos),
            getattr(context, eyev),
            getattr(context, normalv),
        ),
    )


@when(
    rf"{_V} ← lighting\({_V},\s*{_V},\s*{_V},\s*{_V},\s*{_V},\s*{_V}\)"
)
def step_when_lighting_with_shadow(context, result, mat, light, pos, eyev, normalv, shadow):
    shadow_val = getattr(context, shadow) if hasattr(context, shadow) else (shadow == "true")
    setattr(
        context,
        result,
        lighting(
            getattr(context, mat),
            getattr(context, light),
            getattr(context, pos),
            getattr(context, eyev),
            getattr(context, normalv),
            shadow_val,
        ),
    )


@when(
    rf"{_V} ← lighting\({_V},\s*{_V},\s*point\({_A},\s*{_A},\s*{_A}\),\s*{_V},\s*{_V},\s*(false|true)\)"
)
def step_when_lighting_inline_point(context, result, mat, light, px, py, pz, eyev, normalv, shadow):
    setattr(
        context,
        result,
        lighting(
            getattr(context, mat),
            getattr(context, light),
            Point(parse_math(px), parse_math(py), parse_math(pz)),
            getattr(context, eyev),
            getattr(context, normalv),
            shadow == "true",
        ),
    )


@then(rf"{_V}\.color = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_material_color(context, var, r, g, b):
    expected = Color(parse_math(r), parse_math(g), parse_math(b))
    assert getattr(context, var).color == expected


@then(rf"{_V}\.ambient = {_A}")
def step_then_material_ambient(context, var, val):
    assert getattr(context, var).ambient == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.diffuse = {_A}")
def step_then_material_diffuse(context, var, val):
    assert getattr(context, var).diffuse == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.specular = {_A}")
def step_then_material_specular(context, var, val):
    assert getattr(context, var).specular == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.shininess = {_A}")
def step_then_material_shininess(context, var, val):
    assert getattr(context, var).shininess == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.reflective = {_A}")
def step_then_material_reflective(context, var, val):
    assert getattr(context, var).reflective == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.transparency = {_A}")
def step_then_material_transparency(context, var, val):
    assert getattr(context, var).transparency == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.refractive_index = {_A}")
def step_then_material_refractive_index(context, var, val):
    assert getattr(context, var).refractive_index == pytest.approx(parse_math(val), abs=1e-5)
