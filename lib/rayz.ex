defmodule Rayz do
  @moduledoc """
  Documentation for Rayz.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Rayz.new_point(-1.0, 2.0, 3.0)
      %Rayz.Tuple{w: 1.0, x: -1.0, y: 2.0, z: 3.0}

      iex> Rayz.new_vector(1.0, 2.0, -3.0)
      %Rayz.Tuple{w: 0.0, x: 1.0, y: 2.0, z: -3.0}

  """
  def new_point(x, y, z) do
    Rayz.Tuple.new_point(x, y, z)
  end

  def new_vector(x, y, z) do
    Rayz.Tuple.new_vector(x, y, z)
  end
end
