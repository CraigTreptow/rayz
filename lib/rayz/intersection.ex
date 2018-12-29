defmodule Rayz.Intersection do
  @moduledoc """
  Provides multiple Intersection related functions
  """

  defstruct(
    t:      0.0,
    object: 0.0
  )

  def hit(intersections) do
    # return the lowest non-negative t value intersection
    intersections
    |> Enum.filter(fn i -> i.t >= 0 end)
    |> Enum.sort(&(&1.t <= &2.t))
    |> Enum.at(0)
  end

  def intersect(sphere = %Rayz.Sphere{id: _id, transform: transform}, ray) do
    inverted_transform = Rayz.Matrix4x4.inverse(transform)
    transformed_ray    = Rayz.Ray.transform(ray, inverted_transform)
    sphere_to_ray      = Rayz.Tuple.subtract(transformed_ray.origin, Rayz.Tuple.new_point(0, 0, 0))

    a = Rayz.Tuple.dot_product(transformed_ray.direction, transformed_ray.direction)
    b = transformed_ray.direction
        |> Rayz.Tuple.dot_product(sphere_to_ray)
    b = 2 * b
    c = sphere_to_ray
        |> Rayz.Tuple.dot_product(sphere_to_ray)
    c = c - 1

    discriminant = (b * b) - 4 * a * c     # 1.5
    #discriminant = ((b * b) - 4) * a * c   # -2.75
    #discriminant = (b * b) - (4 * a) * c    # 1.5
    #discriminant = (b * b) - (4 * a * c)    # 1.5
    #discriminant = b * b - 4 * a * c        # 1.5

    if discriminant < 0 do
      []
    else
      [
        (-b - :math.sqrt(discriminant)) / (2 * a),
        (-b + :math.sqrt(discriminant)) / (2 * a)
      ]
      |> Enum.sort
      |> convert_to_intersections(sphere)
    end
  end

  defp convert_to_intersections(t_values, object) do
    [
      new_intersection(Enum.at(t_values, 0), object),
      new_intersection(Enum.at(t_values, 1), object)
    ]
  end

  def new_intersection(t, object) do
    %Rayz.Intersection{t: t, object: object}
  end

  def intersections(i1, i2, i3, i4), do: [i1, i2, i3, i4]
  def intersections(i1, i2), do: [i1, i2]
end
