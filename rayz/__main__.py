from rayz.chapter1 import *
from rayz.chapter2 import *

from rayz.canvas import *
from rayz.color import *

def main():
    # Chapter1.run()
    Chapter2.run()
    ### red = Color(red=1, green=0, blue=0)
    ### green = Color(red=0, green=1, blue=0)
    ### blue = Color(red=0, green=0, blue=1)

    ### canvas = Canvas(width=5, height=3)
    ### canvas.write_pixel(x=0, y=0, color=red)
    ### canvas.write_pixel(x=2, y=1, color=green)
    ### canvas.write_pixel(x=4, y=2, color=blue)
    ### print(f" width: {canvas.width}")
    ### print(f"height: {canvas.height}")
    ### print("\n")
    ### print(canvas)
    # print(canvas.to_ppm())

    # canvas = Canvas(width=10, height=20)
    # canvas.write_pixel(x=2, y=3, color=red)
    # print(canvas.pixel_at(x=2, y=3))
    # print(canvas)

if __name__ == "__main__":
    main()
