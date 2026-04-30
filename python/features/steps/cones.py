from behave import given, use_step_matcher

from rayz.cone import Cone

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"


@given(rf"{_V} ← cone\(\)")
def step_given_cone(context, var):
    setattr(context, var, Cone())
