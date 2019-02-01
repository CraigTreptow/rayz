defmodule Mix.Tasks.Cannon do
  use Mix.Task

  @shortdoc "Fires a cannon"
  @moduledoc @shortdoc

  @impl Mix.Task
  def run(_args) do
    fire()
  end

  def fire() do
    projectile  = new_projectile()
    environment = new_environment()
    canvas      = Builder.canvas(900, 550)
    red         = Builder.color(1, 0, 0)


    canvas = tick(canvas, red, environment, projectile)
    Rayz.Canvas.canvas_to_ppm(canvas)

    IO.puts("Assuming OSX, opening PPM file for you")
    System.cmd("open", ["rayz.ppm"])
  end

  def tick(canvas, color, environment, projectile) do
    rounded_position_x = Kernel.round(projectile.position.x)
    rounded_position_y = Kernel.round(projectile.position.y)

    if rounded_position_y < 0 do
      canvas
    else
      new_canvas = Rayz.Canvas.write_pixel(
                     canvas,
                     rounded_position_x,
                     canvas.height - rounded_position_y,
                     color
                    )
      new_environment = Map.put(environment, :ticks, environment.ticks + 1)
      new_position   = projectile.position
                       |> Rayz.Tuple.add(projectile.velocity)
      new_velocity   = projectile.velocity
                       |> Rayz.Tuple.add(environment.gravity)
                       |> Rayz.Tuple.add(environment.wind)
      new_projectile = %{position: new_position, velocity: new_velocity}

      show_position(environment.ticks, new_position)
      tick(new_canvas, color, new_environment, new_projectile)
    end
  end

  def show_position(ticks, position) do
    IO.puts "Tick: #{ticks}"
    IO.puts "X: #{position.x}"
    IO.puts "Y: #{position.y}"
    IO.puts ""
  end

  def new_projectile(multiplier \\ 11.25) do
    # projectile starts one unit above the origin.
    # velocity is normalized to 1 unit/tick.
    initial_position = Builder.point(0, 1, 0)
    v = Builder.vector(1, 1.8, 0)
    initial_velocity = 
      v
      |> Rayz.Tuple.normalize
      |> Rayz.Tuple.multiply(multiplier)

    %{position: initial_position, velocity: initial_velocity}
  end

  def new_environment do
    # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.
    # e ← environment(vector(0, -0.1, 0), vector(-0.01, 0, 0))
    initial_gravity = Builder.vector(0, -0.1, 0)
    initial_wind    = Builder.vector(-0.01, 0, 0)
    %{ticks: 0, gravity: initial_gravity, wind: initial_wind}
  end
end
