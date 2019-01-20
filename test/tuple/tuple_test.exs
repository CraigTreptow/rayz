defmodule RayzTupleTest do
  use ExUnit.Case
  doctest Rayz.Tuple

  describe "Rayz.Tuple.negate/1" do
    test "Negating a tuple" do
      a = Builder.tuple(1, -2, 3, -4)

      na = Rayz.Tuple.negate(a)

      expected_tuple = Builder.tuple(-1, 2, -3, 4)

      assert Rayz.Tuple.equal?(na, expected_tuple) == true
    end
  end

  describe "Rayz.Tuple.subtract/2" do
    test "Subtracting two points" do
      p1 = Builder.point(3, 2, 1)
      p2 = Builder.point(5, 6, 7)

      v = Rayz.Tuple.subtract(p1, p2)

      expected_vector = Builder.vector(-2, -4, -6)

      assert Rayz.Tuple.is_vector?(v) == true
      assert Rayz.Tuple.equal?(v, expected_vector) == true
    end

    test "Subtracting a vector from a point" do
      p = Builder.point(3, 2, 1)
      v = Builder.vector(5, 6, 7)

      p = Rayz.Tuple.subtract(p, v)
      expected_point = Builder.point(-2, -4, -6)

      assert Rayz.Tuple.is_point?(p) == true
      assert Rayz.Tuple.equal?(p, expected_point) == true
    end

    test "Subtracting two vectors" do 
      v1 = Builder.vector(3, 2, 1)
      v2 = Builder.vector(5, 6, 7)

      v = Rayz.Tuple.subtract(v1, v2)
      expected_vector = Builder.vector(-2, -4, -6)

      assert Rayz.Tuple.is_vector?(v) == true
      assert Rayz.Tuple.equal?(v, expected_vector) == true
    end

    test "Subtracting a vector from the zero vector" do
      v0 = Builder.vector(0, 0, 0)
      v1 = Builder.vector(1, -2, 3)

      v = Rayz.Tuple.subtract(v0, v1)
      expected_vector = Builder.vector(-1, 2, -3)

      assert Rayz.Tuple.is_vector?(v) == true
      assert Rayz.Tuple.equal?(v, expected_vector) == true
    end
  end

  describe "Rayz.Tuple.add/2" do
    test "adding two tuples" do
      a1 = Builder.tuple(3, -2, 5, 1)
      a2 = Builder.tuple(-2, 3, 1, 0)

      a3 = Rayz.Tuple.add(a1, a2)

      expected_tuple = Builder.tuple(1, 1, 6, 1)

      assert Rayz.Tuple.equal?(a3, expected_tuple) == true
    end
  end

  describe "Rayz.Tuple.equal?/2" do
    test "the same point is equal to itself" do
      p = Builder.point(1.0, 2.0, 3.0)

      assert Rayz.Tuple.equal?(p, p) == true
    end

    test "two different points are different" do
      p1 = Builder.point(1.0, 2.0, 3.0)
      p2 = Builder.point(4.0, 5.0, 6.0)

      assert Rayz.Tuple.equal?(p1, p2) == false
    end

    test "the same vector is equal to itself" do
      v = Builder.vector(1.0, 2.0, 3.0)

      assert Rayz.Tuple.equal?(v, v) == true
    end

    test "two different vectors are different" do
      v1 = Builder.vector(1.0, 2.0, 3.0)
      v2 = Builder.vector(4.0, 5.0, 6.0)

      assert Rayz.Tuple.equal?(v1, v2) == false
    end

    test "vector is different than point" do
      v = Builder.vector(1.0, 2.0, 3.0)
      p = Builder.point(1.0, 2.0, 3.0)

      assert Rayz.Tuple.equal?(v, p) == false
    end
  end

  describe "Tuple" do
    test "A tuple with w=1.0 is a point" do
      a = Builder.tuple(4.3, -4.2, 3.1, 1.0)

      assert a.x ==  4.3
      assert a.y == -4.2
      assert a.z ==  3.1
      assert a.w ==  1.0

      assert Rayz.Tuple.is_point?(a) == true
      assert Rayz.Tuple.is_vector?(a) == false
    end

    test "A tuple with w=0 is a vector" do
      a = Builder.tuple(4.3, -4.2, 3.1, 0.0)

      assert a.x ==  4.3
      assert a.y == -4.2
      assert a.z ==  3.1
      assert a.w ==  0

      assert Rayz.Tuple.is_point?(a) == false
      assert Rayz.Tuple.is_vector?(a) == true
    end
  end
end
