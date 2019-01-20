defmodule Rayz.IntersectionsTest do
  use ExUnit.Case, async: true
  doctest Rayz.Intersection

  describe "Rayz.Intersection.hit/1" do
    test " The hit, when all intersections have positive t" do
      s  = Rayz.Sphere.new_sphere
      i1 = Rayz.Intersection.new_intersection(1, s)
      i2 = Rayz.Intersection.new_intersection(2, s)
      xs = Rayz.Intersection.intersections(i2, i1) 

      i = Rayz.Intersection.hit(xs)

      assert i.t == i1.t
      assert i.object.id == i1.object.id
    end

    test "The hit, when some intersections have negative t" do
      s  = Rayz.Sphere.new_sphere
      i1 = Rayz.Intersection.new_intersection(-1, s)
      i2 = Rayz.Intersection.new_intersection(1, s)
      xs = Rayz.Intersection.intersections(i2, i1) 

      i = Rayz.Intersection.hit(xs)

      assert i.t == i2.t
      assert i.object.id == i2.object.id
    end

    test "The hit, when all intersections have negative t" do
      s  = Rayz.Sphere.new_sphere
      i1 = Rayz.Intersection.new_intersection(-2, s)
      i2 = Rayz.Intersection.new_intersection(-2, s)
      xs = Rayz.Intersection.intersections(i2, i1) 

      i = Rayz.Intersection.hit(xs)

      assert i == nil
    end

    test "The hit is always the lowest non-negative intersection" do
      s  = Rayz.Sphere.new_sphere
      i1 = Rayz.Intersection.new_intersection(5, s)
      i2 = Rayz.Intersection.new_intersection(7, s)
      i3 = Rayz.Intersection.new_intersection(-3, s)
      i4 = Rayz.Intersection.new_intersection(2, s)
      xs = Rayz.Intersection.intersections(i1, i2, i3, i4)

      i = Rayz.Intersection.hit(xs)

      assert i.t == i4.t
      assert i.object.id == i4.object.id
    end
  end

  describe "Rayz.Intersection.intersections/2" do
    test "Aggregating intersections" do
      s  = Rayz.Sphere.new_sphere
      i1 = Rayz.Intersection.new_intersection(1, s)
      i2 = Rayz.Intersection.new_intersection(2, s)
      xs = Rayz.Intersection.intersections(i1, i2) 

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == 1
      assert Enum.at(xs, 1).t == 2
    end
  end

  describe "Rayz.Intersection.intersect/2" do
    test "An intersection encapsulates t and object" do
      s = Rayz.Sphere.new_sphere
      i = Rayz.Intersection.new_intersection(3.5, s)

      assert i.t == 3.5
      assert i.object.id == s.id
    end

    test "Intersect sets the object on the intersection" do
      o = Rayz.Tuple.new_point(0, 0, -5)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)
      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).object == s
      assert Enum.at(xs, 1).object == s
    end

    test "A sphere is behind a ray" do
      o = Rayz.Tuple.new_point(0, 0, 5)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)

      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == -6.0
      assert Enum.at(xs, 1).t == -4.0
    end

    test "A sphere is behind a ray again (Pavio's test)" do
      o = Rayz.Tuple.new_point(0, 0, -2.5)
      d = Rayz.Tuple.new_vector(0, 0, 0.5)
      r = Rayz.Ray.new_ray(o, d)

      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == 3.0
      assert Enum.at(xs, 1).t == 7.0
    end

    test "A ray originates inside a sphere" do
      o = Rayz.Tuple.new_point(0, 0, 0)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)

      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == -1.0
      assert Enum.at(xs, 1).t == 1.0
    end

    test "A ray misses a sphere" do
      o = Rayz.Tuple.new_point(0, 2, -5)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)

      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert Enum.empty?(xs) == true
    end

    test "A ray intersects a sphere at a tangent" do
      o = Rayz.Tuple.new_point(0, 1, -5)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)

      s = Rayz.Sphere.new_sphere
      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == 5.0
      assert Enum.at(xs, 1).t == 5.0
    end

    test "A ray intersects a sphere at two points" do
      o = Rayz.Tuple.new_point(0, 0, -5)
      d = Rayz.Tuple.new_vector(0, 0, 1)
      r = Rayz.Ray.new_ray(o, d)
      s = Rayz.Sphere.new_sphere

      xs = Rayz.Intersection.intersect(s, r)

      assert length(xs) == 2
      assert Enum.at(xs, 0).t == 4.0
      assert Enum.at(xs, 1).t == 6.0
    end
  end
end
