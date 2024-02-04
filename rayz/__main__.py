import rayz.tuple_util as TU

def main():
    print("Hello from Rayz!!")
    p = TU.new_point(x=1.1, y=2.2, z=3.3)
    v = TU.new_vector(x=1.1, y=2.2, z=3.3)
    print("X: % s" % p[0])
    print(type(p))
    print(TU.is_point(p))
    print(TU.is_vector(p))
    print(TU.is_point(v))
    print(TU.is_vector(v))

if __name__ == "__main__":
    main()
