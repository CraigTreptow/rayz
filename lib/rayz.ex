defmodule Rayz do
  @moduledoc """
  Documentation for Rayz.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Rayz.point(-1.0, 2.0, 3.0)
      %Rayz.Tuple{w: 1.0, x: -1.0, y: 2.0, z: 3.0}

      iex> Rayz.vector(1.0, 2.0, -3.0)
      %Rayz.Tuple{w: 0.0, x: 1.0, y: 2.0, z: -3.0}

  """
  def point(x,y,z) do
    Rayz.Tuple.point(x,y,z)
  end

  def vector(x,y,z) do
    Rayz.Tuple.vector(x,y,z)
  end
end
