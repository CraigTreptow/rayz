defmodule Mix.Tasks.Cannon do
  use Mix.Task

  @shortdoc "Fires a canon"
  @moduledoc @shortdoc

  @impl Mix.Task
  def run(_args) do
    # projectile starts one unit above the origin.
    # velocity is normalized to 1 unit/tick.
    initial_position = Builder.point(0, 1, 0)
    initial_velocity = Builder.vector(1, 1, 0) |> Rayz.Tuple.normalize
    projectile       = %{position: initial_position, velocity: initial_velocity}

    # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.
    # e ← environment(vector(0, -0.1, 0), vector(-0.01, 0, 0))
    initial_gravity = Builder.vector(0, -0.1, 0)
    initial_wind    = Builder.vector(-0.01, 0, 0)
    environment     = %{ticks: 0, gravity: initial_gravity, wind: initial_wind}

    tick(environment, projectile)
  end

  def tick(environment, projectile) do
    if projectile.position.y < 0 do
      say_bye()
    else
      new_environment = Map.put(environment, :ticks, environment.ticks + 1)
      new_position   = projectile.position
                       |> Rayz.Tuple.add(projectile.velocity)
      new_velocity   = projectile.velocity
                       |> Rayz.Tuple.add(environment.gravity)
                       |> Rayz.Tuple.add(environment.wind)
      show_position(environment.ticks, new_position)
      new_projectile = %{position: new_position, velocity: new_velocity}

      tick(new_environment, new_projectile)
    end
  end

  def show_position(ticks, position) do
    IO.puts "Tick: #{ticks}"
    IO.puts "X: #{position.x}"
    IO.puts "Y: #{position.y}"
    IO.puts ""
  end

  def say_bye do
    IO.puts("Done")
  end
end
