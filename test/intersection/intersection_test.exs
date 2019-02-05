defmodule RayzIntersectionTest do
  use ExUnit.Case
  #doctest Rayz.Intersection

  describe "Rayz.Intersection.hit/1" do
    test "The hit, when all intersections have positive t" do
      s = Builder.sphere()
      i1 = Builder.intersection(1, s)
      i2 = Builder.intersection(2, s)

      xs = Builder.intersections(i2, i1)
      i = Rayz.Intersection.hit(xs)

      assert i.t == i1.t
    end

    test "The hit, when some intersections have negative t" do
      s = Builder.sphere()
      i1 = Builder.intersection(-1, s)
      i2 = Builder.intersection(1, s)

      xs = Builder.intersections(i2, i1)
      i = Rayz.Intersection.hit(xs)

      assert i == i2
    end

    test "The hit, when all intersections have negative t" do
      s = Builder.sphere()
      i1 = Builder.intersection(-2, s)
      i2 = Builder.intersection(-1, s)

      xs = Builder.intersections(i2, i1)
      i = Rayz.Intersection.hit(xs)

      assert i == nil
    end

    test "The hit is always the lowest non-negative intersection" do
      s = Builder.sphere()
      i1 = Builder.intersection(5, s)
      i2 = Builder.intersection(7, s)
      i3 = Builder.intersection(-3, s)
      i4 = Builder.intersection(2, s)

      xs = Builder.intersections(i1, i2, i3, i4)
      i = Rayz.Intersection.hit(xs)

      assert i == i4
    end
  end

  describe "Rayz.Intersection.intersections/2" do
    test "Intersect sets the object on the intersection" do
      origin    = Builder.point(0, 0, -5)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).object == s
      assert Enum.at(xs, 1).object == s
    end

    test "Aggregating intersections" do
      s  = Builder.sphere()
      i1 = Builder.intersection(1, s)
      i2 = Builder.intersection(2, s)

      xs = Builder.intersections(i1, i2)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).t == 1
      assert Enum.at(xs, 1).t == 2
    end
  end

  describe "Rayz.Intersection.intersection/2" do
    test "An intersection encapsulates t and object" do
      s = Builder.sphere()
      i = Builder.intersection(3.5, s)

      assert i.t == 3.5
      assert i.object == s
    end
  end

  describe "Rayz.Intersection.intersect/2" do
    test "A ray intersects a sphere at two points" do
      origin    = Builder.point(0, 0, -5)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).t == 4.0
      assert Enum.at(xs, 1).t == 6.0
    end

    test "A ray intersects a sphere at a tangent" do
      origin    = Builder.point(0, 1, -5)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).t == 5.0
      assert Enum.at(xs, 1).t == 5.0
    end

    test "A ray misses a sphere" do
      origin    = Builder.point(0, 2, -5)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 0
    end

    test "A ray originates inside a sphere" do
      origin    = Builder.point(0, 0, 0)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).t == -1.0
      assert Enum.at(xs, 1).t == 1.0
    end

    test "A sphere is behind a ray" do
      origin    = Builder.point(0, 0, 5)
      direction = Builder.vector(0, 0, 1)
      r = Builder.ray(origin, direction)
      s = Builder.sphere()

      xs = Rayz.Intersection.intersect(s, r)

      assert Kernel.length(xs) == 2
      assert Enum.at(xs, 0).t == -6.0
      assert Enum.at(xs, 1).t == -4.0
    end
  end
end
