from behave import given, then, use_step_matcher, when

from rayz.canvas import Canvas
from rayz.color import Color
from rayz.math_parser import parse_math

use_step_matcher("re")

_A = r"([^\s,)]+)"


@given(r"canvas ← canvas\((\d+),\s*(\d+)\)")
def step_given_canvas(context, w, h):
    context.canvas = Canvas(int(w), int(h))


@then(r"canvas\.width = (\d+)")
def step_then_canvas_width(context, n):
    assert context.canvas.width == int(n)


@then(r"canvas\.height = (\d+)")
def step_then_canvas_height(context, n):
    assert context.canvas.height == int(n)


@then(rf"every pixel of canvas is color\({_A},\s*{_A},\s*{_A}\)")
def step_then_every_pixel(context, r, g, b):
    expected = Color(parse_math(r), parse_math(g), parse_math(b))
    for row in range(context.canvas.height):
        for col in range(context.canvas.width):
            assert context.canvas.pixel_at(col=col, row=row) == expected


@given(rf"red ← color\({_A},\s*{_A},\s*{_A}\)")
def step_given_red(context, r, g, b):
    context.red = Color(parse_math(r), parse_math(g), parse_math(b))


@given(rf"color(\d+) ← color\({_A},\s*{_A},\s*{_A}\)")
def step_given_colorN(context, n, r, g, b):
    setattr(context, f"color{n}", Color(parse_math(r), parse_math(g), parse_math(b)))


@when(r"write_pixel\(canvas,\s*(\d+),\s*(\d+),\s*(red|color\d+)\)")
def step_when_write_pixel(context, col, row, color_var):
    context.canvas.write_pixel(col=int(col), row=int(row), color=getattr(context, color_var))


@then(r"pixel_at\(canvas,\s*(\d+),\s*(\d+)\) = (red|color\d+)")
def step_then_pixel_at(context, col, row, color_var):
    assert context.canvas.pixel_at(col=int(col), row=int(row)) == getattr(context, color_var)


@when(r"ppm ← canvas_to_ppm\(canvas\)")
def step_when_canvas_to_ppm(context):
    context.ppm = context.canvas.to_ppm()


@then("lines 1-3 of ppm are")
def step_then_ppm_header(context):
    ppm_lines = context.ppm.split("\n")[:3]
    doc_lines = context.text.split("\n")
    for i, expected_line in enumerate(doc_lines):
        assert ppm_lines[i] == expected_line, f"Line {i + 1}: {ppm_lines[i]!r} != {expected_line!r}"


@then("lines 4-6 of ppm are")
def step_then_ppm_body(context):
    ppm_lines = context.ppm.split("\n")[3:6]
    doc_lines = context.text.split("\n")
    for i, expected_line in enumerate(doc_lines):
        assert ppm_lines[i] == expected_line, f"Line {i + 4}: {ppm_lines[i]!r} != {expected_line!r}"


@then("ppm ends with a newline character")
def step_then_ppm_ends_newline(context):
    assert context.ppm.endswith("\n")
