from behave import given, then, use_step_matcher, when

from rayz.point_light import PointLight

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"


def _make_point_light(context, var, pos_var, int_var):
    setattr(context, var, PointLight(getattr(context, pos_var), getattr(context, int_var)))


@given(rf"{_V} ← point_light\({_V},\s*{_V}\)")
def step_given_point_light_vars(context, var, pos_var, int_var):
    _make_point_light(context, var, pos_var, int_var)


@when(rf"{_V} ← point_light\({_V},\s*{_V}\)")
def step_when_point_light_vars(context, var, pos_var, int_var):
    _make_point_light(context, var, pos_var, int_var)


@then(rf"{_V}\.position = {_V}")
def step_then_light_position(context, light_var, pos_var):
    assert getattr(context, light_var).position == getattr(context, pos_var)


@then(rf"{_V}\.intensity = {_V}")
def step_then_light_intensity(context, light_var, int_var):
    assert getattr(context, light_var).intensity == getattr(context, int_var)
