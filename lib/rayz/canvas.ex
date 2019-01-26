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


  def canvas_to_ppm(canvas, file_name \\ "rayz.ppm") do
    output_file = open_file("rayz.ppm")
    header      = ppm_header(canvas)
    body        = ppm_body(canvas)

    IO.binwrite(output_file, header)
    IO.binwrite(output_file, body)

    File.close(output_file)
  end

  def open_file(file) do
    file
    |> File.open([:write])
    |> file_helper()
  end

  defp file_helper({:ok, file}), do: file
  defp file_helper({:error, reason}) do
    IO.puts "Error: #{reason}"
    exit(:error)
  end

  def ppm_body(canvas) do
    result = canvas.pixels
             |> Enum.map(fn color -> "#{clamp(color.red)} #{clamp(color.green)} #{clamp(color.blue)} " end)
             |> Enum.chunk_every(canvas.width)
             |> Enum.intersperse("\n")
             |> List.flatten
             |> List.to_string


    Regex.replace(~r/( \n| $)/, result, "\n")
    # TODO add newline at 70 characters if it was a space
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

  def ppm_header(canvas, max_color_value \\ 255) do
    """
    P3
    #{canvas.width} #{canvas.height}
    #{max_color_value}
    """
  end

  # TODO implement out of bounds
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
