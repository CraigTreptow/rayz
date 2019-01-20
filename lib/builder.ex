defmodule Builder do
  @moduledoc """
  Documentation for Builder.
  """

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  
  @spec tuple(float(), float(), float(), float()) :: rayztuple
  def tuple(x, y, z, w), do: %Rayz.Tuple{x: x, y: y, z: z, w: w}

  @spec point(float(), float(), float()) :: rayztuple
  def point(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 1.0}

  @spec vector(float(), float(), float()) :: rayztuple
  def vector(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 0.0}
end
