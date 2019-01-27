defmodule Rayz.Matrix do
  @moduledoc """
  Provides matrixes of different sizes.

  A 4x4 Matrix:

  a_a a_b a_c a_d
  b_a b_b b_c b_d
  c_a c_b c_c c_d
  d_a d_b d_c d_d

  A 3x3 Matrix:

  a_a a_b a_c
  b_a b_b b_c
  c_a c_b c_c

  A 2x2 Matrix:

  a_a a_b
  b_a b_b
  """

  @doc """
      iex> Builder.matrix(1.1, 2.2, 3.3, 0,
      ...>                2.1, 2.2, 2.3, 0,
      ...>                3.1, 3.2, 3.3, 0,
      ...>                4.1, 4.2, 4.3, 0)
      {1.1, 2.2, 3.3, 0, 2.1, 2.2, 2.3, 0, 3.1, 3.2, 3.3, 0, 4.1, 4.2, 4.3, 0}
  """

  @type matrix4x4() :: 
    {
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float()
    }

  @type matrix3x3() :: 
    {
      float(), float(), float(),
      float(), float(), float(),
      float(), float(), float()
    }

  @type matrix2x2() :: 
    {
      float(), float(),
      float(), float()
    }

  def equal?(
    {
      m1_a_a, m1_a_b, m1_a_c, m1_a_d,
      m1_b_a, m1_b_b, m1_b_c, m1_b_d,
      m1_c_a, m1_c_b, m1_c_c, m1_c_d,
      m1_d_a, m1_d_b, m1_d_c, m1_d_d
    },
    {
      m2_a_a, m2_a_b, m2_a_c, m2_a_d,
      m2_b_a, m2_b_b, m2_b_c, m2_b_d,
      m2_c_a, m2_c_b, m2_c_c, m2_c_d,
      m2_d_a, m2_d_b, m2_d_c, m2_d_d
    }
  ) do
    m1_a_a == m2_a_a &&
    m1_a_b == m2_a_b &&
    m1_a_c == m2_a_c &&
    m1_a_d == m2_a_d &&
    m1_b_a == m2_b_a &&
    m1_b_b == m2_b_b &&
    m1_b_c == m2_b_c &&
    m1_b_d == m2_b_d &&
    m1_c_a == m2_c_a &&
    m1_c_b == m2_c_b &&
    m1_c_c == m2_c_c &&
    m1_c_d == m2_c_d &&
    m1_d_a == m2_d_a &&
    m1_d_b == m2_d_b &&
    m1_d_c == m2_d_c &&
    m1_d_d == m2_d_d
  end

  @spec value_at(matrix4x4, float(), float()) :: float()
  def value_at({a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 0, 0), do: a_a
  def value_at({_a_a, a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 0, 1), do: a_b
  def value_at({_a_a, _a_b, a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 0, 2), do: a_c
  def value_at({_a_a, _a_b, _a_c, a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 0, 3), do: a_d
  def value_at({_a_a, _a_b, _a_c, _a_d, b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 1, 0), do: b_a
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 1, 1), do: b_b
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 1, 2), do: b_c
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 1, 3), do: b_d
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 2, 0), do: c_a
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, c_b, _c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 2, 1), do: c_b
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, c_c, _c_d, _d_a, _d_b, _d_c, _d_d}, 2, 2), do: c_c
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, c_d, _d_a, _d_b, _d_c, _d_d}, 2, 3), do: c_d
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, d_a, _d_b, _d_c, _d_d}, 3, 0), do: d_a
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, d_b, _d_c, _d_d}, 3, 1), do: d_b
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, d_c, _d_d}, 3, 2), do: d_c
  def value_at({_a_a, _a_b, _a_c, _a_d, _b_a, _b_b, _b_c, _b_d, _c_a, _c_b, _c_c, _c_d, _d_a, _d_b, _d_c, d_d}, 3, 3), do: d_d

  @spec value_at(matrix3x3, float(), float()) :: float()
  def value_at({a_a, _a_b, _a_c, _b_a, _b_b, _b_c, _c_a, _c_b, _c_c}, 0, 0), do: a_a
  def value_at({_a_a, a_b, _a_c, _b_a, _b_b, _b_c, _c_a, _c_b, _c_c}, 0, 1), do: a_b
  def value_at({_a_a, _a_b, a_c, _b_a, _b_b, _b_c, _c_a, _c_b, _c_c}, 0, 2), do: a_c
  def value_at({_a_a, _a_b, _a_c, b_a, _b_b, _b_c, _c_a, _c_b, _c_c}, 1, 0), do: b_a
  def value_at({_a_a, _a_b, _a_c, _b_a, b_b, _b_c, _c_a, _c_b, _c_c}, 1, 1), do: b_b
  def value_at({_a_a, _a_b, _a_c, _b_a, _b_b, b_c, _c_a, _c_b, _c_c}, 1, 2), do: b_c
  def value_at({_a_a, _a_b, _a_c, _b_a, _b_b, _b_c, c_a, _c_b, _c_c}, 2, 0), do: c_a
  def value_at({_a_a, _a_b, _a_c, _b_a, _b_b, _b_c, _c_a, c_b, _c_c}, 2, 1), do: c_b
  def value_at({_a_a, _a_b, _a_c, _b_a, _b_b, _b_c, _c_a, _c_b, c_c}, 2, 2), do: c_c

  @spec value_at(matrix2x2, float(), float()) :: float()
  def value_at({a_a, _a_b, _b_a, _b_b}, 0, 0), do: a_a
  def value_at({_a_a, a_b, _b_a, _b_b}, 0, 1), do: a_b
  def value_at({_a_a, _a_b, b_a, _b_b}, 1, 0), do: b_a
  def value_at({_a_a, _a_b, _b_a, b_b}, 1, 1), do: b_b
end
