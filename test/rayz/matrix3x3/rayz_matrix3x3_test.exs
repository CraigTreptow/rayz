defmodule Rayz.Matrix3x3Test do
  use ExUnit.Case, async: true
  doctest Rayz.Matrix3x3

  describe "Rayz.Matrix3x3.determinant/1" do
    test "putting it all together" do
      m =
        Rayz.Matrix3x3.new_matrix(
          1,  2,  6,
          -5, 8, -4,
          2, 6,  4
        )

      assert Rayz.Matrix3x3.cofactor(m, 0, 0) == 56
      assert Rayz.Matrix3x3.cofactor(m, 0, 1) == 12
      assert Rayz.Matrix3x3.cofactor(m, 0, 2) == -46
      assert Rayz.Matrix3x3.determinant(m) == -196
    end
  end

  describe "Rayz.Matrix3x3.cofactor/3" do
    test "cofactor is just a number" do
      m =
        Rayz.Matrix3x3.new_matrix(
          3,  5,  0,
          2, -1, -7,
          6, -1,  5
        )

      assert Rayz.Matrix3x3.minor(m, 0, 0) == -12
      assert Rayz.Matrix3x3.cofactor(m, 0, 0) == -12
    end

    test "cofactor can change signs" do
      m =
        Rayz.Matrix3x3.new_matrix(
          3,  5,  0,
          2, -1, -7,
          6, -1,  5
        )

      assert Rayz.Matrix3x3.minor(m, 1, 0) == 25
      assert Rayz.Matrix3x3.cofactor(m, 1, 0) == -25
    end
  end

  describe "Rayz.Matrix3x3.minor/3" do
    test "calculates the determinant of the submatrix" do
      m =
        Rayz.Matrix3x3.new_matrix(
          3,  5,  0,
          2, -1, -7,
          6, -1,  5
        )

      assert Rayz.Matrix3x3.minor(m, 1, 0) == 25
    end
  end

  describe "Rayz.Matrix3x3.submatrix/3" do
    test "creates a Matrix2x2" do
    m =
      Rayz.Matrix3x3.new_matrix(
        1,  5, 0,
        -3, 2, 7,
        0,  6, -3
      )

      expected =
        Rayz.Matrix2x2.new_matrix(
        -3,  2,
          0, 6
        )

      assert Rayz.Matrix3x3.submatrix(m, 0, 2) == expected
    end
  end

  test "Works for floats more precise then the epsilon" do
    a = 0.000_003
    b = 0.000_004
    m1 =
      Rayz.Matrix3x3.new_matrix(
        a, a, a,
        a, a, a,
        a, a, a
      )

    m2 =
      Rayz.Matrix3x3.new_matrix(
        b, b, b,
        b, b, b,
        b, b, b
      )

    assert Rayz.Matrix3x3.compare(m1, m2) == true
  end

  test "Works for floats less precise than the epsilon" do
    a = 0.000_03
    b = 0.000_04
    m1 =
      Rayz.Matrix3x3.new_matrix(
        a, a, a,
        a, a, a,
        a, a, a
      )

    m2 =
      Rayz.Matrix3x3.new_matrix(
        b, b, b,
        b, b, b,
        b, b, b
      )

    assert Rayz.Matrix3x3.compare(m1, m2) == false
  end

  test "two unequal matrices are unequal" do
    m1 =
      Rayz.Matrix3x3.new_matrix(
        1, 2, 3,
        4, 5, 6,
        7, 8, 9
      )

    m2 =
      Rayz.Matrix3x3.new_matrix(
        2, 3, 4,
        5, 6, 7,
        8, 9, 0
      )

    assert Rayz.Matrix3x3.compare(m1, m2) == false
  end

  test "two equal matrices are equal" do
    m1 =
      Rayz.Matrix3x3.new_matrix(
        1, 2, 3,
        4, 5, 6,
        7, 8, 9
      )

    m2 =
      Rayz.Matrix3x3.new_matrix(
        1, 2, 3,
        4, 5, 6,
        7, 8, 9
      )

    assert Rayz.Matrix3x3.compare(m1, m2) == true
  end

  test "can create a 3x3 matrix" do
    m = Rayz.Matrix3x3.new_matrix(
          1,   2,   3,
          5.5, 6.5, 7.5,
          9,   10,  11
        )

    assert m == {1, 2, 3, 5.5, 6.5, 7.5, 9, 10, 11}

    assert Rayz.Matrix3x3.value_at(m, 0, 0) == 1
    assert Rayz.Matrix3x3.value_at(m, 0, 2) == 3
    assert Rayz.Matrix3x3.value_at(m, 1, 0) == 5.5
    assert Rayz.Matrix3x3.value_at(m, 1, 2) == 7.5
    assert Rayz.Matrix3x3.value_at(m, 2, 2) == 11
  end
end
