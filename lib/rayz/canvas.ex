defmodule Rayz.Canvas do
  @moduledoc """
  Documentation for Rayz.Canvas.
  0 ---> w
  |
  |
  |
  ˇ
  h
  """

  @doc """
      iex> Builder.canvas(1, 2)
      %Rayz.Canvas{
        height: 2,
        pixels: [
              %Rayz.Color{blue: 0, green: 0, red: 0},
              %Rayz.Color{blue: 0, green: 0, red: 0}
            ],
        width: 1
      }
  """

  defstruct(
    width:  0,
    height: 0,
    pixels: []
  )

  @type canvas :: %Rayz.Canvas{width: integer(), height: integer()}
  @type color :: %Rayz.Color{red: float(), green: float(), blue: float()}

  # x < 0 or > w - 1 is out of bounds
  # y < 0 or > h - 1 is out of bounds
  @spec write_pixel(canvas, integer(), integer(), color) :: canvas
  def write_pixel(canvas, x, y, color) do
    index = x + (y * canvas.width)
    new_pixels = List.replace_at(canvas.pixels, index, color)
    Map.put(canvas, :pixels, new_pixels)
  end

  @spec pixel_at(canvas, integer(), integer()) :: color
  def pixel_at(canvas, x, y) do
    index = x + (y * canvas.width)
    Enum.at(canvas.pixels, index)
  end
end
