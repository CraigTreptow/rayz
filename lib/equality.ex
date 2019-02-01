defmodule Equality do
  @moduledoc """
  Documentation for Equality.
  """

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type color :: %Rayz.Color{red: float(), green: float(), blue: float()}
  @type canvas :: %Rayz.Canvas{width: integer(), height: integer()}
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

  @spec equal?(matrix4x4(), matrix4x4()) :: boolean()
  def equal?(
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
    Util.equal?(Rayz.Matrix.value_at(m1, 0, 0), Rayz.Matrix.value_at(m2, 0, 0)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 0, 1), Rayz.Matrix.value_at(m2, 0, 1)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 0, 2), Rayz.Matrix.value_at(m2, 0, 2)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 0, 3), Rayz.Matrix.value_at(m2, 0, 3)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 1, 0), Rayz.Matrix.value_at(m2, 1, 0)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 1, 1), Rayz.Matrix.value_at(m2, 1, 1)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 1, 2), Rayz.Matrix.value_at(m2, 1, 2)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 1, 3), Rayz.Matrix.value_at(m2, 1, 3)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 2, 0), Rayz.Matrix.value_at(m2, 2, 0)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 2, 1), Rayz.Matrix.value_at(m2, 2, 1)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 2, 2), Rayz.Matrix.value_at(m2, 2, 2)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 2, 3), Rayz.Matrix.value_at(m2, 2, 3)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 3, 0), Rayz.Matrix.value_at(m2, 3, 0)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 3, 1), Rayz.Matrix.value_at(m2, 3, 1)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 3, 2), Rayz.Matrix.value_at(m2, 3, 2)) &&
    Util.equal?(Rayz.Matrix.value_at(m1, 3, 3), Rayz.Matrix.value_at(m2, 3, 3))
  end

  @spec equal?(matrix3x3(), matrix3x3()) :: boolean()
  def equal?(
    {
      m1_a_a, m1_a_b, m1_a_c,
      m1_b_a, m1_b_b, m1_b_c,
      m1_c_a, m1_c_b, m1_c_c
    },
    {
      m2_a_a, m2_a_b, m2_a_c,
      m2_b_a, m2_b_b, m2_b_c,
      m2_c_a, m2_c_b, m2_c_c,
    }
  ) do
    m1_a_a == m2_a_a && m1_a_b == m2_a_b && m1_a_c == m2_a_c &&
    m1_b_a == m2_b_a && m1_b_b == m2_b_b && m1_b_c == m2_b_c &&
    m1_c_a == m2_c_a && m1_c_b == m2_c_b && m1_c_c == m2_c_c
  end

  @spec equal?(matrix2x2(), matrix2x2()) :: boolean()
  def equal?(
    {
      m1_a_a, m1_a_b,
      m1_b_a, m1_b_b
    },
    {
      m2_a_a, m2_a_b,
      m2_b_a, m2_b_b
    }
  ) do
    m1_a_a == m2_a_a && m1_a_b == m2_a_b &&
    m1_b_a == m2_b_a && m1_b_b == m2_b_b
  end

  @spec equal?(rayztuple(), rayztuple()) :: boolean()
  def equal?(tuple1, tuple2) do
    Util.equal?(tuple1.x, tuple2.x) &&
    Util.equal?(tuple1.y, tuple2.y) &&
    Util.equal?(tuple1.z, tuple2.z) &&
    Util.equal?(tuple1.w, tuple2.w)
  end
end
