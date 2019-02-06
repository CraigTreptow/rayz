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

  def set_transform(sphere, transform) do
    Map.put(sphere, :transform, transform)
  end
end
