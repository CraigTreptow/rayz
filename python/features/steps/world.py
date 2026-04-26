from behave import given, then, use_step_matcher, when

from rayz.color import Color
from rayz.intersection import Intersection, prepare_computations
from rayz.math_parser import parse_math
from rayz.point_light import PointLight
from rayz.sphere import Sphere
from rayz.transformations import scaling, translation
from rayz.tuple import Point
from rayz.world import World, default_world

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

_TRANSFORM_MAP = {"scaling": scaling, "translation": translation}


def _apply_table(obj, table):
    import re

    # behave treats the first table row as column headers; include it as data
    all_rows = [(table.headings[0], table.headings[1])] + [(row[0], row[1]) for row in table]
    for prop, raw in all_rows:
        prop, raw = prop.strip(), raw.strip()
        if prop == "transform":
            m = re.fullmatch(r"(scaling|translation)\((.+)\)", raw)
            func = _TRANSFORM_MAP[m.group(1)]
            args = [parse_math(a.strip()) for a in m.group(2).split(",")]
            obj.set_transform(func(*args))
        elif prop == "material.color":
            m = re.fullmatch(r"\((.+),\s*(.+),\s*(.+)\)", raw)
            obj.material.color = Color(parse_math(m.group(1)), parse_math(m.group(2)), parse_math(m.group(3)))
        elif prop == "material.diffuse":
            obj.material.diffuse = parse_math(raw)
        elif prop == "material.specular":
            obj.material.specular = parse_math(raw)
        elif prop == "material.ambient":
            obj.material.ambient = parse_math(raw)
        elif prop == "material.reflective":
            obj.material.reflective = parse_math(raw)
        elif prop == "material.transparency":
            obj.material.transparency = parse_math(raw)
        elif prop == "material.refractive_index":
            obj.material.refractive_index = parse_math(raw)


# ---------------------------------------------------------------------------
# Given
# ---------------------------------------------------------------------------


@given(rf"{_V} ← world\(\)")
def step_given_world(context, var):
    setattr(context, var, World())


@given(rf"{_V} ← sphere\(\) with:")
def step_given_sphere_with_table(context, var):
    s = Sphere()
    _apply_table(s, context.table)
    setattr(context, var, s)


@given(rf"{_V} is added to {_V}")
def step_given_shape_added_to_world(context, shape_var, world_var):
    getattr(context, world_var).objects.append(getattr(context, shape_var))


@given(rf"{_V}\.light ← point_light\(point\({_A},\s*{_A},\s*{_A}\),\s*color\({_A},\s*{_A},\s*{_A}\)\)")
def step_given_world_light(context, world_var, px, py, pz, ir, ig, ib):
    getattr(context, world_var).light = PointLight(
        Point(parse_math(px), parse_math(py), parse_math(pz)),
        Color(parse_math(ir), parse_math(ig), parse_math(ib)),
    )


@given(rf"{_V} ← the first object in {_V}")
def step_given_first_object(context, var, world_var):
    setattr(context, var, getattr(context, world_var).objects[0])


@given(rf"{_V} ← the second object in {_V}")
def step_given_second_object(context, var, world_var):
    setattr(context, var, getattr(context, world_var).objects[1])


@given(rf"{_V}\.material\.ambient ← {_A}")
def step_given_shape_ambient(context, var, val):
    getattr(context, var).material.ambient = parse_math(val)


@given(rf"{_V} ← intersection\({_A},\s*{_V}\)")
def step_given_intersection(context, var, t_val, obj_var):
    setattr(context, var, Intersection(parse_math(t_val), getattr(context, obj_var)))


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@given(rf"{_V} ← default_world\(\)")
def step_given_default_world(context, var):
    setattr(context, var, default_world())


@when(rf"{_V} ← default_world\(\)")
def step_when_default_world(context, var):
    setattr(context, var, default_world())


@when(rf"xs ← intersect_world\({_V},\s*{_V}\)")
def step_when_intersect_world(context, world_var, ray_var):
    context.xs = getattr(context, world_var).intersect_world(getattr(context, ray_var))


@when(rf"comps ← prepare_computations\({_V},\s*{_V}\)")
def step_when_prepare_computations(context, i_var, ray_var):
    context.comps = prepare_computations(getattr(context, i_var), getattr(context, ray_var))


@when(rf"c ← shade_hit\({_V},\s*comps\)")
def step_when_shade_hit(context, world_var):
    context.c = getattr(context, world_var).shade_hit(context.comps)


@when(rf"c ← color_at\({_V},\s*{_V}\)")
def step_when_color_at(context, world_var, ray_var):
    context.c = getattr(context, world_var).color_at(getattr(context, ray_var))


@when(rf"color ← reflected_color\({_V},\s*comps\)")
def step_when_reflected_color(context, world_var):
    context.color = getattr(context, world_var).reflected_color(context.comps)


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(r"w contains no objects")
def step_then_no_objects(context):
    assert context.w.objects == []


@then(r"w has no light source")
def step_then_no_light(context):
    assert context.w.light is None


@then(rf"{_V}\.light = {_V}")
def step_then_world_light(context, world_var, light_var):
    assert getattr(context, world_var).light == getattr(context, light_var)


@then(rf"{_V} contains {_V}")
def step_then_world_contains(context, world_var, shape_var):
    world = getattr(context, world_var)
    shape = getattr(context, shape_var)
    assert any(obj.transform == shape.transform and obj.material == shape.material for obj in world.objects)


@then(rf"is_shadowed\({_V},\s*{_V}\) is (true|false)")
def step_then_is_shadowed(context, world_var, point_var, expected):
    result = getattr(context, world_var).is_shadowed(getattr(context, point_var))
    assert result == (expected == "true")


@then(rf"c = {_V}\.material\.color")
def step_then_c_eq_material_color(context, shape_var):
    assert context.c == getattr(context, shape_var).material.color


@then(rf"color = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_color_eq(context, r, g, b):
    expected = Color(parse_math(r), parse_math(g), parse_math(b))
    assert context.color == expected, f"{context.color!r} != {expected!r}"
