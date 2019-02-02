defmodule Mix.Tasks.Clock do
  use Mix.Task

  @shortdoc "Generates a clock face"
  @moduledoc @shortdoc

  @impl Mix.Task
  def run(_args) do
    clock()
  end

  def clock() do
    size  = 100
    half_size = Kernel.round(size / 2)
    canvas = Builder.canvas(size, size)
    origin = Builder.point(half_size, half_size, half_size)
    red    = Builder.color(1, 0, 0)
    green  = Builder.color(0, 1, 0)
    radius = (3 / 8) * size

    canvas = Rayz.Canvas.write_pixel(canvas, origin.x, origin.y, green)

    1..12
    |> Enum.to_list
    |> Enum.map(fn hour -> compute_point(hour, size, origin, radius) end)
    |> update_canvas(canvas, red)
    |> Rayz.Canvas.canvas_to_ppm

    IO.puts("Assuming OSX, opening PPM file for you")
    System.cmd("open", ["rayz.ppm"])
  end

  def update_canvas([], canvas, _color), do: canvas
  def update_canvas([head | tail], canvas, color) do
    new_canvas = Rayz.Canvas.write_pixel(canvas, head.x, head.y, color)
    update_canvas(tail, new_canvas, color)
  end

  def compute_point(hour, size, origin, radius) do
    point = 
      hour
      |> compute_rotation
      |> compute_point(origin, radius)
    %{x: Kernel.round(point.x), y: size - Kernel.round(point.z)}
  end

  defp compute_rotation(hour) do
    Builder.rotation_y(hour * (:math.pi() / 6))
  end

  defp compute_point(rotation, origin, radius) do
    twelve = Builder.point(0, 0, 1)

    rotation
    |> Rayz.Matrix.multiply(twelve)
    |> apply_radius(radius)
    |> move_to_center(origin)
  end

  defp move_to_center(point, origin) do
    Builder.point(point.x + origin.x, point.y + origin.y, point.z + origin.z)
  end

  defp apply_radius(point, radius) do
    Builder.point(point.x * radius, point.y, point.z * radius)
  end
end
