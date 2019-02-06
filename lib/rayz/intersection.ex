defmodule Rayz.Intersection do
  @moduledoc """
  Documentation for Rayz.Intersection
  """

  @doc """
      iex> s = Builder.sphere()
      %Rayz.Sphere{id: 1}
  """

  defstruct(
    t:      0.0,
    object: nil
  )

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type ray :: %Rayz.Ray{origin: rayztuple(), direction: rayztuple()}
  @type sphere :: %Rayz.Sphere{id: integer()}

  def hit(hits) do
    hits
    |> Enum.sort(&(&1.t < &2.t))
    |> Enum.filter(fn o -> o.t >= 0 end)
    |> Enum.at(0)
  end

  @spec intersect(sphere(), ray()) :: list()
  def intersect(sphere, ray) do
    ray2 = 
      ray
      |> Rayz.Ray.transform(Rayz.Matrix.inverse(sphere.transform))
    # the vector from the sphere's center, to the ray origin
    # Remember: the sphere is centered at the world origin
    sphere_to_ray = Rayz.Tuple.subtract(ray2.origin, Builder.point(0, 0, 0))

    a = Rayz.Tuple.dot(ray2.direction, ray2.direction)
    b = 2 * Rayz.Tuple.dot(ray2.direction, sphere_to_ray)
    c = Rayz.Tuple.dot(sphere_to_ray, sphere_to_ray) - 1

    discriminant = (b * b) - (4 * a * c)

    intersect_result(discriminant, a, b, sphere)
  end

  defp intersect_result(discriminant, a, b, sphere) when discriminant >= 0 do
    [
      Builder.intersection(
        (-b - :math.sqrt(discriminant)) / (2 * a), sphere),
          Builder.intersection(
        (-b + :math.sqrt(discriminant)) / (2 * a), sphere)
    ]
  end
  defp intersect_result(_discriminant, _a, _b, _sphere), do: []
end
