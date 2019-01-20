defmodule RayzTest do
  use ExUnit.Case
  doctest Rayz

  test "creates a point" do
    assert Rayz.new_point(1.0, 2.0, 3.0) == %Rayz.Tuple{w: 1.0, x: 1.0, y: 2.0, z: 3.0}
  end

  test "saves the coordinates of a point" do
    p = Rayz.new_point(1.0, 2.0, 3.0)
    assert p.x == 1.0
    assert p.y == 2.0
    assert p.z == 3.0
  end

  test "works with negative coordinates of a point" do
    p = Rayz.new_point(-1.0, -2.0, -3.0)
    assert p.x == -1.0
    assert p.y == -2.0
    assert p.z == -3.0
  end

  test "creates a vector" do
    assert Rayz.new_vector(1, 2, 3) == %Rayz.Tuple{w: 0.0, x: 1.0, y: 2.0, z: 3.0}
  end

  test "saves the coordinates of a vector" do
    v = Rayz.new_vector(1.0, 2.0, 3.0)
    assert v.x == 1.0
    assert v.y == 2.0
    assert v.z == 3.0
  end

  test "works with negative coordinates of a vector" do
    v = Rayz.new_vector(-1.0, -2.0, -3.0)
    assert v.x == -1.0
    assert v.y == -2.0
    assert v.z == -3.0
  end
end
