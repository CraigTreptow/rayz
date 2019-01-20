defmodule Rayz.PPM do
  @moduledoc """
  Provides PPM(Portable Pixmap) file format specific functions
  """

  def body(canvas) do
    # a set of three numbers per canvas.x
    # a row per canvas.y

    raw_body = body_helper(canvas)

    raw_body
    |> List.flatten
    |> Rayz.Util.insert_at_every(canvas.x, fn -> "\n" end)
    |> List.to_string
    |> String.replace(" \n", "\n")
  end

  def body_helper(canvas) do
    for y <- 0..canvas.y - 1 do
      for x <- 0..canvas.x - 1 do
        clamped_red  = clamp(canvas[x][y].red)
        clamped_green = clamp(canvas[x][y].green)
        clamped_blue  = clamp(canvas[x][y].blue)
        "#{clamped_red} #{clamped_green} #{clamped_blue} "
      end
    end
  end

  def clamp(color_value, min_value \\ 0, max_value \\ 255) do
    adjusted_value = color_value * (max_value + 0.99)

    cond do
      adjusted_value < min_value ->
        0
      adjusted_value > max_value ->
        255
      true ->
        Kernel.round(adjusted_value)
    end
  end

  def header(canvas, max_color_value \\ 255) do
    """
    P3
    #{canvas.x} #{canvas.y}
    #{max_color_value}
    """
  end
end
