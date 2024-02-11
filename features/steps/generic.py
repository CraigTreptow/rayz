# type: ignore
from behave import *

# from pprint import pprint
# if output is needed, add `print("\n\n")` at the end
import rayz.util as U
from rayz.color import *
from rayz.canvas import *

@then('c.{attribute} = {x}')
def step_impl(context, attribute, x):
    match attribute:
        case "red":
            assert U.equal(context.c.red, float(x)) is True
        case "green":
            assert U.equal(context.c.green, float(x)) is True
        case "blue":
            assert U.equal(context.c.blue, float(x)) is True
        case "width":
            assert (context.canvas.width == int(x)) is True
        case "height":
            assert (context.canvas.height == int(x)) is True
