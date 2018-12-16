defmodule Rayz.Canvas do
  @moduledoc """
  Provides a Canvas
  """

  def canvas_to_ppm(canvas) do
    output_file = open_file("rayz.ppm")

    header = Rayz.PPM.header(canvas)
    body = Rayz.PPM.body(canvas)

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

  def create_canvas(x, y) do
    black = Rayz.Color.new_color(0, 0, 0)
    create_canvas_helper(%{x: x, y: y}, x, y, black)
  end

  defp create_canvas_helper(map, -1, _, _color), do: map
  defp create_canvas_helper(map, x, y, color) do
    row = build_row(%{}, y - 1, color)
    updated_map = Map.put(map, x - 1, row)
    create_canvas_helper(updated_map, x - 1, y, color)
  end

  def build_row(map, -1, _color), do: map
  def build_row(map, y, color) do
    updated_map = Map.put(map, y, color)
    build_row(updated_map, y - 1, color)
  end

  def pixel_at(canvas, x, y) do
    canvas[x][y]
  end

  def write_pixel(_canvas, _x, -1, _color), do: {:error, "y out of bounds"}
  def write_pixel(_canvas, -1, _y, _color), do: {:error, "x out of bounds"}
  def write_pixel(canvas, x, y, color) do
    put_in(canvas[x][y], color)
  end
end
