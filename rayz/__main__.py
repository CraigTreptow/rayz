from rayz.datatypes import Toople

def main():
    print("Hello from Rayz!!")
    p = Toople(x=1.1, y=2.2, z=3.3, w=1.0)
    v = Toople(x=1.1, y=2.2, z=3.3, w=0.0)
    print("X: % s" % p.x)
    print(type(p))
    print(p.is_point())
    print(p.is_vector())
    print(v.is_point())
    print(v.is_vector())

if __name__ == "__main__":
    main()
