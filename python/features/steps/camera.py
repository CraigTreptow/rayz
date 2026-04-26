import pytest
from behave import given, then, use_step_matcher, when

from rayz.camera import Camera
from rayz.color import Color
from rayz.math_parser import parse_math
from rayz.matrix import Matrix
from rayz.transformations import rotation_y, translation, view_transform

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

IDENTITY_MATRIX = Matrix.identity(4)


def _val(context, s):
    """Return numeric value: look up as context attribute if it's a plain name."""
    if hasattr(context, s):
        return getattr(context, s)
    return parse_math(s)


def _make_camera(context, var, h, v, fov):
    setattr(context, var, Camera(int(_val(context, h)), int(_val(context, v)), _val(context, fov)))


# ---------------------------------------------------------------------------
# Given
# ---------------------------------------------------------------------------


@given(rf"hsize ← {_A}")
def step_given_hsize(context, val):
    context.hsize = int(parse_math(val))


@given(rf"vsize ← {_A}")
def step_given_vsize(context, val):
    context.vsize = int(parse_math(val))


@given(rf"field_of_view ← {_A}")
def step_given_fov(context, val):
    context.field_of_view = parse_math(val)


@given(rf"{_V} ← camera\({_A},\s*{_A},\s*{_A}\)")
def step_given_camera(context, var, h, v, fov):
    _make_camera(context, var, h, v, fov)


@given(rf"{_V}\.transform ← view_transform\({_V},\s*{_V},\s*{_V}\)")
def step_given_camera_view_transform(context, cam_var, from_var, to_var, up_var):
    getattr(context, cam_var).transform = view_transform(
        getattr(context, from_var),
        getattr(context, to_var),
        getattr(context, up_var),
    )


# ---------------------------------------------------------------------------
# When
# ---------------------------------------------------------------------------


@when(rf"{_V} ← camera\({_A},\s*{_A},\s*{_A}\)")
def step_when_camera(context, var, h, v, fov):
    _make_camera(context, var, h, v, fov)


@when(rf"{_V}\.transform ← rotation_y\({_A}\) \* translation\({_A},\s*{_A},\s*{_A}\)")
def step_when_camera_transform(context, var, ry_val, tx, ty, tz):
    t = rotation_y(parse_math(ry_val)) * translation(parse_math(tx), parse_math(ty), parse_math(tz))
    getattr(context, var).transform = t


@when(rf"r ← ray_for_pixel\({_V},\s*{_A},\s*{_A}\)")
def step_when_ray_for_pixel(context, cam_var, px, py):
    context.r = getattr(context, cam_var).ray_for_pixel(int(parse_math(px)), int(parse_math(py)))


@when(rf"image ← render\({_V},\s*{_V}\)")
def step_when_render(context, cam_var, world_var):
    context.image = getattr(context, cam_var).render(getattr(context, world_var))


# ---------------------------------------------------------------------------
# Then
# ---------------------------------------------------------------------------


@then(rf"{_V}\.hsize = {_A}")
def step_then_hsize(context, var, val):
    assert getattr(context, var).hsize == int(parse_math(val))


@then(rf"{_V}\.vsize = {_A}")
def step_then_vsize(context, var, val):
    assert getattr(context, var).vsize == int(parse_math(val))


@then(rf"{_V}\.field_of_view = {_A}")
def step_then_fov(context, var, val):
    assert getattr(context, var).field_of_view == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"{_V}\.transform = identity_matrix")
def step_then_camera_transform_identity(context, var):
    assert getattr(context, var).transform == IDENTITY_MATRIX


@then(rf"{_V}\.pixel_size = {_A}")
def step_then_pixel_size(context, var, val):
    assert getattr(context, var).pixel_size == pytest.approx(parse_math(val), abs=1e-4)


@then(rf"pixel_at\(image,\s*{_A},\s*{_A}\) = color\({_A},\s*{_A},\s*{_A}\)")
def step_then_pixel_at(context, px, py, cr, cg, cb):
    pixel = context.image.pixel_at(col=int(parse_math(px)), row=int(parse_math(py)))
    expected = Color(parse_math(cr), parse_math(cg), parse_math(cb))
    assert pixel == expected, f"{pixel!r} != {expected!r}"
