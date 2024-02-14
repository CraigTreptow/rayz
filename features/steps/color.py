# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
from rayz.color import *

@given('{c} ← color({r}, {g}, {b})')
def step_impl(context, c, r, g, b):
    new_color = Color(red=float(r), green=float(g), blue=float(b))
    match c:
        case "c":
            context.c = new_color
        case "c1":
            context.c1 = new_color
        case "c2":
            context.c2 = new_color
        case "c3":
            context.c3 = new_color

# THEN #######################################################################

@then('c1 + c2 = color({r}, {g}, {b})')
def step_impl(context, r, g, b):
    expected = Color(red=float(r), green=float(g), blue=float(b))
    assert (context.c1 + context.c2 == expected) is True

@then('c1 - c2 = color({r}, {g}, {b})')
def step_impl(context, r, g, b):
    expected = Color(red=float(r), green=float(g), blue=float(b))
    assert (context.c1 - context.c2 == expected) is True

@then('c1 * c2 = color({r}, {g}, {b})')
def step_impl(context, r, g, b):
    expected = Color(red=float(r), green=float(g), blue=float(b))
    assert (context.c1 * context.c2 == expected) is True

@then('c * {s} = color({r}, {g}, {b})')
def step_impl(context, s, r, g, b):
    expected = Color(red=float(r), green=float(g), blue=float(b))
    assert (context.c.scalar_mult(float(s)) == expected) is True
