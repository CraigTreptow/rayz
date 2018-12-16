defmodule Rayz.TupleTest do
  use ExUnit.Case
  doctest Rayz.Tuple

  test "can calculate cross product of two vectors" do
    v1 = Rayz.Tuple.new_vector(1, 2, 3)
    v2 = Rayz.Tuple.new_vector(2, 3, 4)

    assert Rayz.Tuple.cross_product(v1, v2) == Rayz.Tuple.new_vector(-1, 2, -1)
    assert Rayz.Tuple.cross_product(v2, v1) == Rayz.Tuple.new_vector(1, -2, 1)
  end

  test "can calculate dot product of two vectors" do
    v1 = Rayz.Tuple.new_vector(1, 2, 3)
    v2 = Rayz.Tuple.new_vector(2, 3, 4)

    x = Rayz.Tuple.dot_product(v1, v2)

    assert x == 20
  end

  test "normalize a vector with only x" do
    v = Rayz.Tuple.new_vector(4, 0, 0)

    x = Rayz.Tuple.normalize(v)

    normalized_vector = Rayz.Tuple.new_vector(1, 0, 0)
    assert x == normalized_vector
  end

  test "normalize a vector(1, 2, 3)" do
    v = Rayz.Tuple.new_vector(1, 2, 3)

    x = Rayz.Tuple.normalize(v)

    #                                              1/sqrt(14), 2/sqrt(14), 3/sqrt(14)
    assert Rayz.Tuple.equal?(x, Rayz.Tuple.new_vector(0.26726, 0.53452, 0.80178))
  end

  test "magnitued of normalized vector is 1" do
    v = Rayz.Tuple.new_vector(1, 2, 3)

    x =
      v
      |> Rayz.Tuple.normalize()
      |> Rayz.Tuple.magnitude()

    assert x == 1
  end

  test "magnitude of vector with only x" do
    v = Rayz.Tuple.new_vector(1, 0, 0)

    x = Rayz.Tuple.magnitude(v)

    assert x == 1
  end

  test "magnitude of vector with only y" do
    v = Rayz.Tuple.new_vector(0, 1, 0)

    x = Rayz.Tuple.magnitude(v)

    assert x == 1
  end

  test "magnitude of vector with only z" do
    v = Rayz.Tuple.new_vector(0, 0, 1)

    x = Rayz.Tuple.magnitude(v)

    assert x == 1
  end

  test "magnitude of vector(1, 2, 3)" do
    v = Rayz.Tuple.new_vector(1, 2, 3)

    x = Rayz.Tuple.magnitude(v)

    assert x == :math.sqrt(14)
  end

  test "magnitude of vector(-1, -2, -3)" do
    v = Rayz.Tuple.new_vector(-1, -2, -3)

    x = Rayz.Tuple.magnitude(v)

    assert x == :math.sqrt(14)
  end

  test "can be divided by a scalar" do
    t = %Rayz.Tuple{x: 1, y: -2, z: 3, w: -4}

    x = Rayz.Tuple.divide(t, 2)

    assert x == %Rayz.Tuple{x: 0.5, y: -1.0, z: 1.5, w: -2}
  end

  test "can be multiplied by a scalar" do
    t = %Rayz.Tuple{x: 1.0, y: -2.0, z: 3.0, w: -4.0}

    x = Rayz.Tuple.multiply(t, 3.5)

    assert x == %Rayz.Tuple{x: 3.5, y: -7.0, z: 10.5, w: -14}
  end

  test "can be multiplied by a fraction" do
    t = %Rayz.Tuple{x: 1, y: -2, z: 3, w: -4}

    x = Rayz.Tuple.multiply(t, 0.5)

    assert x == %Rayz.Tuple{x: 0.5, y: -1.0, z: 1.5, w: -2}
  end

  test "can negate a vector" do
    v = Rayz.Tuple.new_vector(4.0, 3.0, 2.0)

    x = Rayz.Tuple.negate(v)

    assert x == %Rayz.Tuple{x: -4.0, y: -3.0, z: -2.0, w: 0.0}
    assert Rayz.Tuple.vector?(x) == true
    assert Rayz.Tuple.point?(x) == false
  end

  test "can subtract two points gives a vector" do
    p1 = Rayz.Tuple.new_point(4.0, 3.0, 2.0)
    p2 = Rayz.Tuple.new_point(1.0, 1.0, 1.0)

    x = Rayz.Tuple.subtract(p1, p2)

    assert x == %Rayz.Tuple{x: 3.0, y: 2.0, z: 1.0, w: 0.0}
    assert Rayz.Tuple.vector?(x) == true
    assert Rayz.Tuple.point?(x) == false
  end

  test "can subtract a vector from a point gives a point" do
    p = Rayz.Tuple.new_point(4.0, 3.0, 2.0)
    v = Rayz.Tuple.new_vector(1.0, 1.0, 1.0)

    x = Rayz.Tuple.subtract(p, v)

    assert x == %Rayz.Tuple{x: 3.0, y: 2.0, z: 1.0, w: 1.0}
    assert Rayz.Tuple.vector?(x) == false
    assert Rayz.Tuple.point?(x) == true
  end

  test "can subtract two vectors gives a vector" do
    v1 = Rayz.Tuple.new_vector(4.0, 3.0, 2.0)
    v2 = Rayz.Tuple.new_vector(1.0, 1.0, 1.0)

    x = Rayz.Tuple.subtract(v1, v2)

    assert x == %Rayz.Tuple{x: 3.0, y: 2.0, z: 1.0, w: 0.0}
    assert Rayz.Tuple.vector?(x) == true
    assert Rayz.Tuple.point?(x) == false
  end

  test "can add two points" do
    p1 = Rayz.Tuple.new_point(1.0, 2.0, 3.0)
    p2 = Rayz.Tuple.new_point(1.0, 2.0, 3.0)

    x = Rayz.Tuple.add(p1, p2)

    assert x == %Rayz.Tuple{x: 2.0, y: 4.0, z: 6.0, w: 2.0}
    assert Rayz.Tuple.vector?(x) == false
    assert Rayz.Tuple.point?(x) == false
  end

  test "can add two vectors" do
    v1 = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)
    v2 = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)

    x = Rayz.Tuple.add(v1, v2)

    assert x == %Rayz.Tuple{x: 2.0, y: 4.0, z: 6.0, w: 0.0}
    assert Rayz.Tuple.vector?(x) == true
    assert Rayz.Tuple.point?(x) == false
  end

  test "can add a point and a vector" do
    p = Rayz.Tuple.new_point(1.0, 2.0, 3.0)
    v = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)

    x = Rayz.Tuple.add(p, v)

    assert x == %Rayz.Tuple{x: 2.0, y: 4.0, z: 6.0, w: 1.0}
    assert Rayz.Tuple.vector?(x) == false
    assert Rayz.Tuple.point?(x) == true
  end

  test "can detect points" do
    p = Rayz.Tuple.new_point(1.0, 2.0, 3.0)

    assert Rayz.Tuple.point?(p) == true
    assert Rayz.Tuple.vector?(p) == false
  end

  test "can detect vectors" do
    v = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)

    assert Rayz.Tuple.point?(v) == false
    assert Rayz.Tuple.vector?(v) == true
  end

  test "the same point is equal to itself" do
    p = Rayz.Tuple.new_point(1.0, 2.0, 3.0)

    assert Rayz.Tuple.equal?(p, p) == true
  end

  test "two different points are different" do
    p1 = Rayz.Tuple.new_point(1.0, 2.0, 3.0)
    p2 = Rayz.Tuple.new_point(4.0, 5.0, 6.0)

    assert Rayz.Tuple.equal?(p1, p2) == false
  end

  test "the same vector is equal to itself" do
    v = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)

    assert Rayz.Tuple.equal?(v, v) == true
  end

  test "two different vectors are different" do
    v1 = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)
    v2 = Rayz.Tuple.new_vector(4.0, 5.0, 6.0)

    assert Rayz.Tuple.equal?(v1, v2) == false
  end

  test "vector is different than point" do
    v = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)
    p = Rayz.Tuple.new_point(1.0, 2.0, 3.0)

    assert Rayz.Tuple.equal?(v, p) == false
  end

  test "creates a point" do
    assert Rayz.Tuple.new_point(1.0, 2.0, 3.0) == %Rayz.Tuple{w: 1.0, x: 1.0, y: 2.0, z: 3.0}
  end

  test "saves the coordinates of a point" do
    p = Rayz.Tuple.new_point(1.0, 2.0, 3.0)
    assert p.x == 1.0
    assert p.y == 2.0
    assert p.z == 3.0
  end

  test "works with negative coordinates of a point" do
    p = Rayz.Tuple.new_point(-1.0, -2.0, -3.0)
    assert p.x == -1.0
    assert p.y == -2.0
    assert p.z == -3.0
  end

  test "creates a vector" do
    assert Rayz.Tuple.new_vector(1, 2, 3) == %Rayz.Tuple{w: 0.0, x: 1.0, y: 2.0, z: 3.0}
  end

  test "saves the coordinates of a vector" do
    v = Rayz.Tuple.new_vector(1.0, 2.0, 3.0)
    assert v.x == 1.0
    assert v.y == 2.0
    assert v.z == 3.0
  end

  test "works with negative coordinates of a vector" do
    v = Rayz.Tuple.new_vector(-1.0, -2.0, -3.0)
    assert v.x == -1.0
    assert v.y == -2.0
    assert v.z == -3.0
  end
end
