defmodule RayzSphereTest do
  use ExUnit.Case
  #doctest Rayz.Sphere

  test "Intersecting a scaled sphere with a ray" do
    origin = Builder.point(0, 0, -5)
    direction = Builder.vector(0, 0, 1)
    r = Builder.ray(origin, direction)
    s = 
      Builder.sphere()
      |> Rayz.Sphere.set_transform(Builder.scaling(2, 2, 2))

    xs = Rayz.Intersection.intersect(s, r)

    assert Kernel.length(xs) == 2
    assert Enum.at(xs, 0).t == 3.0
    assert Enum.at(xs, 1).t == 7.0
  end

  test "Intersecting a translated sphere with a ray" do
    origin = Builder.point(0, 0, -5)
    direction = Builder.vector(0, 0, 1)
    r = Builder.ray(origin, direction)
    s = 
      Builder.sphere()
      |> Rayz.Sphere.set_transform(Builder.translation(5, 0, 0))

    xs = Rayz.Intersection.intersect(s, r)

    assert Kernel.length(xs) == 0
  end

  test "A sphere's default transformation" do
    s = Builder.sphere()
    i = Builder.identity_matrix()

    assert Equality.equal?(s.transform, i)
  end

  test "Changing a sphere's transformation" do
    s = Builder.sphere()
    t = Builder.translation(2, 3, 4) 

    s = Rayz.Sphere.set_transform(s, t)

    assert Equality.equal?(s.transform, t)
  end
end
