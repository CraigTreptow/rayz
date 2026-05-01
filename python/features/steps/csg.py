from behave import given, then, use_step_matcher, when

from rayz.csg import CSG, filter_intersections, intersection_allowed
from rayz.cube import Cube
from rayz.sphere import Sphere

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_A = r"([^\s,)]+)"
_SHAPE = r"(sphere\(\)|cube\(\)|[A-Za-z][A-Za-z0-9_]*)"


def _resolve_shape(context, spec: str):
    if spec == "sphere()":
        return Sphere()
    if spec == "cube()":
        return Cube()
    return getattr(context, spec)


@given(rf"{_V} ← csg\(\"([^\"]+)\",\s*{_SHAPE},\s*{_SHAPE}\)")
def step_given_csg(context, var, op, left, right):
    setattr(context, var, CSG(op, _resolve_shape(context, left), _resolve_shape(context, right)))


@when(rf"{_V} ← csg\(\"([^\"]+)\",\s*{_SHAPE},\s*{_SHAPE}\)")
def step_when_csg(context, var, op, left, right):
    setattr(context, var, CSG(op, _resolve_shape(context, left), _resolve_shape(context, right)))


@then(rf"{_V}\.operation = \"([^\"]+)\"")
def step_then_csg_operation(context, var, op):
    assert getattr(context, var).operation == op


@then(rf"{_V}\.left = {_V}")
def step_then_csg_left(context, csg_var, shape_var):
    assert getattr(context, csg_var).left is getattr(context, shape_var)


@then(rf"{_V}\.right = {_V}")
def step_then_csg_right(context, csg_var, shape_var):
    assert getattr(context, csg_var).right is getattr(context, shape_var)


@then(rf"{_V}\.parent = {_V}")
def step_then_shape_parent(context, shape_var, parent_var):
    assert getattr(context, shape_var).parent is getattr(context, parent_var)


@when(r"result ← intersection_allowed\(\"([^\"]+)\",\s*(true|false),\s*(true|false),\s*(true|false)\)")
def step_when_intersection_allowed(context, op, lhit, inl, inr):
    context.result = intersection_allowed(op, lhit == "true", inl == "true", inr == "true")


@then(r"result = (true|false)")
def step_then_result_bool(context, val):
    assert context.result is (val == "true")


@when(rf"result ← filter_intersections\({_V},\s*{_V}\)")
def step_when_filter_intersections(context, csg_var, xs_var):
    context.result = filter_intersections(getattr(context, csg_var), getattr(context, xs_var))


@then(r"result\.count = (\d+)")
def step_then_result_count(context, n):
    assert len(context.result) == int(n)


@then(rf"result\[(\d+)\] = {_V}\[(\d+)\]")
def step_then_result_item(context, ri, xs_var, xi):
    assert context.result[int(ri)] is getattr(context, xs_var)[int(xi)]
