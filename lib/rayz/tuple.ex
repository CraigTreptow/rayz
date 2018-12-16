defmodule Rayz.Tuple do
  @moduledoc """
  Provides a Tuple
  """

  alias Rayz.Epsilon, as: Epsilon

  defstruct(
    x: 0.0,
    y: 0.0,
    z: 0.0,
    w: 1.0
  )

  # vectors only
  @spec cross_product(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }) :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def cross_product(vector_a, vector_b) do
    Rayz.Tuple.new_vector(
      vector_a.y * vector_b.z - vector_a.z * vector_b.y,
      vector_a.z * vector_b.x - vector_a.x * vector_b.z,
      vector_a.x * vector_b.y - vector_a.y * vector_b.x
    )
  end

  # aka scalar or inner product
  # vectors only
  @spec dot_product(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }) :: integer()
  def dot_product(tuple1, tuple2) do
    tuple1.x * tuple2.x + tuple1.y * tuple2.y + tuple1.z * tuple2.z + tuple1.w * tuple2.w
  end

  @spec divide(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, integer()) ::
          %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def normalize(vector) do
    m = magnitude(vector)

    %Rayz.Tuple{
      x: vector.x / m,
      y: vector.y / m,
      z: vector.z / m,
      w: vector.w / m
    }
  end

  @spec magnitude(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}) :: integer()
  def magnitude(vector) do
    x_total = vector.x * vector.x
    y_total = vector.y * vector.y
    z_total = vector.z * vector.z
    w_total = vector.w * vector.w

    # have to use Erlang's math library
    :math.sqrt(x_total + y_total + z_total + w_total)
  end

  @spec divide(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, integer()) ::
          %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def divide(tuple, scalar) do
    %Rayz.Tuple{
      x: tuple.x / scalar,
      y: tuple.y / scalar,
      z: tuple.z / scalar,
      w: tuple.w / scalar
    }
  end

  @spec multiply(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, integer()) ::
          %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def multiply(tuple, scalar) do
    %Rayz.Tuple{
      x: tuple.x * scalar,
      y: tuple.y * scalar,
      z: tuple.z * scalar,
      w: tuple.w * scalar
    }
  end

  @spec negate(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}) :: %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }
  def negate(tuple) do
    %Rayz.Tuple{
      x: 0 - tuple.x,
      y: 0 - tuple.y,
      z: 0 - tuple.z,
      w: 0 - tuple.w
    }
  end

  @spec subtract(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }) :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def subtract(tuple1, tuple2) do
    %Rayz.Tuple{
      x: tuple1.x - tuple2.x,
      y: tuple1.y - tuple2.y,
      z: tuple1.z - tuple2.z,
      w: tuple1.w - tuple2.w
    }
  end

  @spec add(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }) :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  def add(tuple1, tuple2) do
    %Rayz.Tuple{
      x: tuple1.x + tuple2.x,
      y: tuple1.y + tuple2.y,
      z: tuple1.z + tuple2.z,
      w: tuple1.w + tuple2.w
    }
  end

  @spec new_point(float(), float(), float()) :: %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }
  def new_point(x, y, z) do
    %Rayz.Tuple{x: x, y: y, z: z, w: 1.0}
  end

  @spec new_vector(float(), float(), float()) :: %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }
  def new_vector(x, y, z) do
    %Rayz.Tuple{x: x, y: y, z: z, w: 0.0}
  end

  @spec equal?(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}, %Rayz.Tuple{
          x: float(),
          y: float(),
          z: float(),
          w: float()
        }) :: boolean()
  def equal?(tuple1, tuple2) do
    Epsilon.equal?(tuple1.x, tuple2.x) && Epsilon.equal?(tuple1.y, tuple2.y) &&
      Epsilon.equal?(tuple1.z, tuple2.z) && Epsilon.equal?(tuple1.w, tuple2.w)
  end

  @spec point?(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}) :: boolean()
  def point?(tuple) do
    Epsilon.equal?(tuple.w, 1.0)
  end

  @spec vector?(%Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}) :: boolean()
  def vector?(tuple) do
    Epsilon.equal?(tuple.w, 0.0)
  end
end
