defmodule Rayz.Cannon do
  @moduledoc """
  Implements a cannon that uses points and vectors.
  Plots on a canvas, when fire()ed.
  """

  def fire() do
    environment = Rayz.Cannon.new_environment
    projectile  = Rayz.Cannon.new_projectile
    canvas      = Rayz.Canvas.new_canvas(900, 550)
    red         = Rayz.Color.new_color(1, 0, 0)
    canvas      = Rayz.Cannon.tick(canvas, red, environment, projectile)
    Rayz.Canvas.canvas_to_ppm(canvas)
  end

  def new_projectile(multiplier \\ 11.25) do
    velocity =
      Rayz.Tuple.new_vector(1, 1.8, 0)
      |> Rayz.Tuple.normalize()
      |> Rayz.Tuple.multiply(multiplier)

    %{position: Rayz.Tuple.new_point(0, 0, 0), velocity: velocity}
  end

  def new_environment() do
    # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.
    %{
      gravity: Rayz.Tuple.new_vector(0, -0.1, 0),
      wind:    Rayz.Tuple.new_vector(-0.01, 0, 0),
      ticks: 0
    }
  end

  def tick(canvas, color, env, projectile) do
    rounded_position_x = Kernel.round(projectile.position.x)
    rounded_position_y = Kernel.round(projectile.position.y)

    if rounded_position_y < 0 do
      # exit(:normal)
      canvas
    else
      new_canvas = Rayz.Canvas.write_pixel(
                canvas,
                rounded_position_x,
                canvas.y - rounded_position_y,
                color
              )

      new_position =
        projectile.position
        |> Rayz.Tuple.add(projectile.velocity)

      new_velocity =
        projectile.velocity
        |> Rayz.Tuple.add(env.gravity)
        |> Rayz.Tuple.add(env.wind)

      new_env        = Map.put(env, :ticks, env.ticks + 1)
      new_projectile = %{position: new_position, velocity: new_velocity}
      tick(new_canvas, color, new_env, new_projectile)
    end
  end
end
