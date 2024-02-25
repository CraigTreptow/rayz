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

@then('lines 1-3 of ppm are')
def step_impl(context):
    lines = context.ppm.split("\n")
    assert (lines[0] == "P3") is True
    assert (lines[1] == "5 3") is True
    assert (lines[2] == "255") is True

@then('lines 4-6 of ppm are')
def step_impl(context):
    lines = context.ppm.split("\n")
    assert (lines[3] == "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0") is True
    assert (lines[4] == "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0") is True
    assert (lines[5] == "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255") is True

@then('ppm ends with a newline character')
def step_impl(context):
    assert (context.ppm.endswith("\n")) is True

# @then(u'lines 4-7 of ppm are')
# def step_impl(context):
#     lines = context.ppm.split("\n")
#     assert (lines[3] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204") is True
#     assert (lines[4] == "153 255 204 153 255 204 153 255 204 153 255 204 153") is True
#     assert (lines[5] == "255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204") is True
#     assert (lines[6] == "153 255 204 153 255 204 153 255 204 153 255 204 153") is True

# WHEN #######################################################################

@when('write_pixel(c, {w}, {h}, {color})')
def step_impl(context, w, h, color):
    match color:
        case 'red':
            red = Color(red=1, green=0, blue=0)
            context.canvas.write_pixel(int(w), int(h), red)
        case 'c1':
            context.canvas.write_pixel(int(w), int(h), context.c1)
        case 'c2':
            context.canvas.write_pixel(int(w), int(h), context.c2)
        case 'c3':
            context.canvas.write_pixel(int(w), int(h), context.c3)

@when('ppm ← canvas_to_ppm(c)')
def step_impl(context):
    context.ppm = context.canvas.to_ppm()

@when('every pixel of c is set to color({r}, {g}, {b})')
def step_impl(context, r, g, b):
    for index, row in enumerate(context.canvas.grid):
        assert (row == [Color(red=float(r), green=float(g), blue=float(b)) for _ in range(len(row))]) is True