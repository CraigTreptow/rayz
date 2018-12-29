defmodule Rayz.Clock do
  @moduledoc """
  Attempts to plot points and make a clock face
  """

  def doit() do
    red    = Rayz.Color.new_color(1, 0, 0)
    canvas = Rayz.Canvas.new_canvas(10, 10)
    origin = Rayz.Tuple.new_point(5, 5, 5)
    twelve = Rayz.Tuple.new_point(0, 0, 1)

    rotation = Rayz.Matrix4x4.rotation_y(3 * (:math.pi() / 6))
    three = Rayz.Matrix4x4.multiply_tuple(twelve, rotation)

    canvas
    |> Rayz.Canvas.write_pixel(origin.x, origin.y, red)
    |> Rayz.Canvas.write_pixel(Kernel.round(twelve.x), Kernel.round(twelve.y), red)
    |> Rayz.Canvas.write_pixel(Kernel.round(three.x), Kernel.round(three.y), red)
    |> Rayz.Canvas.canvas_to_ppm
  end
end
