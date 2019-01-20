defmodule Rayz.Matrix4x4Test do
  use ExUnit.Case, async: true
  doctest Rayz.Matrix4x4

  describe "transformations" do
    test "Individual transformations are applied in sequence" do
      p = Rayz.Tuple.new_point(1, 0, 1)
      a = Rayz.Matrix4x4.rotation_x(:math.pi() / 2)
      b = Rayz.Matrix4x4.scaling(5, 5, 5)
      c = Rayz.Matrix4x4.translation(10, 5, 7)

      # apply rotation first
      p2 = Rayz.Matrix4x4.multiply_tuple(p, a)
      ep = Rayz.Tuple.new_point(1, -1, 0)
      assert Rayz.Tuple.equal?(p2, ep) == true

      # then apply scaling
      p3 = Rayz.Matrix4x4.multiply_tuple(p2, b)
      ep = Rayz.Tuple.new_point(5, -5, 0)
      assert Rayz.Tuple.equal?(p3, ep) == true

      # then apply translation
      p4 = Rayz.Matrix4x4.multiply_tuple(p3, c)
      ep = Rayz.Tuple.new_point(15, 0, 7)
      assert Rayz.Tuple.equal?(p4, ep) == true
    end

    test "Chained transformations must be applied in reverse order" do
      p = Rayz.Tuple.new_point(1, 0, 1)
      a = Rayz.Matrix4x4.rotation_x(:math.pi() / 2)
      b = Rayz.Matrix4x4.scaling(5, 5, 5)
      c = Rayz.Matrix4x4.translation(10, 5, 7)
      t = p
          |> Rayz.Matrix4x4.multiply_tuple(a)
          |> Rayz.Matrix4x4.multiply_tuple(b)
          |> Rayz.Matrix4x4.multiply_tuple(c)

      ep = Rayz.Tuple.new_point(15, 0, 7)
      assert Rayz.Tuple.equal?(ep, t) == true
    end
  end

  describe "Rayz.Matrix4x4.shearing/6" do
    test "A shearing transformation moves x in proportion to y" do
      transform = Rayz.Matrix4x4.shearing(1, 0, 0, 0, 0, 0)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(5, 3, 4)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end

    test "A shearing transformation moves x in proportion to z" do
      transform = Rayz.Matrix4x4.shearing(0, 1, 0, 0, 0, 0)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(6, 3, 4)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end

    test "A shearing transformation moves y in proportion to x" do
      transform = Rayz.Matrix4x4.shearing(0, 0, 1, 0, 0, 0)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(2, 5, 4)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end

    test "A shearing transformation moves y in proportion to z" do
      transform = Rayz.Matrix4x4.shearing(0, 0, 0, 1, 0, 0)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(2, 7, 4)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end

    test "A shearing transformation moves z in proportion to x" do
      transform = Rayz.Matrix4x4.shearing(0, 0, 0, 0, 1, 0)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(2, 3, 6)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end

    test "A shearing transformation moves z in proportion to y" do
      transform = Rayz.Matrix4x4.shearing(0, 0, 0, 0, 0, 1)
      p = Rayz.Tuple.new_point(2, 3, 4)

      sheared_point = Rayz.Matrix4x4.multiply_tuple(p, transform)
      expected_point = Rayz.Tuple.new_point(2, 3, 7)

      assert Rayz.Tuple.equal?(sheared_point, expected_point) == true
    end
  end

  describe "Rayz.Matrix4x4.rotation_z/1" do
    test " Rotating a point around the z axis" do
      p = Rayz.Tuple.new_point(0, 1, 0)
      half_quarter = Rayz.Matrix4x4.rotation_z(:math.pi() / 4)
      full_quarter = Rayz.Matrix4x4.rotation_z(:math.pi() / 2)

      half_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, half_quarter)
      full_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, full_quarter)

      expected_half_quarter_rotated_point =  Rayz.Tuple.new_point(-1 * (:math.sqrt(2)) / 2, :math.sqrt(2) / 2, 0)
      expected_full_quarter_rotated_point =  Rayz.Tuple.new_point(-1, 0, 0)

      assert Rayz.Tuple.equal?(half_quarter_rotated_point, expected_half_quarter_rotated_point) == true
      assert Rayz.Tuple.equal?(full_quarter_rotated_point, expected_full_quarter_rotated_point) == true
    end
  end

  describe "Rayz.Matrix4x4.rotation_y/1" do
    test " Rotating a point around the y axis" do
      p = Rayz.Tuple.new_point(0, 0, 1)
      half_quarter = Rayz.Matrix4x4.rotation_y(:math.pi() / 4)
      full_quarter = Rayz.Matrix4x4.rotation_y(:math.pi() / 2)

      half_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, half_quarter)
      full_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, full_quarter)

      expected_half_quarter_rotated_point =  Rayz.Tuple.new_point(:math.sqrt(2) / 2, 0, :math.sqrt(2) / 2)
      expected_full_quarter_rotated_point =  Rayz.Tuple.new_point(1, 0, 0)

      assert Rayz.Tuple.equal?(half_quarter_rotated_point, expected_half_quarter_rotated_point) == true
      assert Rayz.Tuple.equal?(full_quarter_rotated_point, expected_full_quarter_rotated_point) == true
    end
  end

  describe "Rayz.Matrix4x4.rotation_x/1" do
    test " Rotating a point around the x axis" do
      p = Rayz.Tuple.new_point(0, 1, 0)
      half_quarter = Rayz.Matrix4x4.rotation_x(:math.pi() / 4)
      full_quarter = Rayz.Matrix4x4.rotation_x(:math.pi() / 2)

      half_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, half_quarter)
      full_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, full_quarter)

      expected_half_quarter_rotated_point =  Rayz.Tuple.new_point(0, :math.sqrt(2) / 2, :math.sqrt(2) / 2)
      expected_full_quarter_rotated_point =  Rayz.Tuple.new_point(0, 0, 1)

      assert Rayz.Tuple.equal?(half_quarter_rotated_point, expected_half_quarter_rotated_point) == true
      assert Rayz.Tuple.equal?(full_quarter_rotated_point, expected_full_quarter_rotated_point) == true
    end

    test "The inverse of an x-rotation rotates in the opposite direction" do
      p = Rayz.Tuple.new_point(0, 1, 0)
      half_quarter = Rayz.Matrix4x4.rotation_x(:math.pi() / 4)
      inverse = Rayz.Matrix4x4.inverse(half_quarter)

      inverse_half_quarter_rotated_point = Rayz.Matrix4x4.multiply_tuple(p, inverse)

      expected_inverse_half_quarter_rotated_point = 
        Rayz.Tuple.new_point(
          0,
          :math.sqrt(2) / 2,
          -1 * (:math.sqrt(2) / 2)
        )

      assert Rayz.Tuple.equal?(
        inverse_half_quarter_rotated_point,
        expected_inverse_half_quarter_rotated_point) == true
    end
  end

  describe "Rayz/Matrix4x4.scaling/3" do
    test "A scaling matrix applied to a point" do
      transform = Rayz.Matrix4x4.scaling(2, 3, 4)
      point = Rayz.Tuple.new_point(-4, 6, 8)

      expected_point = Rayz.Tuple.new_point(-8, 18, 32)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(point, transform)

      assert Rayz.Tuple.equal?(new_tuple, expected_point) == true
    end

    test "A scaling matrix applied to a vector" do
      transform = Rayz.Matrix4x4.scaling(2, 3, 4)
      vector = Rayz.Tuple.new_vector(-4, 6, 8)

      expected_vector = Rayz.Tuple.new_vector(-8, 18, 32)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(vector, transform)

      assert Rayz.Tuple.equal?(new_tuple, expected_vector) == true
    end

    test "Multiplying by the inverse of a scaling matrix" do
      transform = Rayz.Matrix4x4.scaling(2, 3, 4)
      inverse = Rayz.Matrix4x4.inverse(transform)
      vector = Rayz.Tuple.new_vector(-4, 6, 8)

      expected_vector = Rayz.Tuple.new_vector(-2, 2, 2)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(vector, inverse)

      assert Rayz.Tuple.equal?(new_tuple, expected_vector) == true
    end

    test "Reflection is scaling by a negative value" do
      transform = Rayz.Matrix4x4.scaling(-1, 1, 1)
      point = Rayz.Tuple.new_point(2, 3, 4)

      expected_point = Rayz.Tuple.new_point(-2, 3, 4)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(point, transform)

      assert Rayz.Tuple.equal?(new_tuple, expected_point) == true
    end
  end

  describe "Rayz/Matrix4x4.translation/3" do
    test "Multiplying by a translation matrix" do
      transform = Rayz.Matrix4x4.translation(5, -3, 2)
      point = Rayz.Tuple.new_point(-3, 4, 5)

      expected_point = Rayz.Tuple.new_point(2, 1, 7)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(point, transform)

      assert Rayz.Tuple.equal?(new_tuple, expected_point) == true
    end

    test "Multiplying by the inverse of a translation matrix" do
      transform = Rayz.Matrix4x4.translation(5, -3, 2)
      inverse = Rayz.Matrix4x4.inverse(transform)
      point = Rayz.Tuple.new_point(-3, 4, 5)

      expected_point = Rayz.Tuple.new_point(-8, 7, 3)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(point, inverse)

      assert Rayz.Tuple.equal?(new_tuple, expected_point) == true
    end

    test "Translation does not affect vectors" do
      transform = Rayz.Matrix4x4.translation(5, -3, 2)
      vector = Rayz.Tuple.new_vector(-3, 4, 5)

      new_tuple = Rayz.Matrix4x4.multiply_tuple(vector, transform)

      assert Rayz.Tuple.equal?(new_tuple, vector) == true
    end
  end

  describe "Rayz.Matrix4x4.inverse/1" do
    test "Multiplying a product by its inverse" do
      a =
        Rayz.Matrix4x4.new_matrix(
          3, -9, 7, 3,
          3, -8, 2, -9,
          -4, 4, 4, 1,
          -6, 5, -1, 1
        )

      b =
        Rayz.Matrix4x4.new_matrix(
          8, 2, 2, 2,
          3, -1, 7, 0,
          7, 0, 5, 4,
          6, -2, 0, 5
        )

      c = Rayz.Matrix4x4.multiply(a, b)
      bi = Rayz.Matrix4x4.inverse(b)

      d = Rayz.Matrix4x4.multiply(c, bi)

      assert Rayz.Matrix4x4.equal?(d, a)
    end

    test "Calculating the inverse of a matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          -5, 2, 6, -8,
          1, -5, 1, 8,
          7, 7, -6, -7,
          1, -3, 7, 4
        )

    inversed_matrix =
      Rayz.Matrix4x4.new_matrix(
         0.21805,  0.45113,  0.24060, -0.04511,
        -0.80827, -1.45677, -0.44361,  0.52068,
        -0.07895, -0.22368, -0.05263,  0.19737,
        -0.52256, -0.81391, -0.30075,  0.30639
      )

      b = Rayz.Matrix4x4.inverse(m)

      assert Rayz.Matrix4x4.determinant(m) == 532
      assert Rayz.Matrix4x4.cofactor(m, 2, 3) == -160
      assert Rayz.Matrix4x4.cofactor(m, 3, 2) == 105
      assert Rayz.Matrix4x4.value_at(b, 3, 2) == -160 / 532
      assert Rayz.Matrix4x4.value_at(b, 2, 3) == 105 / 532
      assert Rayz.Matrix4x4.equal?(b, inversed_matrix) == true
    end

    test "Calculating the inverse of another matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          8, -5, 9, 2,
          7, 5, 6, 1,
          -6, 0, 9, 6,
          -3, 0, -9, -4
        )

    inversed_matrix =
      Rayz.Matrix4x4.new_matrix(
        -0.15385, -0.15385, -0.28205, -0.53846,
        -0.07692,  0.12308,  0.02564,  0.03077,
         0.35897,  0.35897,  0.43590,  0.92308,
        -0.69231, -0.69231, -0.76923, -1.92308
      )

      b = Rayz.Matrix4x4.inverse(m)

      assert Rayz.Matrix4x4.equal?(b, inversed_matrix) == true
    end

    test "Calculating the inverse of a third matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          9, 3, 0, 9,
          -5, -2, -6, -3,
          -4, 9, 6, 4,
          -7, 6, 6, 2
        )

    inversed_matrix =
      Rayz.Matrix4x4.new_matrix(
        -0.04074, -0.07778,  0.14444, -0.22222,
        -0.07778,  0.03333,  0.36667, -0.33333,
        -0.02901, -0.14630, -0.10926,  0.12963,
         0.17778,  0.06667, -0.26667,  0.33333
      )

      b = Rayz.Matrix4x4.inverse(m)

      assert Rayz.Matrix4x4.equal?(b, inversed_matrix) == true
    end
  end

  describe "Rayz.Matrix4x4.invertible?/1" do
    test "testing an invertible matrix for invertibility" do
      m =
        Rayz.Matrix4x4.new_matrix(
          6, 4, 4, 4,
          5, 5, 7, 6,
          4, -9, 3, -7,
          9, 1, 7, -6
        )

      assert Rayz.Matrix4x4.determinant(m) == -2120
      assert Rayz.Matrix4x4.invertible?(m) == true
    end

    test "testing a non-invertible matrix for invertibility" do
      m =
        Rayz.Matrix4x4.new_matrix(
          -4, 2, -2, -3,
          9,  6,  2,  6,
          0, -5,  1, -5,
          0,  0,  0,  0
        )

      assert Rayz.Matrix4x4.determinant(m) == 0
      assert Rayz.Matrix4x4.invertible?(m) == false
    end
  end

  describe "Rayz.Matrix4x4.determinant/1" do
    test "putting it all together" do
      m =
        Rayz.Matrix4x4.new_matrix(
        -2, -8, 3, 5,
        -3, 1, 7, 3,
        1, 2, -9, 6,
        -6, 7, 7, -9
        )

      assert Rayz.Matrix4x4.cofactor(m, 0, 0) == 690
      assert Rayz.Matrix4x4.cofactor(m, 0, 1) == 447
      assert Rayz.Matrix4x4.cofactor(m, 0, 2) == 210
      assert Rayz.Matrix4x4.cofactor(m, 0, 3) == 51
      assert Rayz.Matrix4x4.determinant(m) == -4071
    end
  end

  describe "Rayz.Matrix4x4.minor/3" do
    test "calculates the determinant of the submatrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          9, 1,  2, 6,
          9, 9, 9, 9,
          9, -5, 8, -4,
          9, 2, 6, 4
        )

      assert Rayz.Matrix4x4.minor(m, 1, 0) == -196
    end
  end

  describe "Rayz.Matrix4x4.submatrix/3" do
    test "creates a Matrix3x3" do
      m =
        Rayz.Matrix4x4.new_matrix(
        -6, 1, 1, 6,
        -8, 5, 8, 6,
        -1, 0, 8, 2,
        -7, 1, -1, 1
        )

      expected =
        Rayz.Matrix3x3.new_matrix(
        -6, 1, 6,
        -8, 8, 6,
        -7, -1, 1
        )

      assert Rayz.Matrix4x4.submatrix(m, 2, 1) == expected
    end
  end

  describe "Rayz.Matrix4x4.transpose/1" do
    test "can transpose a matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          0, 9, 3, 0,
          9, 8, 0, 8,
          1, 8, 5, 3,
          0, 0, 5, 8
        )

      expected =
        Rayz.Matrix4x4.new_matrix(
          0, 9, 1, 0,
          9, 8, 8, 0,
          3, 0, 5, 5,
          0, 8, 3, 8
        )

      t = Rayz.Matrix4x4.transpose(m)

      assert Rayz.Matrix4x4.equal?(t, expected) == true
    end

    test "transposing identity gives identity" do
      i = Rayz.Matrix4x4.identity()
      t = Rayz.Matrix4x4.transpose(i)

      assert Rayz.Matrix4x4.equal?(i, t)
    end
  end

  describe "Rayz.Matrix4x4.identity/0" do
    test "can create an identity matrix" do
      i = Rayz.Matrix4x4.identity()

      assert i ==
        {
          1, 0, 0, 0,
          0, 1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1
        }
    end
  end

  describe "Rayz.Matrix4x4.multiply_tuple/2" do
    test "can multiply identity matrix by vector" do
      i = Rayz.Matrix4x4.identity()
      v = Rayz.Tuple.new_vector(1, 2, 3)

      assert Rayz.Matrix4x4.multiply_tuple(v, i) == v
    end

    test "can multiply matrix by vector" do
      m =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          2, 4, 4, 2,
          8, 6, 4, 1,
          0, 0, 0, 1
        )

      t = Rayz.Tuple.new_tuple(1, 2, 3, 1)

      expected_tuple = Rayz.Tuple.new_tuple(18, 24, 33, 1)

      assert Rayz.Matrix4x4.multiply_tuple(t, m) == expected_tuple
    end
  end

  describe "Rayz.Matrix4x4.multiply/2" do
    test "can multiply by the identity matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          0, 1, 2,  4,
          1, 2, 4,  8,
          2, 4, 8,  16,
          4, 8, 16, 32
        )
      i = Rayz.Matrix4x4.identity()

      assert Rayz.Matrix4x4.multiply(m, i) == m
    end

    test "can multiply two matrices" do
      m1 =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Rayz.Matrix4x4.new_matrix(
        -2, 1, 2, 3,
          3, 2, 1, -1,
          4, 3, 6, 5,
          1, 2, 7, 8
        )

      assert Rayz.Matrix4x4.multiply(m1, m2) == 
        {
          20, 22, 50,  48,
          44, 54, 114, 108,
          40, 58, 110, 102,
          16, 26, 46,  42
        }
    end
  end

  describe "Rayz.Matrix.equal/2" do
    test "Works for floats more precise then the epsilon" do
      a = 0.000_003
      b = 0.000_004
      m1 =
        Rayz.Matrix4x4.new_matrix(
          a, a, a, a,
          a, a, a, a,
          a, a, a, a,
          a, a, a, a
        )

      m2 =
        Rayz.Matrix4x4.new_matrix(
          b, b, b, b,
          b, b, b, b,
          b, b, b, b,
          b, b, b, b
        )

      assert Rayz.Matrix4x4.equal?(m1, m2) == true
    end

    test "Works for floats less precise than the epsilon" do
      a = 0.000_03
      b = 0.000_04
      m1 =
        Rayz.Matrix4x4.new_matrix(
          a, a, a, a,
          a, a, a, a,
          a, a, a, a,
          a, a, a, a
        )

      m2 =
        Rayz.Matrix4x4.new_matrix(
          b, b, b, b,
          b, b, b, b,
          b, b, b, b,
          b, b, b, b
        )

      assert Rayz.Matrix4x4.equal?(m1, m2) == false
    end

    test "two unequal matrices are unequal" do
      m1 =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Rayz.Matrix4x4.new_matrix(
          2, 3, 4, 5,
          6, 7, 8, 9,
          8, 7, 6, 5,
          4, 3, 2, 1
        )

      assert Rayz.Matrix4x4.equal?(m1, m2) == false
    end

    test "two equal matrices are equal" do
      m1 =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      m2 =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      assert Rayz.Matrix4x4.equal?(m1, m2) == true
    end
  end

  describe "Rayz.Matrix4x4.value_at/3" do
    test "get's correct value back out" do
      m =
        Rayz.Matrix4x4.new_matrix(
          1, 2, 3, 4,
          5, 6, 7, 8,
          9, 8, 7, 6,
          5, 4, 3, 2
        )

      assert Rayz.Matrix4x4.value_at(m, 0, 0) == 1
      assert Rayz.Matrix4x4.value_at(m, 0, 1) == 2
      assert Rayz.Matrix4x4.value_at(m, 0, 2) == 3
      assert Rayz.Matrix4x4.value_at(m, 0, 3) == 4
      assert Rayz.Matrix4x4.value_at(m, 1, 0) == 5
      assert Rayz.Matrix4x4.value_at(m, 1, 1) == 6
      assert Rayz.Matrix4x4.value_at(m, 1, 2) == 7
      assert Rayz.Matrix4x4.value_at(m, 1, 3) == 8
      assert Rayz.Matrix4x4.value_at(m, 2, 0) == 9
      assert Rayz.Matrix4x4.value_at(m, 2, 1) == 8
      assert Rayz.Matrix4x4.value_at(m, 2, 2) == 7
      assert Rayz.Matrix4x4.value_at(m, 2, 3) == 6
      assert Rayz.Matrix4x4.value_at(m, 3, 0) == 5
      assert Rayz.Matrix4x4.value_at(m, 3, 1) == 4
      assert Rayz.Matrix4x4.value_at(m, 3, 2) == 3
      assert Rayz.Matrix4x4.value_at(m, 3, 3) == 2
    end
  end

  describe "Rayz.Matrix4x4.new_matrix/16" do
    test "can create a 4x4 matrix" do
      m =
        Rayz.Matrix4x4.new_matrix(
          1,    2,    3,    4,
          5.5,  6.5,  7.5,  8.5,
          9,    10,   11,   12,
          13.5, 14.5, 15.5, 16.5
        )

      assert m ==
        {
          1,    2,    3,    4,
          5.5,  6.5,  7.5,  8.5,
          9,    10,   11,   12,
          13.5, 14.5, 15.5, 16.5
        }

      assert Rayz.Matrix4x4.value_at(m, 0, 0) == 1
      assert Rayz.Matrix4x4.value_at(m, 0, 3) == 4
      assert Rayz.Matrix4x4.value_at(m, 1, 0) == 5.5
      assert Rayz.Matrix4x4.value_at(m, 1, 2) == 7.5
      assert Rayz.Matrix4x4.value_at(m, 2, 2) == 11
      assert Rayz.Matrix4x4.value_at(m, 3, 0) == 13.5
      assert Rayz.Matrix4x4.value_at(m, 3, 2) == 15.5
    end
  end
end
