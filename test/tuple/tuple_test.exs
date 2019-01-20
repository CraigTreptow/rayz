defmodule RayzTupleTest do
  use ExUnit.Case
  doctest Rayz.Tuple

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
