# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
# import rayz.util as U
from rayz.canvas import *

@given('c ← canvas({width}, {height})')
def step_impl(context, width, height):
    new_canvas = Canvas(width=int(width), height=int(height))
    context.canvas = new_canvas

# THEN #######################################################################

@then('every pixel of c is color(0, 0, 0)')
def step_impl(context):
    for index, row in enumerate(context.canvas.grid):
        assert (row == [Color(red=0, green=0, blue=0) for _ in range(len(row))]) is True

@then('pixel_at(c, {w}, {h}) = red')
def step_impl(context, w, h):
        red = Color(red=1, green=0, blue=0)
        color = context.canvas.pixel_at(int(w), int(h))
        assert (color == red) is True

# WHEN #######################################################################

@when('write_pixel(c, {w}, {h}, red)')
def step_impl(context, w, h):
        red = Color(red=1, green=0, blue=0)
        context.canvas.write_pixel(int(w), int(h), red)

# @then('c1 + c2 = color({r}, {g}, {b})')
# def step_impl(context, r, g, b):
#     expected = Color(red=float(r), green=float(g), blue=float(b))
#     assert (context.c1 + context.c2 == expected) is True
# 
# @then('c1 - c2 = color({r}, {g}, {b})')
# def step_impl(context, r, g, b):
#     expected = Color(red=float(r), green=float(g), blue=float(b))
#     assert (context.c1 - context.c2 == expected) is True
# 
# @then('c1 * c2 = color({r}, {g}, {b})')
# def step_impl(context, r, g, b):
#     expected = Color(red=float(r), green=float(g), blue=float(b))
#     assert (context.c1 * context.c2 == expected) is True
# 
# @then('c * {s} = color({r}, {g}, {b})')
# def step_impl(context, s, r, g, b):
#     expected = Color(red=float(r), green=float(g), blue=float(b))
#     assert (context.c.scalar_mult(float(s)) == expected) is True
# 