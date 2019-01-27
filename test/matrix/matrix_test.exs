defmodule RayzMatrixTest do
  use ExUnit.Case
  doctest Rayz.Matrix

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
