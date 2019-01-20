defmodule Rayz.RayTest do
  use ExUnit.Case, async: true
  doctest Rayz.Ray

  describe "Rayz.Ray.transform/2" do
    test "Translating a ray" do
      o = Rayz.Tuple.new_point(1, 2, 3)
      d = Rayz.Tuple.new_vector(0, 1, 0)
      r = Rayz.Ray.new_ray(o, d)
      m = Rayz.Matrix4x4.translation(3, 4, 5)

      r2 = Rayz.Ray.transform(r, m)
      _expected_origin    = r2.origin
      _expected_direction = r2.direction

      assert expected_origin    = Rayz.Tuple.new_point(4, 6, 8)
      assert expected_direction = Rayz.Tuple.new_vector(0, 1, 0)
    end

    test "Scaling a ray" do
      o = Rayz.Tuple.new_point(1, 2, 3)
      d = Rayz.Tuple.new_vector(0, 1, 0)
      r = Rayz.Ray.new_ray(o, d)
      m = Rayz.Matrix4x4.scaling(2, 3, 4)

      r2 = Rayz.Ray.transform(r, m)
      _expected_origin    = r2.origin
      _expected_direction = r2.direction

      assert expected_origin    = Rayz.Tuple.new_point(2, 6, 12)
      assert expected_direction = Rayz.Tuple.new_vector(0, 3, 0)
    end
  end

  describe "Rayz.Ray.new_ray/2" do
    test "Creating and querying a ray" do
      o = Rayz.Tuple.new_point(1, 2, 3)
      d = Rayz.Tuple.new_vector(4, 5, 6)

      r = Rayz.Ray.new_ray(o, d)

      assert Rayz.Tuple.equal?(r.origin,    o) == true
      assert Rayz.Tuple.equal?(r.direction, d) == true
    end
  end

  describe "Rayz.Ray.position/2" do
    test "Computing a point from a distance" do
      o = Rayz.Tuple.new_point(2, 3, 4)
      d = Rayz.Tuple.new_vector(1, 0, 0)
      r = Rayz.Ray.new_ray(o, d)

      assert Rayz.Tuple.equal?(Rayz.Ray.position(r, 0), Rayz.Tuple.new_point(2, 3, 4)) == true
      assert Rayz.Tuple.equal?(Rayz.Ray.position(r, 1), Rayz.Tuple.new_point(3, 3, 4)) == true
      assert Rayz.Tuple.equal?(Rayz.Ray.position(r, -1), Rayz.Tuple.new_point(1, 3, 4)) == true
      assert Rayz.Tuple.equal?(Rayz.Ray.position(r, 2.5), Rayz.Tuple.new_point(4.5, 3, 4)) == true
    end
  end
end
