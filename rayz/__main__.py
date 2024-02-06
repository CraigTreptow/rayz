from rayz.toople import *
from rayz.point import *
from rayz.vector import *

def main():
    print("Hello from Rayz!!")
    tt = Toople(x=1.1, y=2.2, z=3.3, w=4.4)
    pp = Point(x=1.1, y=2.2, z=3.3)
    vv = Vector(x=1.1, y=2.2, z=3.3)
    print("X: % s" % pp.x)
    print(type(pp))
    print(tt.is_point())
    print(vv.is_vector())
    print(pp.is_point())
    print(pp.is_vector())

if __name__ == "__main__":
    main()
