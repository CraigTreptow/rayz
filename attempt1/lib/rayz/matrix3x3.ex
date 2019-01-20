defmodule Rayz.Matrix3x3 do
  alias Rayz.Epsilon, as: Epsilon
  require Integer

  @moduledoc """
  Provides a 3x3 Matrix

  a_a a_b a_c
  b_a b_b b_c
  c_a c_b c_c
  """

  @type matrix3x3() :: {
                         float(), float(), float(),
                         float(), float(), float(),
                         float(), float(), float()
                       }

  def determinant(m) do
    m = Rayz.Matrix3x3.new_matrix(
      value_at(m, 0, 0), 
      value_at(m, 0, 1), 
      value_at(m, 0, 2), 
      value_at(m, 1, 0), 
      value_at(m, 1, 1), 
      value_at(m, 1, 2), 
      value_at(m, 2, 0), 
      value_at(m, 2, 1), 
      value_at(m, 2, 2)) 

    (value_at(m, 0, 0) * cofactor(m, 0, 0)) +
    (value_at(m, 0, 1) * cofactor(m, 0, 1)) +
    (value_at(m, 0, 2) * cofactor(m, 0, 2))
  end

  def cofactor(m, r, c) do
    minor(m, r, c)
    |> possible_negation(r + c)
  end

  # if in an odd position(r + c), then sign changes
  # |+ − +|
  # |− + −|
  # |+ − +|
  def possible_negation(x, q) when Integer.is_odd(q), do: -x
  def possible_negation(x, _q), do: x

  def minor(m, r, c) do
    submatrix(m, r, c)
    |> Rayz.Matrix2x2.determinant
  end

  def submatrix({
                  _a_a, _a_b, _a_c,
                  _b_a, b_b, b_c,
                  _c_a, c_b, c_c
                }, 0, 0) do
    Rayz.Matrix2x2.new_matrix(b_b, b_c, c_b, c_c)
  end

  def submatrix({
                  _a_a, _a_b, _a_c,
                  b_a, _b_b, b_c,
                  c_a, _c_b, c_c
                }, 0, 1) do
    Rayz.Matrix2x2.new_matrix(b_a, b_c, c_a, c_c)
  end

  def submatrix({
                  _a_a, _a_b, _a_c,
                  b_a, b_b, _b_c,
                  c_a, c_b, _c_c
                }, 0, 2) do
    Rayz.Matrix2x2.new_matrix(b_a, b_b, c_a, c_b)
  end

  def submatrix({
                  _a_a, a_b, a_c,
                  _b_a, _b_b, _b_c,
                  _c_a, c_b, c_c
                }, 1, 0) do
    Rayz.Matrix2x2.new_matrix(a_b, a_c, c_b, c_c)
  end

  def submatrix({
                  a_a, _a_b, a_c,
                  _b_a, _b_b, _b_c,
                  c_a, _c_b, c_c
                }, 1, 1) do
    Rayz.Matrix2x2.new_matrix(a_a, a_c, c_a, c_c)
  end

  def submatrix({
                  a_a, a_b, _a_c,
                  _b_a, _b_b, _b_c,
                  c_a, c_b, _c_c
                }, 1, 2) do
    Rayz.Matrix2x2.new_matrix(a_a, a_b, c_a, c_b)
  end

  def submatrix({
                  _a_a, a_b, a_c,
                  _b_a, b_b, b_c,
                  _c_a, _c_b, _c_c
                }, 2, 0) do
    Rayz.Matrix2x2.new_matrix(a_b, a_c, b_b, b_c)
  end

  def submatrix({
                  a_a, _a_b, a_c,
                  b_a, _b_b, b_c,
                  _c_a, _c_b, _c_c
                }, 2, 1) do
    Rayz.Matrix2x2.new_matrix(a_a, a_c, b_a, b_c)
  end

  def submatrix({
                  a_a, a_b, _a_c,
                  b_a, b_b, _b_c,
                  _c_a, _c_b, _c_c
                }, 2, 2) do
    Rayz.Matrix2x2.new_matrix(a_a, a_b, b_a, b_b)
  end

  def compare(m1, m2) do
    Epsilon.equal?(value_at(m1, 0, 0), value_at(m2, 0, 0)) &&
    Epsilon.equal?(value_at(m1, 0, 1), value_at(m2, 0, 1)) &&
    Epsilon.equal?(value_at(m1, 0, 2), value_at(m2, 0, 2)) &&
    Epsilon.equal?(value_at(m1, 1, 0), value_at(m2, 1, 0)) &&
    Epsilon.equal?(value_at(m1, 1, 1), value_at(m2, 1, 1)) &&
    Epsilon.equal?(value_at(m1, 1, 2), value_at(m2, 1, 2)) &&
    Epsilon.equal?(value_at(m1, 2, 0), value_at(m2, 2, 0)) &&
    Epsilon.equal?(value_at(m1, 2, 1), value_at(m2, 2, 1)) &&
    Epsilon.equal?(value_at(m1, 2, 2), value_at(m2, 2, 2))
  end

  def value_at(matrix, 0, 0), do: elem(matrix, 0)
  def value_at(matrix, 0, 1), do: elem(matrix, 1)
  def value_at(matrix, 0, 2), do: elem(matrix, 2)
  def value_at(matrix, 1, 0), do: elem(matrix, 3)
  def value_at(matrix, 1, 1), do: elem(matrix, 4)
  def value_at(matrix, 1, 2), do: elem(matrix, 5)
  def value_at(matrix, 2, 0), do: elem(matrix, 6)
  def value_at(matrix, 2, 1), do: elem(matrix, 7)
  def value_at(matrix, 2, 2), do: elem(matrix, 8)

  @spec new_matrix(
          float(), float(), float(),
          float(), float(), float(),
          float(), float(), float()
        ) :: matrix3x3()
  def new_matrix(a_a, a_b, a_c, b_a, b_b, b_c, c_a, c_b, c_c) do
    {
      a_a, a_b, a_c,
      b_a, b_b, b_c,
      c_a, c_b, c_c
    }
  end
end
