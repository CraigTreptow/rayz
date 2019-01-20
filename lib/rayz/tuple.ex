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

  def is_point?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: 1.0}), do: true
  def is_point?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: _}),   do: false

  def is_vector?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: 0}), do: true
  def is_vector?(%Rayz.Tuple{x: _x, y: _y, z: _z, w: _}), do: false

end
