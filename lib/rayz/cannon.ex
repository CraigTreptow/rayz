defmodule Rayz.Cannon do
  @moduledoc """
  Implements a cannon that uses points and vectors
  """

  @doc """
  Example:
  iex> p = Rayz.Cannon.new_projectile
  %{
    position: %Rayz.Tuple{w: 1.0, x: 0, y: 1, z: 0},
      velocity: %Rayz.Tuple{
            w: 0.0,
            x: 0.7071067811865475,
            y: 0.7071067811865475,
            z: 0.0
          }
  }


  iex> e = Rayz.Cannon.new_environment
  %{
    gravity: %Rayz.Tuple{w: 0.0, x: 0, y: -0.1, z: 0},
      ticks: 0,
      wind: %Rayz.Tuple{w: 0.0, x: -0.01, y: 0, z: 0}
  }


  iex> Rayz.Cannon.tick(e, p)
  Ticks: 1
  Position: x: 0
  Position: y: 1
  Position: z: 0
  Ticks: 2
  Position: x: 0.7071067811865475
  Position: y: 1.7071067811865475
  Position: z: 0.0 
  Ticks: 3
  Position: x: 1.404213562373095
  Position: y: 2.314213562373095
  Position: z: 0.0
  Ticks: 4
  Position: x: 2.0913203435596426
  Position: y: 2.821320343559642
  Position: z: 0.0
  Ticks: 5
  Position: x: 2.7684271247461902
  Position: y: 3.2284271247461898
  Position: z: 0.0
  Ticks: 6
  Position: x: 3.4355339059327377
  Position: y: 3.5355339059327373
  Position: z: 0.0
  Ticks: 7
  Position: x: 4.092640687119285
  Position: y: 3.7426406871192848
  Position: z: 0.0
  Ticks: 8
  Position: x: 4.739747468305833
  Position: y: 3.849747468305832
  Position: z: 0.0
  Ticks: 9
  Position: x: 5.37685424949238
  Position: y: 3.85685424949238
  Position: z: 0.0
  Ticks: 10
  Position: x: 6.003961030678928
  Position: y: 3.7639610306789275
  Position: z: 0.0
  Ticks: 11
  Position: x: 6.621067811865475
  Position: y: 3.571067811865475
  Position: z: 0.0
  Ticks: 12
  Position: x: 7.228174593052023
  Position: y: 3.2781745930520225
  Position: z: 0.0
  Ticks: 13
  Position: x: 7.82528137423857
  Position: y: 2.88528137423857
  Position: z: 0.0
  Ticks: 14
  Position: x: 8.412388155425118
  Position: y: 2.3923881554251176
  Position: z: 0.0
  Ticks: 15
  Position: x: 8.989494936611665
  Position: y: 1.7994949366116653
  Position: z: 0.0
  Ticks: 16
  Position: x: 9.556601717798213
  Position: y: 1.1066017177982128
  Position: z: 0.0
  Ticks: 17
  Position: x: 10.11370849898476
  Position: y: 0.3137084989847604
  Position: z: 0.0
  Ticks: 18
  Position: x: 10.660815280171308
  Position: y: -0.579184719828692
  Position: z: 0.0
  ** (exit) normal
      (rayz) lib/rayz/cannon.ex:42: Rayz.Cannon.tick/2
  """

  def new_projectile(multiplier \\ 1) do
    velocity =
      Rayz.Tuple.new_vector(1, 1, 0)
      |> Rayz.Tuple.normalize()
      |> Rayz.Tuple.multiply(multiplier)

    %{position: Rayz.Tuple.new_point(0, 1, 0), velocity: velocity}
  end

  def new_environment() do
    # gravity -0.1 unit/tick, and wind is -0.01 unit/tick.
    %{
      gravity: Rayz.Tuple.new_vector(0, -0.1, 0),
      wind: Rayz.Tuple.new_vector(-0.01, 0, 0),
      ticks: 0
    }
  end

  def do_it() do
    environment = new_environment()
    projectile = new_projectile()
    tick(environment, projectile)
  end

  def tick(env, projectile) do
    env = Map.put(env, :ticks, env.ticks + 1)
    IO.puts("Ticks: #{env.ticks}")
    IO.puts("Position: x: #{projectile.position.x}")
    IO.puts("Position: y: #{projectile.position.y}")
    IO.puts("Position: z: #{projectile.position.z}")

    if projectile.position.y <= 0 do
      exit(:normal)
    else
      new_position =
        projectile.position
        |> Rayz.Tuple.add(projectile.velocity)

      new_velocity =
        projectile.velocity
        |> Rayz.Tuple.add(env.gravity)
        |> Rayz.Tuple.add(env.wind)

      tick(env, %{position: new_position, velocity: new_velocity})
    end
  end
end
