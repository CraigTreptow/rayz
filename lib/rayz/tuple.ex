defmodule Rayz.Tuple do
  @moduledoc """
  Documentation for Rayz.Tuple.
  """

  @doc """
      iex> Builder.tuple(1.1, 2.2, 3.3, 0)
      %Rayz.Tuple{w: 0, x: 1.1, y: 2.2, z: 3.3}
  """

  defstruct(
    x: 0.0,
    y: 0.0,
    z: 0.0,
    w: 0.0
  )

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}

  @spec normalize(rayztuple) :: rayztuple
  def normalize(vector) do
    m = magnitude(vector)
    %Rayz.Tuple{
      x: vector.x / m,
      y: vector.y / m,
      z: vector.z / m,
      w: vector.w / m
    }
  end

  @spec magnitude(rayztuple) :: float()
  def magnitude(vector) do
    x2 = vector.x * vector.x
    y2 = vector.y * vector.y
    z2 = vector.z * vector.z
    w2 = vector.w * vector.w

    # have to use Erlang's math library
    :math.sqrt(x2 + y2 + z2 + w2)
  end

  @spec divide(rayztuple, float()) :: rayztuple
  def divide(tuple, scalar) do
    %Rayz.Tuple{
      x: tuple.x / scalar,
      y: tuple.y / scalar,
      z: tuple.z / scalar,
      w: tuple.w / scalar
    }
  end

  @spec multiply(rayztuple, float()) :: rayztuple
  def multiply(tuple, scalar) do
    %Rayz.Tuple{
      x: tuple.x * scalar,
      y: tuple.y * scalar,
      z: tuple.z * scalar,
      w: tuple.w * scalar
    }
  end

  @spec negate(rayztuple) :: rayztuple
  def negate(tuple) do
    %Rayz.Tuple{
      x: -tuple.x,
      y: -tuple.y,
      z: -tuple.z,
      w: -tuple.w
    }
  end

  @spec subtract(rayztuple, rayztuple) :: rayztuple
  def subtract(tuple1, tuple2) do
    %Rayz.Tuple{
      x: tuple1.x - tuple2.x,
      y: tuple1.y - tuple2.y,
      z: tuple1.z - tuple2.z,
      w: tuple1.w - tuple2.w
    }
  end

  @spec add(rayztuple, rayztuple) :: rayztuple
  def add(tuple1, tuple2) do
    %Rayz.Tuple{
      x: tuple1.x + tuple2.x,
      y: tuple1.y + tuple2.y,
      z: tuple1.z + tuple2.z,
      w: tuple1.w + tuple2.w
    }
  end

  @spec equal?(rayztuple, rayztuple) :: boolean()
  def equal?(tuple1, tuple2) do
    Util.equal?(tuple1.x, tuple2.x) &&
    Util.equal?(tuple1.y, tuple2.y) &&
    Util.equal?(tuple1.z, tuple2.z) &&
    Util.equal?(tuple1.w, tuple2.w)
  end

  @spec is_point?(rayztuple) :: boolean()
  def is_point?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: 1.0}), do: true
  def is_point?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: _}),   do: false

  @spec is_vector?(rayztuple) :: boolean()
  def is_vector?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: 0.0}), do: true
  def is_vector?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: _}),   do: false
end
