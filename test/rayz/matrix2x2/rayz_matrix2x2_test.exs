defmodule Rayz.Matrix2x2Test do
  use ExUnit.Case, async: true
  doctest Rayz.Matrix2x2

  describe "Rayz.Matrix2x2.determinant/1" do
    test "it calculates the determinant correctly" do
      m =
        Rayz.Matrix2x2.new_matrix(
          1,  5,
          -3, 2
        )

      assert Rayz.Matrix2x2.determinant(m) == 17
    end
  end

  describe "Rayz.Matrix2x2.compare/2" do
    test "Works for floats more precise then the epsilon" do
      a = 0.000_003
      b = 0.000_004
      m1 =
        Rayz.Matrix2x2.new_matrix(
          a, a,
          a, a
        )

      m2 =
        Rayz.Matrix2x2.new_matrix(
          b, b,
          b, b
        )

      assert Rayz.Matrix2x2.compare(m1, m2) == true
    end

    test "Works for floats less precise than the epsilon" do
      a = 0.000_03
      b = 0.000_04
      m1 =
        Rayz.Matrix2x2.new_matrix(
          a, a,
          a, a
        )

      m2 =
        Rayz.Matrix2x2.new_matrix(
          b, b,
          b, b
        )

      assert Rayz.Matrix2x2.compare(m1, m2) == false
    end

    test "two unequal matrices are unequal" do
      m1 =
        Rayz.Matrix2x2.new_matrix(
          1, 2,
          3, 4
        )

      m2 =
        Rayz.Matrix2x2.new_matrix(
          2, 3,
          4, 5
        )

      assert Rayz.Matrix2x2.compare(m1, m2) == false
    end

    test "two equal matrices are equal" do
      m1 =
        Rayz.Matrix2x2.new_matrix(
          1, 2,
          3, 4
        )

      m2 =
        Rayz.Matrix2x2.new_matrix(
          1, 2,
          3, 4
        )

      assert Rayz.Matrix2x2.compare(m1, m2) == true
    end
  end

  describe "Rayz.Matrix2x2.new_matrix4" do
    test "can create a 2x2 matrix" do
      m = Rayz.Matrix2x2.new_matrix(
        1,   2,
        5.5, 6.5
      )

      assert m == {1, 2, 5.5, 6.5}

      assert Rayz.Matrix2x2.value_at(m, 0, 0) == 1
      assert Rayz.Matrix2x2.value_at(m, 1, 0) == 5.5
    end
  end
end
