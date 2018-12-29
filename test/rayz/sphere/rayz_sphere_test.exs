defmodule Rayz.SphereTest do
  use ExUnit.Case, async: true
  doctest Rayz.Sphere

  test "Intersecting a scaled sphere with a ray" do
    o = Rayz.Tuple.new_point(0, 0, -5)
    d = Rayz.Tuple.new_vector(0, 0, 1)
    r = Rayz.Ray.new_ray(o, d)
    s = Rayz.Sphere.new_sphere
    t = Rayz.Matrix4x4.scaling(2, 2, 2)

    s2 = Rayz.Sphere.set_transform(s, t)

    xs = Rayz.Intersection.intersect(s2, r)

    assert length(xs) == 2
    assert Enum.at(xs, 0).t == 3
    #assert Enum.at(xs, 1).t == 7
  end

  test "Intersecting a translated sphere with a ray" do
    o = Rayz.Tuple.new_point(0, 0, -5)
    d = Rayz.Tuple.new_vector(0, 0, 1)
    r = Rayz.Ray.new_ray(o, d)
    s = Rayz.Sphere.new_sphere
    t = Rayz.Matrix4x4.translation(5, 0, 0)

    s2 = Rayz.Sphere.set_transform(s, t)

    xs = Rayz.Intersection.intersect(s2, r)

    assert Enum.empty?(xs) == true
  end

  test "A sphere's default transformation" do
    s = Rayz.Sphere.new_sphere
    _t = s.transform

    assert t = Rayz.Matrix4x4.identity()
  end

  test "Changing a sphere's transformation" do
    s = Rayz.Sphere.new_sphere
    t = Rayz.Matrix4x4.translation(2, 3, 4)
    s2 = Rayz.Sphere.set_transform(s, t)

    assert s2.transform == t
  end

  test "A sphere is created" do
    s = Rayz.Sphere.new_sphere

    assert Map.has_key?(s, :id) == true
  end
end
