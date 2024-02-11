from rayz.chapter1 import *

from rayz.canvas import *
from rayz.color import *

def main():
    # Chapter1.run()
    canvas = Canvas(width=10, height=20)
    red = Color(red=1, green=0, blue=0)
    canvas.write_pixel(row=2, column=3, color=red)
    print(canvas)

if __name__ == "__main__":
    main()
