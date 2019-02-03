defmodule Rayz.Sphere do
  @moduledoc """
  Documentation for Rayz.Sphere
  """

  @doc """
      iex> s = Builder.sphere()
      %Rayz.Sphere{id: 1}
  """

  defstruct(
    id: Integer.to_string(:rand.uniform(4_294_967_296), 32) #,
    #transform: Rayz.Matrix.identity_matrix()
  )

  @type rayztuple :: %Rayz.Tuple{x: float(), y: float(), z: float(), w: float()}
  @type ray :: %Rayz.Ray{origin: rayztuple(), direction: rayztuple()}
  @type sphere :: %Rayz.Sphere{id: integer()}

  @spec intersect(sphere(), ray()) :: list()
  def intersect(sphere, ray) do
    # the vector from the sphere's center, to the ray origin
    # Remember: the sphere is centered at the world origin
    sphere_to_ray = Rayz.Tuple.subtract(ray.origin, Builder.point(0, 0, 0))

    a = Rayz.Tuple.dot(ray.direction, ray.direction)
    b = 2 * Rayz.Tuple.dot(ray.direction, sphere_to_ray)
    c = Rayz.Tuple.dot(sphere_to_ray, sphere_to_ray) - 1

    discriminant = (b * b) - (4 * a * c)

    intersect_result(discriminant, a, b, c)
  end

  defp intersect_result(discriminant, a, b, c) when discriminant >= 0 do
    [
      (-b - :math.sqrt(discriminant)) / (2 * a),
      (-b + :math.sqrt(discriminant)) / (2 * a)
    ]
  end
  defp intersect_result(_discriminant, _a, _b, _c), do: []
end
