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

  def normal_at(_sphere, p) do
    o = Builder.point(0, 0, 0)
    # Note that, because this is a unit sphere, the vector will be normalized by
    # default for any point on its surface, so it’s not strictly necessary to 
    # explicitly normalize it here.)

    p
    |> Rayz.Tuple.subtract(o)
    |> Rayz.Tuple.normalize()

  end

  def set_transform(sphere, transform) do
    Map.put(sphere, :transform, transform)
  end
end
