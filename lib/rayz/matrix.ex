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

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}

  @spec inverse(matrix4x4()) :: matrix4x4()
  def inverse(m = {
      _, _, _, _,
      _, _, _, _,
      _, _, _, _,
      _, _, _, _}
      ) do

    if invertible?(m) do
      d = determinant(m)

      m1 = Builder.matrix(
        cofactor(m, 0, 0), cofactor(m, 0, 1), cofactor(m, 0, 2), cofactor(m, 0, 3),
        cofactor(m, 1, 0), cofactor(m, 1, 1), cofactor(m, 1, 2), cofactor(m, 1, 3),
        cofactor(m, 2, 0), cofactor(m, 2, 1), cofactor(m, 2, 2), cofactor(m, 2, 3),
        cofactor(m, 3, 0), cofactor(m, 3, 1), cofactor(m, 3, 2), cofactor(m, 3, 3)
      )

      m2 = transpose(m1)

      Builder.matrix(
        value_at(m2, 0, 0) / d, value_at(m2, 0, 1) / d, value_at(m2, 0, 2) / d,  value_at(m2, 0, 3) / d,
        value_at(m2, 1, 0) / d, value_at(m2, 1, 1) / d, value_at(m2, 1, 2) / d,  value_at(m2, 1, 3) / d,
        value_at(m2, 2, 0) / d, value_at(m2, 2, 1) / d, value_at(m2, 2, 2) / d,  value_at(m2, 2, 3) / d,
        value_at(m2, 3, 0) / d, value_at(m2, 3, 1) / d, value_at(m2, 3, 2) / d,  value_at(m2, 3, 3) / d
      )
    else
      {:error, "not invertible"}
    end
  end

  @spec invertible?(matrix4x4()) :: boolean()
  def invertible?(m) do
    determinant(m) != 0
  end

  @spec cofactor(matrix3x3(), integer(), integer()) :: integer()
  def cofactor(m, 0, 0), do:  minor(m, 0, 0)
  def cofactor(m, 0, 1), do: -minor(m, 0, 1)
  def cofactor(m, 0, 2), do:  minor(m, 0, 2)
  def cofactor(m, 0, 3), do: -minor(m, 0, 3)
  def cofactor(m, 1, 0), do: -minor(m, 1, 0)
  def cofactor(m, 1, 1), do:  minor(m, 1, 1)
  def cofactor(m, 1, 2), do: -minor(m, 1, 2)
  def cofactor(m, 1, 3), do:  minor(m, 1, 3)
  def cofactor(m, 2, 0), do:  minor(m, 2, 0)
  def cofactor(m, 2, 1), do: -minor(m, 2, 1)
  def cofactor(m, 2, 2), do:  minor(m, 2, 2)
  def cofactor(m, 2, 3), do: -minor(m, 2, 3)
  def cofactor(m, 3, 0), do: -minor(m, 3, 0)
  def cofactor(m, 3, 1), do:  minor(m, 3, 1)
  def cofactor(m, 3, 2), do: -minor(m, 3, 2)
  def cofactor(m, 3, 3), do:  minor(m, 3, 3)

  @spec minor(matrix3x3(), integer(), integer()) :: integer()
  def minor(m, r, c) do
    m
    |> submatrix(r, c)
    |> determinant
  end

  @spec submatrix(matrix3x3(), integer(), integer()) :: matrix2x2()
  def submatrix({_, _, _, _, b_b, b_c, _, c_b, c_c}, 0, 0) do
    {
      b_b, b_c,
      c_b, c_c
    }
  end
  def submatrix({_, _, _, b_a, _, b_c, c_a, _, c_c}, 0, 1) do
    {
      b_a, b_c,
      c_a, c_c
    }
  end
  def submatrix({_, _, _, b_a, b_b, _, c_a, c_b, _}, 0, 2) do
    {
      b_a, b_b,
      c_a, c_b
    }
  end
  def submatrix({_, a_b, a_c, _, _, _, _, c_b, c_c}, 1, 0) do
    {
      a_b, a_c,
      c_b, c_c
    }
  end
  def submatrix({a_a, _, a_c, _, _, _, c_a, _, c_c}, 1, 1) do
    {
      a_a, a_c,
      c_a, c_c
    }
  end
  def submatrix({a_a, a_b, _, _, _, _, c_a, c_b, _}, 1, 2) do
    {
      a_a, a_b,
      c_a, c_b
    }
  end
  def submatrix({_, a_b, a_c, _, b_b, b_c, _, _, _}, 2, 0) do
    {
      a_b, a_c,
      b_b, b_c
    }
  end
  def submatrix({a_a, _, a_c, b_a, _, b_c, _, _, _}, 2, 1) do
    {
      a_a, a_c,
      b_a, b_c
    }
  end
  def submatrix({a_a, a_b, _, b_a, b_b, _, _, _, _}, 2, 2) do
    {
      a_a, a_b,
      b_a, b_b
    }
  end

  @spec submatrix(matrix4x4(), integer(), integer()) :: matrix3x3()
  def submatrix({_, _, _, _, _, b_b, b_c, b_d, _, c_b, c_c, c_d, _, d_b, d_c, d_d}, 0, 0) do
    {
      b_b, b_c, b_d,
      c_b, c_c, c_d,
      d_b, d_c, d_d
    }
  end
  def submatrix({_, _, _, _, b_a, _, b_c, b_d, c_a, _, c_c, c_d, d_a, _, d_c, d_d}, 0, 1) do
    {
      b_a, b_c, b_d,
      c_a, c_c, c_d,
      d_a, d_c, d_d
    }
  end
  def submatrix({_, _, _, _, b_a, b_b, _, b_d, c_a, c_b, _, c_d, d_a, d_b, _, d_d}, 0, 2) do
    {
      b_a, b_b, b_d,
      c_a, c_b, c_d,
      d_a, d_b, d_d
    }
  end
  def submatrix({_, _, _, _, b_a, b_b, b_c, _, c_a, c_b, c_c, _, d_a, d_b, d_c, _}, 0, 3) do
    {
      b_a, b_b, b_c,
      c_a, c_b, c_c,
      d_a, d_b, d_c
    }
  end
  def submatrix({_, a_b, a_c, a_d, _, _, _, _, _, c_b, c_c, c_d, _, d_b, d_c, d_d}, 1, 0) do
    {
      a_b, a_c, a_d,
      c_b, c_c, c_d,
      d_b, d_c, d_d
    }
  end
  def submatrix({a_a, _, a_c, a_d, _, _, _, _, c_a, _, c_c, c_d, d_a, _, d_c, d_d}, 1, 1) do
    {
      a_a, a_c, a_d,
      c_a, c_c, c_d,
      d_a, d_c, d_d
    }
  end
  def submatrix({a_a, a_b, _, a_d, _, _, _, _, c_a, c_b, _, c_d, d_a, d_b, _, d_d}, 1, 2) do
    {
      a_a, a_b, a_d,
      c_a, c_b, c_d,
      d_a, d_b, d_d
    }
  end
  def submatrix({a_a, a_b, a_c, _, _, _, _, _, c_a, c_b, c_c, _, d_a, d_b, d_c, _}, 1, 3) do
    {
      a_a, a_b, a_c,
      c_a, c_b, c_c,
      d_a, d_b, d_c
    }
  end
  def submatrix({_, a_b, a_c, a_d, _, b_b, b_c, b_d, _, _, _, _, _, d_b, d_c, d_d}, 2, 0) do
    {
      a_b, a_c, a_d,
      b_b, b_c, b_d,
      d_b, d_c, d_d
    }
  end
  def submatrix({a_a, _, a_c, a_d, b_a, _, b_c, b_d, _, _, _, _, d_a, _, d_c, d_d}, 2, 1) do
    {
      a_a, a_c, a_d,
      b_a, b_c, b_d,
      d_a, d_c, d_d
    }
  end
  def submatrix({a_a, a_b, _, a_d, b_a, b_b, _, b_d, _, _, _, _, d_a, d_b, _, d_d}, 2, 2) do
    {
      a_a, a_b, a_d,
      b_a, b_b, b_d,
      d_a, d_b, d_d
    }
  end
  def submatrix({a_a, a_b, a_c, _, b_a, b_b, b_c, _, _, _, _, _, d_a, d_b, d_c, _}, 2, 3) do
    {
      a_a, a_b, a_c,
      b_a, b_b, b_c,
      d_a, d_b, d_c
    }
  end
  def submatrix({_, a_b, a_c, a_d, _, b_b, b_c, b_d, _, c_b, c_c, c_d, _, _, _, _}, 3, 0) do
    {
      a_b, a_c, a_d,
      b_b, b_c, b_d,
      c_b, c_c, c_d,
    }
  end
  def submatrix({a_a, _, a_c, a_d, b_a, _, b_c, b_d, c_a, _, c_c, c_d, _, _, _, _}, 3, 1) do
    {
      a_a, a_c, a_d,
      b_a, b_c, b_d,
      c_a, c_c, c_d,
    }
  end
  def submatrix({a_a, a_b, _, a_d, b_a, b_b, _, b_d, c_a, c_b, _, c_d, _, _, _, _}, 3, 2) do
    {
      a_a, a_b, a_d,
      b_a, b_b, b_d,
      c_a, c_b, c_d,
    }
  end
  def submatrix({a_a, a_b, a_c, _, b_a, b_b, b_c, _, c_a, c_b, c_c, _, _, _, _, _}, 3, 3) do
    {
      a_a, a_b, a_c,
      b_a, b_b, b_c,
      c_a, c_b, c_c,
    }
  end
 
  @spec determinant(matrix4x4()) :: float()
  def determinant(
    m = {
          a, b, c, d,
          _, _, _, _,
          _, _, _, _,
          _, _, _, _
        }
  ) do
    a * cofactor(m, 0, 0) +
    b * cofactor(m, 0, 1) +
    c * cofactor(m, 0, 2) +
    d * cofactor(m, 0, 3)
  end

  @spec determinant(matrix3x3()) :: float()
  def determinant(
    m = {
          a, b, c,
          _, _, _,
          _, _, _
    }
  ) do
    a * cofactor(m, 0, 0) +
    b * cofactor(m, 0, 1) +
    c * cofactor(m, 0, 2)
  end

  @spec determinant(matrix2x2()) :: float()
  def determinant(
    {
      a, b,
      c, d
    }
  ) do
    a * d - b * c
  end

  @spec transpose(matrix4x4()) :: matrix4x4()
  def transpose(
    {
      a_a, a_b, a_c, a_d,
      b_a, b_b, b_c, b_d,
      c_a, c_b, c_c, c_d,
      d_a, d_b, d_c, d_d
    }
  ) do
    {
      a_a, b_a, c_a, d_a,
      a_b, b_b, c_b, d_b,
      a_c, b_c, c_c, d_c,
      a_d, b_d, c_d, d_d
    }
  end

  @spec multiply(matrix4x4(), rayztuple()) :: matrix4x4()
  def multiply(
    {
      a_a, a_b, a_c, a_d,
      b_a, b_b, b_c, b_d,
      c_a, c_b, c_c, c_d,
      d_a, d_b, d_c, d_d
    },
    t = %Rayz.Tuple
      {
        x: _x,
        y: _y,
        z: _z,
        w: _w,
      }
  ) do
    Builder.tuple(
      Rayz.Tuple.dot(Builder.tuple(a_a, a_b, a_c, a_d), t),
      Rayz.Tuple.dot(Builder.tuple(b_a, b_b, b_c, b_d), t),
      Rayz.Tuple.dot(Builder.tuple(c_a, c_b, c_c, c_d), t),
      Rayz.Tuple.dot(Builder.tuple(d_a, d_b, d_c, d_d), t)
    )
  end

  @spec multiply(matrix4x4(), matrix4x4()) :: matrix4x4()
  def multiply(
    m1 = {
      _m1_a_a, _m1_a_b, _m1_a_c, _m1_a_d,
      _m1_b_a, _m1_b_b, _m1_b_c, _m1_b_d,
      _m1_c_a, _m1_c_b, _m1_c_c, _m1_c_d,
      _m1_d_a, _m1_d_b, _m1_d_c, _m1_d_d
    },
    m2 = {
      _m2_a_a, _m2_a_b, _m2_a_c, _m2_a_d,
      _m2_b_a, _m2_b_b, _m2_b_c, _m2_b_d,
      _m2_c_a, _m2_c_b, _m2_c_c, _m2_c_d,
      _m2_d_a, _m2_d_b, _m2_d_c, _m2_d_d
    }
  ) do
    for r <- 0..3 do
      for c <- 0..3 do
        (value_at(m1, r, 0) * value_at(m2, 0, c)) +
        (value_at(m1, r, 1) * value_at(m2, 1, c)) +
        (value_at(m1, r, 2) * value_at(m2, 2, c)) +
        (value_at(m1, r, 3) * value_at(m2, 3, c))
      end
    end
    |> List.flatten
    |> List.to_tuple
  end

  @spec put_value(matrix4x4, integer(), integer(), float()) :: float()
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 0, 0, value), do: put_elem(m,  0, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 0, 1, value), do: put_elem(m,  1, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 0, 2, value), do: put_elem(m,  2, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 0, 3, value), do: put_elem(m,  3, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 1, 0, value), do: put_elem(m,  4, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 1, 1, value), do: put_elem(m,  5, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 1, 2, value), do: put_elem(m,  6, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 1, 3, value), do: put_elem(m,  7, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 2, 0, value), do: put_elem(m,  8, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 2, 1, value), do: put_elem(m,  9, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 2, 2, value), do: put_elem(m, 10, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 2, 3, value), do: put_elem(m, 11, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 3, 0, value), do: put_elem(m, 12, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 3, 1, value), do: put_elem(m, 13, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 3, 2, value), do: put_elem(m, 14, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}, 3, 3, value), do: put_elem(m, 15, value)

  @spec put_value(matrix3x3, integer(), integer(), float()) :: float()
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 0, 0, value), do: put_elem(m, 0, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 0, 1, value), do: put_elem(m, 1, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 0, 2, value), do: put_elem(m, 2, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 1, 0, value), do: put_elem(m, 3, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 1, 1, value), do: put_elem(m, 4, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 1, 2, value), do: put_elem(m, 5, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 2, 0, value), do: put_elem(m, 6, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 2, 1, value), do: put_elem(m, 7, value)
  def put_value(m = {_, _, _, _, _, _, _, _, _}, 2, 2, value), do: put_elem(m, 8, value)

  @spec put_value(matrix2x2, integer(), integer(), float()) :: float()
  def put_value(m = {_, _, _, _}, 0, 0, value), do: put_elem(m, 0, value)
  def put_value(m = {_, _, _, _}, 0, 1, value), do: put_elem(m, 1, value)
  def put_value(m = {_, _, _, _}, 1, 0, value), do: put_elem(m, 2, value)
  def put_value(m = {_, _, _, _}, 1, 1, value), do: put_elem(m, 3, value)

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
