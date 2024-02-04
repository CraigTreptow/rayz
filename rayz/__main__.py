import rayz.util as U

def main():
    print("Hello from Rayz!!")
    p = U.new_point(x=1.1, y=2.2, z=3.3)
    v = U.new_vector(x=1.1, y=2.2, z=3.3)
    print("X: % s" % p['x'])
    print(type(p))
    print(U.is_point(p))
    print(U.is_vector(p))
    print(U.is_point(v))
    print(U.is_vector(v))

if __name__ == "__main__":
    main()
