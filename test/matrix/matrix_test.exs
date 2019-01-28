defmodule RayzMatrixTest do
  use ExUnit.Case
  doctest Rayz.Matrix

  describe "Rayz.Matrix.submatrix/3" do
    test "A submatrix of a 3x3 matrix is a 2x2 matrix" do
      m = Builder.matrix(
             1, 5,  0,
            -3, 2,  7,
             0, 6, -3
          )

      sm = Rayz.Matrix.submatrix(m, 0, 2)

      expected_m = Builder.matrix(
                     -3, 2,
                      0, 6
                   )

      assert Rayz.Matrix.equal?(sm, expected_m) == true
    end

    test "A submatrix of a 4x4 matrix is a 3x3 matrix" do
      m = Builder.matrix(
            -6, 1, 1, 6, 
            -8, 5, 8, 6, 
            -1, 0, 8, 2, 
            -7, 1,-1, 1
          )

      sm = Rayz.Matrix.submatrix(m, 2, 1)

      expected_m = Builder.matrix(
                     -6,  1, 6,
                     -8,  8, 6,
                     -7, -1, 1
                   )

      assert Rayz.Matrix.equal?(sm, expected_m) == true
    end
  end

  describe "Rayz.Matrix.determinant/1" do
    test "Calculating the determinant of a 2x2 matrix" do
      m =
        Builder.matrix(
           1, 5,
          -3, 2
        )

      assert Rayz.Matrix.determinant(m) == 17
    end
  end

  describe "Rayz.Matrix.transpose/1" do
    test "Transposing the identity matrix" do
      a = Builder.identity_matrix()
          |> Rayz.Matrix.transpose

      i = Builder.identity_matrix()

      assert Rayz.Matrix.equal?(a, i) == true
    end

    test "Transposing a matrix" do
      m =
        Builder.matrix(
          0, 9, 3, 0,
          9, 8, 0, 8,
          1, 8, 5, 3,
          0, 0, 5, 8
        )

      t = Rayz.Matrix.transpose(m)

      expected_m =
        Builder.matrix(
          0, 9, 1, 0,
          9, 8, 8, 0,
          3, 0, 5, 5,
          0, 8, 3, 8
        )

      assert Rayz.Matrix.equal?(t, expected_m) == true
    end
  end

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
