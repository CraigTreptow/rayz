defmodule Builder do
  @moduledoc """
  Documentation for Builder.
  """

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type color :: %Rayz.Color{red: float(), green: float(), blue: float()}
  @type canvas :: %Rayz.Canvas{width: integer(), height: integer()}
  
  @spec canvas(integer(), integer()) :: canvas
  def canvas(w, h) do
    black = color(0, 0, 0)
    %Rayz.Canvas{
      width: w,
      height: h,
      pixels: List.duplicate(black, w * h)
    }
  end

  @spec color(float(), float(), float()) :: color
  def color(r, g, b), do: %Rayz.Color{red: r, green: g, blue: b}

  @spec tuple(float(), float(), float(), float()) :: rayztuple
  def tuple(x, y, z, w), do: %Rayz.Tuple{x: x, y: y, z: z, w: w}

  @spec point(float(), float(), float()) :: rayztuple
  def point(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 1.0}

  @spec vector(float(), float(), float()) :: rayztuple
  def vector(x, y, z), do: %Rayz.Tuple{x: x, y: y, z: z, w: 0.0}
end
