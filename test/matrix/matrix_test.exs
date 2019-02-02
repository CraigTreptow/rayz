defmodule RayzMatrixTest do
  use ExUnit.Case
  doctest Rayz.Matrix

  describe "Rayz.Matrix.rotation_z/1" do
    test "Rotating a point around the z axis" do
      p = Builder.point(0, 1, 0)

      half_quarter = Builder.rotation_z(:math.pi / 4)
      full_quarter = Builder.rotation_z(:math.pi / 2)

      rotated_half    = Rayz.Matrix.multiply(half_quarter, p)
      expected_half_p = Builder.point(-:math.sqrt(2) / 2, :math.sqrt(2) / 2, 0)
      assert Equality.equal?(rotated_half, expected_half_p)

      rotated_full    = Rayz.Matrix.multiply(full_quarter, p)
      expected_full_p = Builder.point(-1, 0, 0)
      assert Equality.equal?(rotated_full, expected_full_p)
    end
  end

  describe "Rayz.Matrix.rotation_y/1" do
    test "Rotating a point around the y axis" do
      p = Builder.point(0, 0, 1)

      half_quarter = Builder.rotation_y(:math.pi / 4)
      full_quarter = Builder.rotation_y(:math.pi / 2)

      rotated_half    = Rayz.Matrix.multiply(half_quarter, p)
      expected_half_p = Builder.point(:math.sqrt(2) / 2, 0, :math.sqrt(2) / 2)
      assert Equality.equal?(rotated_half, expected_half_p)

      rotated_full    = Rayz.Matrix.multiply(full_quarter, p)
      expected_full_p = Builder.point(1, 0, 0)
      assert Equality.equal?(rotated_full, expected_full_p)
    end
  end

  describe "Rayz.Matrix.rotation_x/1" do
    test "Rotating a point around the x axis" do
      p = Builder.point(0, 1, 0)

      half_quarter = Builder.rotation_x(:math.pi / 4)
      full_quarter = Builder.rotation_x(:math.pi / 2)

      rotated_half    = Rayz.Matrix.multiply(half_quarter, p)
      expected_half_p = Builder.point(0, :math.sqrt(2) / 2, :math.sqrt(2) / 2)
      assert Equality.equal?(rotated_half, expected_half_p)

      rotated_full    = Rayz.Matrix.multiply(full_quarter, p)
      expected_full_p = Builder.point(0, 0, 1)
      assert Equality.equal?(rotated_full, expected_full_p)
    end

    test "The inverse of an x-rotation rotates in the opposite direction" do
      p = Builder.point(0, 1, 0)

      half_quarter = Builder.rotation_x(:math.pi / 4)
      inverse = Rayz.Matrix.inverse(half_quarter)

      rotated_inverse = Rayz.Matrix.multiply(inverse, p)
      expected_half_p = Builder.point(0, :math.sqrt(2) / 2, -:math.sqrt(2) / 2)

      assert Equality.equal?(rotated_inverse, expected_half_p)
    end
  end

  describe "Rayz.Matrix.scaling/1" do
    test "A scaling matrix applied to a point" do
      transform = Builder.scaling(2, 3, 4)
      p = Builder.point(-4, 6, 8)

      transformed = Rayz.Matrix.multiply(transform, p)

      expected_p = Builder.point(-8, 18, 32)

      assert Equality.equal?(transformed, expected_p)
    end

    test "A scaling matrix applied to a vector" do
      transform = Builder.scaling(2, 3, 4)
      v = Builder.vector(-4, 6, 8)

      transformed = Rayz.Matrix.multiply(transform, v)

      expected_v = Builder.vector(-8, 18, 32)

      assert Equality.equal?(transformed, expected_v)
    end

    test "Multiplying by the inverse of a scaling matrix" do
      transform = Builder.scaling(2, 3, 4)
      inverse = Rayz.Matrix.inverse(transform)
      v = Builder.vector(-4, 6, 8)

      transformed = Rayz.Matrix.multiply(inverse, v)

      expected_v = Builder.vector(-2, 2, 2)

      assert Equality.equal?(transformed, expected_v)
    end

    test "Reflection is scaling by a negative value" do
      transform = Builder.scaling(-1, 1, 1)
      p = Builder.point(2, 3, 4)

      transformed = Rayz.Matrix.multiply(transform, p)

      expected_p = Builder.point(-2, 3, 4)

      assert Equality.equal?(transformed, expected_p)
    end
  end

  describe "Rayz.Matrix.transform/1" do
    test "Multiplying by a translation matrix" do
      transform = Builder.translation(5, -3, 2)
      p = Builder.point(-3, 4, 5)

      transformed = Rayz.Matrix.multiply(transform, p)

      expected_p = Builder.point(2, 1, 7)

      assert Equality.equal?(transformed, expected_p)
    end

    test "Multiplying by the inverse of a translation matrix" do
      transform = Builder.translation(5, -3, 2)
      inverse = Rayz.Matrix.inverse(transform)
      p = Builder.point(-3, 4, 5)

      m = Rayz.Matrix.multiply(inverse, p)

      expected_p = Builder.point(-8, 7, 3)

      assert Equality.equal?(m, expected_p)
    end

    test "Translation does not affect vectors" do
      transform = Builder.translation(5, -3, 2)
      v = Builder.vector(-3, 4, 5)

      transformed = Rayz.Matrix.multiply(transform, v)

      assert Equality.equal?(transformed, v)
    end
  end

  describe "Rayz.Matrix.inverse/1" do
    test "Calculating the inverse of a matrix" do
      a = Builder.matrix(
        -5,  2,  6, -8,
         1, -5,  1,  8,
         7,  7, -6, -7,
         1, -3,  7,  4
      )

      b = Rayz.Matrix.inverse(a)

      assert Rayz.Matrix.determinant(a)    ==  532
      assert Rayz.Matrix.cofactor(a, 2, 3) == -160
      assert Rayz.Matrix.value_at(b, 3, 2) == -160 / 532

      assert Rayz.Matrix.cofactor(a, 3, 2) == 105
      assert Rayz.Matrix.value_at(b, 2, 3) == 105 / 532


      expected_m = Builder.matrix(
         0.21805,  0.45113,  0.24060, -0.04511,
        -0.80827, -1.45677, -0.44361,  0.52068,
        -0.07895, -0.22368, -0.05263,  0.19737,
        -0.52256, -0.81391, -0.30075,  0.30639)

      assert Equality.equal?(b, expected_m) == true
    end

    test "Calculating the inverse of another matrix" do
      a = Builder.matrix(
         8, -5,  9,  2,
         7,  5,  6,  1,
        -6,  0,  9,  6,
        -3,  0, -9, -4
      )

      b = Rayz.Matrix.inverse(a)

      expected_m = Builder.matrix(
        -0.15385, -0.15385, -0.28205, -0.53846, 
        -0.07692,  0.12308,  0.02564,  0.03077, 
         0.35897,  0.35897,  0.43590,  0.92308, 
        -0.69231, -0.69231, -0.76923, -1.92308
      )

      assert Equality.equal?(b, expected_m) == true
    end

    test "Calculating the inverse of a third matrix" do
      a = Builder.matrix(
         9,  3,  0,  9,
        -5, -2, -6, -3,
        -4,  9,  6,  4,
        -7,  6,  6,  2
      )

      b = Rayz.Matrix.inverse(a)

      expected_m = Builder.matrix(
        -0.04074, -0.07778,  0.14444, -0.22222,
        -0.07778,  0.03333,  0.36667, -0.33333,
        -0.02901, -0.14630, -0.10926,  0.12963,
         0.17778,  0.06667, -0.26667,  0.33333
      )

      assert Equality.equal?(b, expected_m) == true
    end

    test "Multiplying a product by its inverse" do
      a = Builder.matrix(
         3, -9,  7,  3,
         3, -8,  2, -9,
        -4,  4,  4,  1,
        -6,  5, -1,  1
      )

      b = Builder.matrix(
        8,  2, 2, 2,
        3, -1, 7, 0, 
        7,  0, 5, 4,
        6, -2, 0, 5
      )

      c = Rayz.Matrix.multiply(a, b)

      bi = Rayz.Matrix.inverse(b)

      d = Rayz.Matrix.multiply(c, bi)

      assert Equality.equal?(d, a) == true
    end
  end

  describe "Rayz.Matrix.invertible?/1" do
    test "Testing an invertible matrix for invertibility" do
      m = Builder.matrix(
        6,  4, 4,  4,
        5,  5, 7,  6,
        4, -9, 3, -7,
        9,  1, 7, -6
      )

      assert Rayz.Matrix.determinant(m) == -2120
      assert Rayz.Matrix.invertible?(m) == true
    end

    test "Testing a non-invertible matrix for invertibility" do
      m = Builder.matrix(
        -4,  2, -2, -3,
         9,  6,  2,  6,
         0, -5,  1, -5,
         0,  0,  0,  0
      )

      assert Rayz.Matrix.determinant(m) == 0
      assert Rayz.Matrix.invertible?(m) == false
    end
  end

  describe "Rayz.Matrix.cofactor/3" do
    test "Calculating a cofactor of a 3x3 matrix" do
      m = Builder.matrix(
        3,  5,  0,
        2, -1, -7,
        6, -1,  5
      )

      assert Rayz.Matrix.minor(m, 0, 0)    == -12
      assert Rayz.Matrix.cofactor(m, 0, 0) == -12
      assert Rayz.Matrix.minor(m, 1, 0)    ==  25
      assert Rayz.Matrix.cofactor(m, 1, 0) == -25
    end
  end

  describe "Rayz.Matrix.minor/3" do
    test "Calculating a minor of a 3x3 matrix" do
      m = Builder.matrix(
        3,  5,  0,
        2, -1, -7,
        6, -1,  5
      )

      sm = Rayz.Matrix.submatrix(m, 1, 0)

      assert Rayz.Matrix.determinant(sm) == 25
      assert Rayz.Matrix.minor(m, 1, 0) == 25
    end
  end

  describe "Rayz.Matrix.submatrix/3" do
    test "Test all submatrices" do
      on = [
             [0,   1,  2,  3],
             [4,   5,  6,  7],
             [8,   9, 10, 11],
             [12, 13, 14, 15]
           ]
      n = List.flatten(on)
      m = Builder.matrix(
            Enum.at(n, 0),  Enum.at(n, 1),  Enum.at(n, 2),  Enum.at(n, 3),
            Enum.at(n, 4),  Enum.at(n, 5),  Enum.at(n, 6),  Enum.at(n, 7),
            Enum.at(n, 8),  Enum.at(n, 9),  Enum.at(n, 10), Enum.at(n, 11),
            Enum.at(n, 12), Enum.at(n, 13), Enum.at(n, 14), Enum.at(n, 15)
          )

      result = for r <- 0..3 do
        for c <- 0..3 do
          Rayz.Matrix.submatrix(m, r, c)
        end
      end

      expected = [
        # row 0 removed
        [
          {5, 6, 7, 9, 10, 11, 13, 14, 15}, # col 0 removed
          {4, 6, 7, 8, 10, 11, 12, 14, 15}, # col 1 removed
          {4, 5, 7, 8, 9, 11, 12, 13, 15},  # col 2 removed
          {4, 5, 6, 8, 9, 10, 12, 13, 14}   # col 3 removed
        ],
        # row 1 removed
        [
          {1, 2, 3, 9, 10, 11, 13, 14, 15}, # col 0 removed
          {0, 2, 3, 8, 10, 11, 12, 14, 15}, # col 1 removed
          {0, 1, 3, 8, 9, 11, 12, 13, 15},  # col 2 removed
          {0, 1, 2, 8, 9, 10, 12, 13, 14}   # col 3 removed
        ],
        # row 2 removed
        [
          {1, 2, 3, 5, 6, 7, 13, 14, 15}, # col 0 removed
          {0, 2, 3, 4, 6, 7, 12, 14, 15}, # col 1 removed
          {0, 1, 3, 4, 5, 7, 12, 13, 15}, # col 2 removed
          {0, 1, 2, 4, 5, 6, 12, 13, 14}  # col 3 removed
        ],
        # row 3 removed
        [
          {1, 2, 3, 5, 6, 7, 9, 10, 11}, # col 0 removed
          {0, 2, 3, 4, 6, 7, 8, 10, 11}, # col 1 removed
          {0, 1, 3, 4, 5, 7, 8, 9, 11},  # col 2 removed
          {0, 1, 2, 4, 5, 6, 8, 9, 10}   # col 3 removed
        ]
      ]

      assert result == expected
    end

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

      assert Equality.equal?(sm, expected_m) == true
    end

    test "A submatrix of a 4x4 matrix is a 3x3 matrix" do
      m = Builder.matrix(
            -6, 1,  1, 6, 
            -8, 5,  8, 6, 
            -1, 0,  8, 2, 
            -7, 1, -1, 1
          )

      sm = Rayz.Matrix.submatrix(m, 2, 1)

      expected_m = Builder.matrix(
                     -6,  1, 6,
                     -8,  8, 6,
                     -7, -1, 1
                   )

      assert Equality.equal?(sm, expected_m) == true
    end
  end

  describe "Rayz.Matrix.determinant/1" do
    test "Calculating the determinant of a 3x3 matrix" do
      m = Builder.matrix(
             1, 2,  6,
            -5, 8, -4,
             2, 6,  4
          )

      assert Rayz.Matrix.cofactor(m, 0, 0) ==   56
      assert Rayz.Matrix.cofactor(m, 0, 1) ==   12
      assert Rayz.Matrix.cofactor(m, 0, 2) ==  -46
      assert Rayz.Matrix.determinant(m)    == -196
    end

    test "Calculating the determinant of a 4x4 matrix" do
      m = Builder.matrix(
            -2, -8,  3,  5,
            -3,  1,  7,  3,
             1,  2, -9,  6,
            -6,  7,  7, -9
          )
      assert Rayz.Matrix.cofactor(m, 0, 0) ==   690
      assert Rayz.Matrix.cofactor(m, 0, 1) ==   447
      assert Rayz.Matrix.cofactor(m, 0, 2) ==   210
      assert Rayz.Matrix.cofactor(m, 0, 3) ==    51
      assert Rayz.Matrix.determinant(m)    == -4071
    end

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

      assert Equality.equal?(a, i) == true
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

      assert Equality.equal?(t, expected_m) == true
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

      assert Equality.equal?(p, m) == true
    end

    test "Multiplying the identity matrix by a tuple" do
      a = Builder.tuple(1, 2, 3, 1)
      i = Builder.identity_matrix()

      p = Rayz.Matrix.multiply(i, a)

      assert Equality.equal?(p, a) == true
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

      assert Equality.equal?(p, expected_tuple)
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

      assert Equality.equal?(m3, expected_m) == true
    end
  end

  describe "Equality.equal?/2" do
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

      assert Equality.equal?(m1, m2) == true
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

      assert Equality.equal?(m1, m2) == false
    end
  end
end
