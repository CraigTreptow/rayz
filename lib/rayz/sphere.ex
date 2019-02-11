defmodule Rayz.Sphere do
  @moduledoc """
  Documentation for Rayz.Sphere
  """

  @doc """
      iex> Builder.sphere()
      %Rayz.Sphere{id: "2CKOL5", transform: {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}}
  """

  defstruct(
    id:        nil,
    transform: nil
  )

  def normal_at(sphere, world_point) do
    # Note that, because this is a unit sphere, the vector will be normalized by
    # default for any point on its surface, so it’s not strictly necessary to 
    # explicitly normalize it here.)

    object_normal =
      sphere.transform
      |> Rayz.Matrix.inverse()
      |> Rayz.Matrix.multiply(world_point)
      |> Rayz.Tuple.subtract(Builder.point(0, 0, 0))

    sphere.transform
    |> Rayz.Matrix.inverse()
    |> Rayz.Matrix.transpose()
    |> Rayz.Matrix.multiply(object_normal)
    |> Map.put(:w, 0)
    |> Rayz.Tuple.normalize()
  end

  def set_transform(sphere, transform) do
    Map.put(sphere, :transform, transform)
  end
end
