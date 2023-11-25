defmodule RayzSphereTest do
  use ExUnit.Case
  #doctest Rayz.Sphere

  describe "Rayz.Sphere.normal_at/2" do
    test "Computing the normal on a translated sphere" do
      s = Builder.sphere()
      m = Builder.translation(0, 1, 0)
      Rayz.Sphere.set_transform(s, m)
      p = Builder.point(0, 1.70711, -0.70711) 
      n = Rayz.Sphere.normal_at(s, p)

      IO.inspect n

      expected_v = Builder.vector(0, 0.70711, -0.70711)

      assert Equality.equal?(n, expected_v)
    end

    #test "Computing the normal on a transformed sphere" do
    #  s        = Builder.sphere()
    #  scaling  = Builder.scaling(1, 0.5, 1)
    #  rotation = Builder.rotation_z(:math.pi / 5)
    #  m        = Rayz.Matrix.multiply(scaling, rotation)
    #  Rayz.Sphere.set_transform(s, m)
    #  p = Builder.point(0, :math.sqrt(2) / 2, -:math.sqrt(2) / 2)
    #  n = Rayz.Sphere.normal_at(s, p)

    #  IO.inspect n

    #  expected_v = Builder.vector(0, 0.97014, -0.24254)

    #  assert Equality.equal?(n, expected_v)
    #end

    test "The normal on a sphere at a point on the x axis" do
      s = Builder.sphere()
      p = Builder.point(1, 0, 0)
      n = Rayz.Sphere.normal_at(s, p)

      expected_v = Builder.vector(1, 0, 0)

      assert Equality.equal?(n, expected_v)
    end

    test "The normal on a sphere at a point on the y axis" do
      s = Builder.sphere()
      p = Builder.point(0, 1, 0)
      n = Rayz.Sphere.normal_at(s, p)
      expected_v = Builder.vector(0, 1, 0)

      assert Equality.equal?(n, expected_v)
    end

    test "The normal on a sphere at a point on the z axis" do
      s = Builder.sphere()
      p = Builder.point(0, 0, 1)
      n = Rayz.Sphere.normal_at(s, p)
      expected_v = Builder.vector(0, 0, 1)

      assert Equality.equal?(n, expected_v)
    end

    test "The normal on a sphere at a non-axial point" do
      s = Builder.sphere()
      p = Builder.point(:math.sqrt(3) / 3, :math.sqrt(3) / 3, :math.sqrt(3) / 3)
      n = Rayz.Sphere.normal_at(s, p)
      expected_v = Builder.vector(:math.sqrt(3) / 3, :math.sqrt(3) / 3, :math.sqrt(3) / 3)

      assert Equality.equal?(n, expected_v)
    end

    test "The normal is a normalized vector" do
      s = Builder.sphere()
      p = Builder.point(1, 0, 0)
      n = Rayz.Sphere.normal_at(s, p)
      nv = Rayz.Tuple.normalize(n)

      assert Equality.equal?(n, nv)
    end
  end

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
