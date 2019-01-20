defmodule RayzTupleTest do
  use ExUnit.Case
  doctest Rayz.Tuple

  describe "Rayz.Tuple.equal?/1" do
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
      a = Builder.tuple(4.3, -4.2, 3.1, 0)

      assert a.x ==  4.3
      assert a.y == -4.2
      assert a.z ==  3.1
      assert a.w ==  0

      assert Rayz.Tuple.is_point?(a) == false
      assert Rayz.Tuple.is_vector?(a) == true
    end
  end
end
