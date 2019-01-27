defmodule RayzMatrixTest do
  use ExUnit.Case
  doctest Rayz.Matrix

  describe "Rayz.Matrix.multiply/2" do
    test "Multiplying a matrix by the identity matrix" do
      m =
        Builder.matrix(
          0, 1,  2,  4,
          1, 2,  4,  8,
          2, 4,  8, 16,
          4, 8, 16, 32
        )

      i = Builder.identity_matrix()

      p = Rayz.Matrix.multiply(m, i)

      assert Rayz.Matrix.equal?(p, m) == true
    end

    test "Multiplying the identity matrix by a tuple" do
      a = Builder.tuple(1, 2, 3, 1)
      i = Builder.identity_matrix()

      p = Rayz.Matrix.multiply(i, a)

      assert Rayz.Tuple.equal?(p, a) == true
    end

    test "A matrix multiplied by a tuple" do
      m =
        Builder.matrix(
          1, 2, 3, 4,
          2, 4, 4, 2,
          8, 6, 4, 1,
          0, 0, 0, 1
        )

      t = Builder.tuple(1, 2, 3, 1)

      p = Rayz.Matrix.multiply(m, t)

      expected_tuple = Builder.tuple(18, 24, 33, 1)

      assert Rayz.Tuple.equal?(p, expected_tuple)
    end

    test "Multiplying two matrices" do
      m1 =
        Builder.matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Builder.matrix(
          -2, 1, 2,  3,
           3, 2, 1, -1,
           4, 3, 6,  5,
           1, 2, 7,  8
        )

      m3 = Rayz.Matrix.multiply(m1, m2)

      expected_m =
        Builder.matrix(
          20, 22,  50,  48,
          44, 54, 114, 108,
          40, 58, 110, 102,
          16, 26,  46,  42
        )

      assert Rayz.Matrix.equal?(m3, expected_m) == true
    end
  end

  describe "Rayz.Matrix.equal?/2" do
    test "Matrix equality with identical matrices" do
      m1 =
        Builder.matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Builder.matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      assert Rayz.Matrix.equal?(m1, m2) == true
    end

    test "Matrix equality with different matrices" do
      m1 =
        Builder.matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Builder.matrix(
          2, 3, 4, 5,
          6, 7, 8, 9,
          8, 7, 6, 5,
          4, 3, 2, 1
        )

      assert Rayz.Matrix.equal?(m1, m2) == false
    end
  end
end
