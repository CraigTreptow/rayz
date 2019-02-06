defmodule Rayz.Ray do
  @moduledoc """
  Documentation for Rayz.Ray.
  """

  @doc """
      iex> origin = Builder.point(1, 2, 3)
      %Rayz.Tuple{w: 1.0, x: 1, y: 2, z: 3}
      iex> direction = Builder.vector(4, 5, 6)
      %Rayz.Tuple{w: 0.0, x: 4, y: 5, z: 6}
      iex> Builder.ray(origin, direction)
      %Rayz.Ray{
          direction: %Rayz.Tuple{w: 0.0, x: 4, y: 5, z: 6},
          origin: %Rayz.Tuple{w: 1.0, x: 1, y: 2, z: 3}
      }
  """

  defstruct(
    origin:    nil,
    direction: nil
  )

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type ray :: %Rayz.Ray{origin: rayztuple(), direction: rayztuple()}
  @type matrix4x4() :: 
    {
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float(),
      float(), float(), float(), float()
    }


  @spec transform(ray(), matrix4x4()) :: rayztuple()
  def transform(ray, transformation) do
    Builder.ray(
      Rayz.Matrix.multiply(transformation, ray.origin),
      Rayz.Matrix.multiply(transformation, ray.direction)
    )
  end

  @spec position(ray(), float()) :: rayztuple()
  def position(ray, time) do
    Rayz.Tuple.multiply(ray.direction, time)
    |> Rayz.Tuple.add(ray.origin)
  end
end
