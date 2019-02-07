defmodule Mix.Tasks.Sphere do
  use Mix.Task

  @shortdoc "Cast rays at a sphere"
  @moduledoc @shortdoc

  @canvas_pixels 300

  @impl Mix.Task
  def run(_args) do
    cast()
  end

  def cast() do
    canvas = Builder.canvas(@canvas_pixels, @canvas_pixels)
    red    = Builder.color(1, 0, 0)
    sphere = Builder.sphere()

    rotation_z = Builder.rotation_z(:math.pi / 4)
    scaling   = Builder.scaling(0.5, 1, 1)
    shrink_and_rotate = Rayz.Matrix.multiply(rotation_z, scaling)

    shearing = Builder.shearing(1, 0, 0, 0, 0, 0)
    shear_and_scale = Rayz.Matrix.multiply(shearing, scaling)

    shape =
      sphere
      # shrink it along the y axis
      #|> Rayz.Sphere.set_transform(Builder.scaling(1, 0.5, 1))
      # shrink it along the x-axis
      #|> Rayz.Sphere.set_transform(Builder.scaling(0.5, 1, 1))
      # shrink it, and rotate it!
      #|> Rayz.Sphere.set_transform(shrink_and_rotate)
      # shrink it, and skew it!
      |> Rayz.Sphere.set_transform(shear_and_scale)

    # start the ray at z = -5
    ray_origin = Builder.point(0, 0, -5)

    # put the wall at z = 10
    wall_z     = 10
    wall_size  = 7.0
    pixel_size = wall_size / @canvas_pixels
    # the wall is centered around the origin (because the sphere is at the origin)
    # so 'half' is the minium and maximum x & y coordinates of wall
    half = wall_size / 2

    points = for y <- 1..@canvas_pixels - 1 do
               # compute the world y coordinate (top = +half, bottom = -half)
               world_y = half - pixel_size * y

               world_y
               |> do_row(y, wall_z, half, pixel_size, ray_origin, shape)
               |> Enum.filter(fn r -> r != nil end)
             end

    points
    |> List.flatten
    |> update_canvas(canvas, red)
    |> Rayz.Canvas.canvas_to_ppm

    IO.puts("Assuming OSX, opening PPM file for you")
    System.cmd("open", ["rayz.ppm"])
  end

  def do_row(world_y, y, wall_z, half, pixel_size, ray_origin, shape) do
    for x <- 1..@canvas_pixels - 1 do 
      # compute the world x coordinate (left = -half, right = half)
      world_x = -half + pixel_size * x

      # describe the point on the wall that the ray will target
      new_position =
        world_x
        |> Builder.point(world_y, wall_z)
        |> Rayz.Tuple.subtract(ray_origin)

      r = Builder.ray(ray_origin, Rayz.Tuple.normalize(new_position))

      hit =
        Rayz.Intersection.intersect(shape, r)
        |> Rayz.Intersection.hit()

      if hit != nil do
        %{y: y, x: x }
      end
    end
  end

  def update_canvas([], canvas, _color), do: canvas
  def update_canvas([head|tail], canvas, color) do
    new_canvas = Rayz.Canvas.write_pixel(canvas, head.x, head.y, color)
    update_canvas(tail, new_canvas, color)
  end
end
