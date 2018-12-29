defmodule Rayz.Matrix4x4 do
  alias Rayz.Epsilon, as: Epsilon
  require Integer

  @moduledoc """
  Provides a 4x4 Matrix

  a_a a_b a_c a_d
  b_a b_b b_c b_d
  c_a c_b c_c c_d
  d_a d_b d_c d_d
  """

  @type matrix4x4() ::
    {
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float()
    }

  def shearing(xy, xz, yx, yz, zx, zy) do
    # tu -> t in proportion to u

    Rayz.Matrix4x4.new_matrix(
      1,  xy, xz, 0,
      yx, 1,  yz, 0,
      zx, zy, 1,  0,
      0,  0,  0,  1
    )
  end

  def rotation_z(radians) do
    c  = :math.cos(radians)
    s  = :math.sin(radians)
    ns = s * -1

    Rayz.Matrix4x4.new_matrix(
      c, ns, 0, 0,
      s, c,  0, 0,
      0, 0,  1, 0,
      0, 0,  0, 1
    )
  end

  def rotation_y(radians) do
    c  = :math.cos(radians)
    s  = :math.sin(radians)
    ns = s * -1

    Rayz.Matrix4x4.new_matrix(
      c,  0, s, 0,
      0,  1, 0, 0,
      ns, 0, c, 0,
      0,  0, 0, 1
    )
  end

  def rotation_x(radians) do
    c  = :math.cos(radians)
    s  = :math.sin(radians)
    ns = s * -1

    Rayz.Matrix4x4.new_matrix(
      1, 0, 0,  0,
      0, c, ns, 0,
      0, s, c,  0,
      0, 0, 0,  1
    )
  end

  def scaling(x, y, z) do
    Rayz.Matrix4x4.new_matrix(
      x, 0, 0, 0,
      0, y, 0, 0,
      0, 0, z, 0,
      0, 0, 0, 1
    )
  end

  def translation(x, y, z) do
    Rayz.Matrix4x4.new_matrix(
      1, 0, 0, x,
      0, 1, 0, y,
      0, 0, 1, z,
      0, 0, 0, 1
    )
  end

  def inverse(m) do
    if invertible?(m) do
      d = determinant(m)

      t = for r <- 0..3 do
            for c <- 0..3 do
              cf = cofactor(m, r, c)
              # note that "col, row" here, instead of "row, col",
              # accomplishes the transpose operation!
              cf / d
            end
          end
      |> List.flatten
      |> List.to_tuple

      Rayz.Matrix4x4.new_matrix(
        elem(t, 0),
        elem(t, 4),
        elem(t, 8),
        elem(t, 12),

        elem(t, 1),
        elem(t, 5),
        elem(t, 9),
        elem(t, 13),

        elem(t, 2),
        elem(t, 6),
        elem(t, 10),
        elem(t, 14),

        elem(t, 3),
        elem(t, 7),
        elem(t, 11),
        elem(t, 15)
      )

    else
      {:error, "not invertible"}
    end
  end

  def invertible?(m) do
    if determinant(m) == 0 do
      false
    else
      true
    end
  end

  def determinant(m) do
    m = Rayz.Matrix4x4.new_matrix(
      value_at(m, 0, 0), 
      value_at(m, 0, 1), 
      value_at(m, 0, 2), 
      value_at(m, 0, 3), 
      value_at(m, 1, 0), 
      value_at(m, 1, 1), 
      value_at(m, 1, 2), 
      value_at(m, 1, 3), 
      value_at(m, 2, 0), 
      value_at(m, 2, 1), 
      value_at(m, 2, 2),
      value_at(m, 2, 3),
      value_at(m, 3, 0), 
      value_at(m, 3, 1), 
      value_at(m, 3, 2),
      value_at(m, 3, 3)
    ) 

    (value_at(m, 0, 0) * cofactor(m, 0, 0)) +
    (value_at(m, 0, 1) * cofactor(m, 0, 1)) +
    (value_at(m, 0, 2) * cofactor(m, 0, 2)) +
    (value_at(m, 0, 3) * cofactor(m, 0, 3))
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
    |> Rayz.Matrix3x3.determinant
  end

  def submatrix({
                  _a0, _a1, _a2, _a3,
                  _b0, b1, b2, b3,
                  _c0, c1, c2, c3,
                  _d0, d1, d2, d3
                }, 0, 0) do
    Rayz.Matrix3x3.new_matrix(b1, b2, b3, c1, c2, c3, d1, d2, d3)
  end

  def submatrix({
                  _a0, _a1, _a2, _a3,
                  b0, _b1, b2, b3,
                  c0, _c1, c2, c3,
                  d0, _d1, d2, d3
                }, 0, 1) do
    Rayz.Matrix3x3.new_matrix(b0, b2, b3, c0, c2, c3, d0, d2, d3)
  end

  def submatrix({
                  _a0, _a1, _a2, _a3,
                  b0, b1, _b2, b3,
                  c0, c1, _c2, c3,
                  d0, d1, _d2, d3
                }, 0, 2) do
    Rayz.Matrix3x3.new_matrix(b0, b1, b3, c0, c1, c3, d0, d1, d3)
  end

  def submatrix({
                  _a0, _a1, _a2, _a3,
                  b0, b1, b2, _b3,
                  c0, c1, c2, _c3,
                  d0, d1, d2, _d3
                }, 0, 3) do
    Rayz.Matrix3x3.new_matrix(b0, b1, b2, c0, c1, c2, d0, d1, d2)
  end

  def submatrix({
                  _a0, a1, a2, a3,
                  _b0, _b1, _b2, _b3,
                  _c0, c1, c2, c3,
                  _d0, d1, d2, d3
                }, 1, 0) do
    Rayz.Matrix3x3.new_matrix(a1, a2, a3, c1, c2, c3, d1, d2, d3)
  end

  def submatrix({
                  a0, _a1, a2, a3,
                  _b0, _b1, _b2, _b3,
                  c0, _c1, c2, c3,
                  d0, _d1, d2, d3
                }, 1, 1) do
    Rayz.Matrix3x3.new_matrix(a0, a2, a3, c0, c2, c3, d0, d2, d3)
  end

  def submatrix({
                  a0, a1, _a2, a3,
                  _b0, _b1, _b2, _b3,
                  c0, c1, _c2, c3,
                  d0, d1, _d2, d3
                }, 1, 2) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a3, c0, c1, c3, d0, d1, d3)
  end

  def submatrix({
                  a0, a1, a2, _a3,
                  _b0, _b1, _b2, _b3,
                  c0, c1, c2, _c3,
                  d0, d1, d2, _d3
                }, 1, 3) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a2, c0, c1, c2, d0, d1, d2)
  end

  def submatrix({
                  _a0, a1, a2, a3,
                  _b0, b1, b2, b3,
                  _c0, _c1, _c2, _c3,
                  _d0, d1, d2, d3
                }, 2, 0) do
    Rayz.Matrix3x3.new_matrix(a1, a2, a3, b1, b2, b3, d1, d2, d3)
  end

  def submatrix({
                  a0, _a1, a2, a3,
                  b0, _b1, b2, b3,
                  _c0, _c1, _c2, _c3,
                  d0, _d1, d2, d3
                }, 2, 1) do
    Rayz.Matrix3x3.new_matrix(a0, a2, a3, b0, b2, b3, d0, d2, d3)
  end

  def submatrix({
                  a0, a1, _a2, a3,
                  b0, b1, _b2, b3,
                  _c0, _c1, _c2, _c3,
                  d0, d1, _d2, d3
                }, 2, 2) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a3, b0, b1, b3, d0, d1, d3)
  end

  def submatrix({
                  a0, a1, a2, _a3,
                  b0, b1, b2, _b3,
                  _c0, _c1, _c2, _c3,
                  d0, d1, d2, _d3
                }, 2, 3) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a2, b0, b1, b2, d0, d1, d2)
  end

  def submatrix({
                  _a0, a1, a2, a3,
                  _b0, b1, b2, b3,
                  _c0, c1, c2, c3,
                  _d0, _d1, _d2, _d3
                }, 3, 0) do
    Rayz.Matrix3x3.new_matrix(a1, a2, a3, b1, b2, b3, c1, c2, c3)
  end

  def submatrix({
                  a0, _a1, a2, a3,
                  b0, _b1, b2, b3,
                  c0, _c1, c2, c3,
                  _d0, _d1, _d2, _d3
                }, 3, 1) do
    Rayz.Matrix3x3.new_matrix(a0, a2, a3, b0, b2, b3, c0, c2, c3)
  end

  def submatrix({
                  a0, a1, _a2, a3,
                  b0, b1, _b2, b3,
                  c0, c1, _c2, c3,
                  _d0, _d1, _d2, _d3
                }, 3, 2) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a3, b0, b1, b3, c0, c1, c3)
  end

  def submatrix({
                  a0, a1, a2, _a3,
                  b0, b1, b2, _b3,
                  c0, c1, c2, _c3,
                  _d0, _d1, _d2, _d3
                }, 3, 3) do
    Rayz.Matrix3x3.new_matrix(a0, a1, a2, b0, b1, b2, c0, c1, c2)
  end

  def transpose({
    a0, a1, a2, a3,
    b0, b1, b2, b3,
    c0, c1, c2, c3,
    d0, d1, d2, d3
    }) do

    {
      a0, b0, c0, d0,
      a1, b1, c1, d1,
      a2, b2, c2, d2,
      a3, b3, c3, d3
    }
  end

  def identity do
    {
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1
    }
  end

  def multiply_tuple(t, m) do
    new_t = for r <- 0..3 do
              (value_at(m, r, 0) * t.x) +
              (value_at(m, r, 1) * t.y) +
              (value_at(m, r, 2) * t.z) +
              (value_at(m, r, 3) * t.w)
            end
            |> List.flatten
            |> List.to_tuple
    Rayz.Tuple.new_tuple(elem(new_t, 0), elem(new_t, 1), elem(new_t, 2), elem(new_t, 3))
  end

  def multiply(m1, m2) do
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

  def equal?(m1, m2) do
    Epsilon.equal?(value_at(m1, 0, 0), value_at(m2, 0, 0)) &&
    Epsilon.equal?(value_at(m1, 0, 1), value_at(m2, 0, 1)) &&
    Epsilon.equal?(value_at(m1, 0, 2), value_at(m2, 0, 2)) &&
    Epsilon.equal?(value_at(m1, 0, 3), value_at(m2, 0, 3)) &&
    Epsilon.equal?(value_at(m1, 1, 0), value_at(m2, 1, 0)) &&
    Epsilon.equal?(value_at(m1, 1, 1), value_at(m2, 1, 1)) &&
    Epsilon.equal?(value_at(m1, 1, 2), value_at(m2, 1, 2)) &&
    Epsilon.equal?(value_at(m1, 1, 3), value_at(m2, 1, 3)) &&
    Epsilon.equal?(value_at(m1, 2, 0), value_at(m2, 2, 0)) &&
    Epsilon.equal?(value_at(m1, 2, 1), value_at(m2, 2, 1)) &&
    Epsilon.equal?(value_at(m1, 2, 2), value_at(m2, 2, 2)) &&
    Epsilon.equal?(value_at(m1, 2, 3), value_at(m2, 2, 3)) &&
    Epsilon.equal?(value_at(m1, 3, 0), value_at(m2, 3, 0)) &&
    Epsilon.equal?(value_at(m1, 3, 1), value_at(m2, 3, 1)) &&
    Epsilon.equal?(value_at(m1, 3, 2), value_at(m2, 3, 2)) &&
    Epsilon.equal?(value_at(m1, 3, 3), value_at(m2, 3, 3))
  end

  def value_at(matrix, 0, 0), do: elem(matrix, 0)
  def value_at(matrix, 0, 1), do: elem(matrix, 1)
  def value_at(matrix, 0, 2), do: elem(matrix, 2)
  def value_at(matrix, 0, 3), do: elem(matrix, 3)
  def value_at(matrix, 1, 0), do: elem(matrix, 4)
  def value_at(matrix, 1, 1), do: elem(matrix, 5)
  def value_at(matrix, 1, 2), do: elem(matrix, 6)
  def value_at(matrix, 1, 3), do: elem(matrix, 7)
  def value_at(matrix, 2, 0), do: elem(matrix, 8)
  def value_at(matrix, 2, 1), do: elem(matrix, 9)
  def value_at(matrix, 2, 2), do: elem(matrix, 10)
  def value_at(matrix, 2, 3), do: elem(matrix, 11)
  def value_at(matrix, 3, 0), do: elem(matrix, 12)
  def value_at(matrix, 3, 1), do: elem(matrix, 13)
  def value_at(matrix, 3, 2), do: elem(matrix, 14)
  def value_at(matrix, 3, 3), do: elem(matrix, 15)

  @spec new_matrix(
          float(), float(), float(), float(),
          float(), float(), float(), float(),
          float(), float(), float(), float(),
          float(), float(), float(), float()
        ) :: matrix4x4()
  def new_matrix(a_a, a_b, a_c, a_d, b_a, b_b, b_c, b_d, c_a, c_b, c_c, c_d, d_a, d_b, d_c, d_d) do
    {
      a_a, a_b, a_c, a_d,
      b_a, b_b, b_c, b_d,
      c_a, c_b, c_c, c_d,
      d_a, d_b, d_c, d_d
    }
  end
end
