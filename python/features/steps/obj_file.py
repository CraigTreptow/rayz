import os

import pytest
from behave import given, then, use_step_matcher, when

from rayz.math_parser import parse_math
from rayz.obj_parser import obj_to_group, parse_obj_file
from rayz.tuple import Point, Vector

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"

_FILES_DIR = os.path.join(os.path.dirname(__file__), "..", "files")


@given(rf"{_V} ← a file containing:")
def step_given_file_containing(context, var):
    setattr(context, var, context.text)


@given(rf"{_V} ← the file \"([^\"]+)\"")
def step_given_the_file(context, var, filename):
    path = os.path.join(_FILES_DIR, filename)
    with open(path) as f:
        setattr(context, var, f.read())


@when(rf"{_V} ← parse_obj_file\({_V}\)")
def step_when_parse_obj_file(context, parser_var, file_var):
    setattr(context, parser_var, parse_obj_file(getattr(context, file_var)))


@given(rf"{_V} ← parse_obj_file\({_V}\)")
def step_given_parse_obj_file(context, parser_var, file_var):
    setattr(context, parser_var, parse_obj_file(getattr(context, file_var)))


@then(r"parser should have ignored (\d+) lines")
def step_then_ignored_lines(context, n):
    assert context.parser.ignored_lines == int(n)


@then(rf"{_V}\.vertices\[(\d+)\] = point\({_A},\s*{_A},\s*{_A}\)")
def step_then_vertex(context, var, idx, x, y, z):
    expected = Point(parse_math(x), parse_math(y), parse_math(z))
    assert getattr(context, var).vertices[int(idx)] == expected


@then(rf"{_V}\.normals\[(\d+)\] = vector\({_A},\s*{_A},\s*{_A}\)")
def step_then_normal(context, var, idx, x, y, z):
    expected = Vector(parse_math(x), parse_math(y), parse_math(z))
    actual = getattr(context, var).normals[int(idx)]
    assert actual.x == pytest.approx(expected.x, abs=1e-4)
    assert actual.y == pytest.approx(expected.y, abs=1e-4)
    assert actual.z == pytest.approx(expected.z, abs=1e-4)


@when(rf"{_V} ← {_V}\.default_group")
def step_when_default_group(context, var, parser_var):
    setattr(context, var, getattr(context, parser_var).default_group)


@when(rf"{_V} ← first child of {_V}")
def step_when_first_child(context, var, group_var):
    setattr(context, var, getattr(context, group_var).children[0])


@when(rf"{_V} ← second child of {_V}")
def step_when_second_child(context, var, group_var):
    setattr(context, var, getattr(context, group_var).children[1])


@when(rf"{_V} ← third child of {_V}")
def step_when_third_child(context, var, group_var):
    setattr(context, var, getattr(context, group_var).children[2])


@then(rf"{_V}\.p1 = {_V}\.vertices\[(\d+)\]")
def step_then_tri_p1_vertex(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).p1 is getattr(context, parser_var).vertices[int(idx)]


@then(rf"{_V}\.p2 = {_V}\.vertices\[(\d+)\]")
def step_then_tri_p2_vertex(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).p2 is getattr(context, parser_var).vertices[int(idx)]


@then(rf"{_V}\.p3 = {_V}\.vertices\[(\d+)\]")
def step_then_tri_p3_vertex(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).p3 is getattr(context, parser_var).vertices[int(idx)]


@then(rf"{_V}\.n1 = {_V}\.normals\[(\d+)\]")
def step_then_tri_n1_normal(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).n1 is getattr(context, parser_var).normals[int(idx)]


@then(rf"{_V}\.n2 = {_V}\.normals\[(\d+)\]")
def step_then_tri_n2_normal(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).n2 is getattr(context, parser_var).normals[int(idx)]


@then(rf"{_V}\.n3 = {_V}\.normals\[(\d+)\]")
def step_then_tri_n3_normal(context, tri_var, parser_var, idx):
    assert getattr(context, tri_var).n3 is getattr(context, parser_var).normals[int(idx)]


@when(rf"{_V} ← \"([^\"]+)\" from {_V}")
def step_when_named_group(context, var, name, parser_var):
    setattr(context, var, getattr(context, parser_var).group(name))


@when(rf"{_V} ← obj_to_group\({_V}\)")
def step_when_obj_to_group(context, var, parser_var):
    setattr(context, var, obj_to_group(getattr(context, parser_var)))


@then(rf"{_V} includes \"([^\"]+)\" from {_V}")
def step_then_group_includes(context, group_var, name, parser_var):
    named = getattr(context, parser_var).group(name)
    group = getattr(context, group_var)
    assert named in group.children


@then(rf"{_V} = {_V}")
def step_then_vars_equal(context, a, b):
    assert getattr(context, a) == getattr(context, b)
