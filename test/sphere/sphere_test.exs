defmodule RayzSphereTest do
  use ExUnit.Case
  #doctest Rayz.Sphere

  #describe "Rayz.Sphere.intersect/2" do
  #  test "A ray intersects a sphere at two points" do
  #    origin    = Builder.point(0, 0, -5)
  #    direction = Builder.vector(0, 0, 1)
  #    r = Builder.ray(origin, direction)
  #    s = Builder.sphere()

  #    xs = Rayz.Sphere.intersect(s, r)

  #    assert Kernel.length(xs) == 2
  #    assert Enum.at(xs, 0) == 4.0
  #    assert Enum.at(xs, 1) == 6.0
  #  end

  #  test "A ray intersects a sphere at a tangent" do
  #    origin    = Builder.point(0, 1, -5)
  #    direction = Builder.vector(0, 0, 1)
  #    r = Builder.ray(origin, direction)
  #    s = Builder.sphere()

  #    xs = Rayz.Sphere.intersect(s, r)

  #    assert Kernel.length(xs) == 2
  #    assert Enum.at(xs, 0) == 5.0
  #    assert Enum.at(xs, 1) == 5.0
  #  end

  #  test "A ray misses a sphere" do
  #    origin    = Builder.point(0, 2, -5)
  #    direction = Builder.vector(0, 0, 1)
  #    r = Builder.ray(origin, direction)
  #    s = Builder.sphere()

  #    xs = Rayz.Sphere.intersect(s, r)

  #    assert Kernel.length(xs) == 0
  #  end

  #  test "A ray originates inside a sphere" do
  #    origin    = Builder.point(0, 0, 0)
  #    direction = Builder.vector(0, 0, 1)
  #    r = Builder.ray(origin, direction)
  #    s = Builder.sphere()

  #    xs = Rayz.Sphere.intersect(s, r)

  #    assert Kernel.length(xs) == 2
  #    assert Enum.at(xs, 0) == -1.0
  #    assert Enum.at(xs, 1) == 1.0
  #  end

  #  test "A sphere is behind a ray" do
  #    origin    = Builder.point(0, 0, 5)
  #    direction = Builder.vector(0, 0, 1)
  #    r = Builder.ray(origin, direction)
  #    s = Builder.sphere()

  #    xs = Rayz.Sphere.intersect(s, r)

  #    assert Kernel.length(xs) == 2
  #    assert Enum.at(xs, 0) == -6.0
  #    assert Enum.at(xs, 1) == -4.0
  #  end
  #end
end
