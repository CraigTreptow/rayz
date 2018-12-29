defmodule Rayz.Ray do
  @moduledoc """
  Provides a Ray
  """

  defstruct(
    origin:    Rayz.Tuple.new_point(0, 0, 0),
    direction: Rayz.Tuple.new_vector(0, 0, 0)
  )

  def transform(ray, transformation) do
    o = ray.origin
    d = ray.direction
    np = Rayz.Matrix4x4.multiply_tuple(o, transformation)
    new_ray(np, d)
  end

  def position(ray, t) do
    ray.direction
    |> Rayz.Tuple.multiply(t)
    |> Rayz.Tuple.add(ray.origin)
  end

  def new_ray(origin, direction) do
    %Rayz.Ray{
      origin:    origin,
      direction: direction
    }
  end
end
