defmodule RayzRayTest do
  use ExUnit.Case
  doctest Rayz.Ray

  describe "Rayz.Ray.transform/2" do
    test "Translating a ray" do
      origin    = Builder.point(1, 2, 3)
      direction = Builder.vector(0, 1, 0)
      r = Builder.ray(origin, direction)
      m = Builder.translation(3, 4, 5)
      r2 = Rayz.Ray.transform(r, m)

      expected_p = Builder.point(4, 6, 8)
      assert Equality.equal?(r2.origin, expected_p)

      expected_v = Builder.vector(0, 1, 0)
      assert Equality.equal?(r2.direction, expected_v)
    end

    test "Scaling a ray" do
      origin    = Builder.point(1, 2, 3)
      direction = Builder.vector(0, 1, 0)
      r = Builder.ray(origin, direction)
      m = Builder.scaling(2, 3, 4)
      r2 = Rayz.Ray.transform(r, m)

      expected_p = Builder.point(2, 6, 12)
      assert Equality.equal?(r2.origin, expected_p)

      expected_v = Builder.vector(0, 3, 0)
      assert Equality.equal?(r2.direction, expected_v)
    end
  end

  describe "Rayz.Ray.position/2" do
    test "Computing a point from a distance" do
      origin    = Builder.point(2, 3, 4)
      direction = Builder.vector(1, 0, 0)

      r = Builder.ray(origin, direction)

      p0 = Rayz.Ray.position(r, 0)
      p1 = Rayz.Ray.position(r, 1)
      p2 = Rayz.Ray.position(r, -1)
      p3 = Rayz.Ray.position(r, 2.5)

      expected_p0 = Builder.point(2, 3, 4)
      expected_p1 = Builder.point(3, 3, 4)
      expected_p2 = Builder.point(1, 3, 4)
      expected_p3 = Builder.point(4.5, 3, 4)

      assert Equality.equal?(p0, expected_p0)
      assert Equality.equal?(p1, expected_p1)
      assert Equality.equal?(p2, expected_p2)
      assert Equality.equal?(p3, expected_p3)
    end
  end

  test "Creating and querying a ray" do
    origin    = Builder.point(1, 2, 3)
    direction = Builder.vector(4, 5, 6)

    r = Builder.ray(origin, direction)

    assert Equality.equal?(r.origin, origin) == true
    assert Equality.equal?(r.direction, direction) == true
  end
end
