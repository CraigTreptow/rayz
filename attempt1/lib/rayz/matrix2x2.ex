defmodule Rayz.Matrix2x2 do
  alias Rayz.Epsilon, as: Epsilon

  @moduledoc """
  Provides a 2x2 Matrix

  a_a a_b
  b_a b_b
  """

  @type matrix2x2() ::
  {
    float(), float(),
    float(), float()
  }

  def determinant({a, b, c, d}) do
    a * d - b * c
  end

  def compare(m1, m2) do
    Epsilon.equal?(value_at(m1, 0, 0), value_at(m2, 0, 0)) &&
    Epsilon.equal?(value_at(m1, 0, 1), value_at(m2, 0, 1)) &&
    Epsilon.equal?(value_at(m1, 1, 0), value_at(m2, 1, 0)) &&
    Epsilon.equal?(value_at(m1, 1, 1), value_at(m2, 1, 1))
  end

  def value_at(matrix, 0, 0), do: elem(matrix, 0)
  def value_at(matrix, 0, 1), do: elem(matrix, 1)
  def value_at(matrix, 1, 0), do: elem(matrix, 2)
  def value_at(matrix, 1, 1), do: elem(matrix, 3)

  @spec new_matrix(
          float(), float(),
          float(), float()
        ) :: matrix2x2()
  def new_matrix(a_a, a_b, b_a, b_b) do
    {
      a_a, a_b,
      b_a, b_b
    }
  end
end
