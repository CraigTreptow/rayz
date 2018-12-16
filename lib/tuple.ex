defmodule Rayz.Tuple do
  @moduledoc """
  Provides a Tuple
  """

  defstruct(
    x: 0.0,
    y: 0.0,
    z: 0.0,
    w: 1.0
  )

  def point(x, y, z) do
    %Rayz.Tuple{x: x, y: y, z: z, w: 1.0}
  end

  def vector(x, y, z) do
    %Rayz.Tuple{x: x, y: y, z: z, w: 0.0}
  end
end
