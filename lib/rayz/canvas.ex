defmodule Rayz.Canvas do
  @moduledoc """
  Provides a Canvas

  0 --- x
  |
  |
  |
  y

  """

  def canvas_to_ppm(canvas) do
    output_file = open_file("rayz.ppm")
    header      = Rayz.PPM.header(canvas)
    body        = Rayz.PPM.body(canvas)

    IO.binwrite(output_file, header)
    IO.binwrite(output_file, body)

    File.close(output_file)
  end

  def open_file(file_name) do
    file_name
    |> File.open([:write])
    |> file_helper()
  end

  defp file_helper({:ok, file}), do: file
  defp file_helper({:error, reason}) do
    IO.puts "Error: #{reason}"
    exit(:error)
  end

  def new_canvas(x, y) do
    black = Rayz.Color.new_color(0, 0, 0)
    new_canvas_helper(%{x: x, y: y}, x, y, black)
  end

  defp new_canvas_helper(map, 0, _, _color), do: map
  defp new_canvas_helper(map, x, y, color) do
    row = build_row(%{}, y, color)
    updated_map = Map.put(map, x - 1, row)
    new_canvas_helper(updated_map, x - 1, y, color)
  end

  def build_row(map, 0, _color), do: map
  def build_row(map, y, color) do
    updated_map = Map.put(map, y - 1, color)
    build_row(updated_map, y - 1, color)
  end

  def pixel_at(canvas, x, y) do
    canvas[x][y]
  end

  def write_pixel(canvas, x, y, color) do
    cond do
      x < 0 ->
        canvas
      x > canvas.x ->
        canvas
      y < 0 ->
        canvas
      y > canvas.y ->
        canvas
      true ->
        put_in(canvas[x][y], color)
    end
  end
end
