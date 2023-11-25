defmodule RayzBuilderTest do
  use ExUnit.Case
  doctest Builder

  describe "Builder.matrix/16" do
    test "can create a 4x4 matrix" do
      m =
        Builder.matrix(
          1,    2,    3,    4,
          5.5,  6.5,  7.5,  8.5,
          9,    10,   11,   12,
          13.5, 14.5, 15.5, 16.5
        )

      assert m ==
        {
          1,    2,    3,    4,
          5.5,  6.5,  7.5,  8.5,
          9,    10,   11,   12,
          13.5, 14.5, 15.5, 16.5
        }

      assert Rayz.Matrix.value_at(m, 0, 0) == 1
      assert Rayz.Matrix.value_at(m, 0, 3) == 4
      assert Rayz.Matrix.value_at(m, 1, 0) == 5.5
      assert Rayz.Matrix.value_at(m, 1, 2) == 7.5
      assert Rayz.Matrix.value_at(m, 2, 2) == 11
      assert Rayz.Matrix.value_at(m, 3, 0) == 13.5
      assert Rayz.Matrix.value_at(m, 3, 2) == 15.5
      assert Rayz.Matrix.value_at(m, 3, 3) == 16.5
    end
  end

  describe "Builder.matrix/9" do
    test "can create a 3x3 matrix" do
      m =
        Builder.matrix(
          1,    2,    3,
          5.5,  6.5,  7.5,
          9,    10,   11
        )

      assert m ==
        {
          1,    2,    3,
          5.5,  6.5,  7.5,
          9,    10,   11
        }

      assert Rayz.Matrix.value_at(m, 0, 0) == 1
      assert Rayz.Matrix.value_at(m, 0, 2) == 3
      assert Rayz.Matrix.value_at(m, 1, 1) == 6.5
      assert Rayz.Matrix.value_at(m, 1, 2) == 7.5
      assert Rayz.Matrix.value_at(m, 2, 2) == 11
    end
  end

  describe "Builder.matrix/4" do
    test "can create a 4x4 matrix" do
      m =
        Builder.matrix(
          1,    2,
          5.5,  6.5
        )

      assert m ==
        {
          1,    2,
          5.5,  6.5
        }

      assert Rayz.Matrix.value_at(m, 0, 0) == 1
      assert Rayz.Matrix.value_at(m, 0, 1) == 2
      assert Rayz.Matrix.value_at(m, 1, 0) == 5.5
      assert Rayz.Matrix.value_at(m, 1, 1) == 6.5
    end
  end

  describe "Builder.canvas/2" do
    test "Creating a canvas" do
      c = Builder.canvas(10, 20)

      assert c.width  == 10
      assert c.height == 20

      black = Builder.color(0, 0, 0)

      assert Enum.all?(c.pixels, fn x -> Rayz.Color.equal?(x, black) == true end) == true
    end
  end

  describe "Builder.tuple/4" do
    test "A tuple can be created" do
      a = Builder.tuple(4.3, -4.2, 3.1, 1.0)

      assert a == %Rayz.Tuple{x: 4.3, y: -4.2, z: 3.1, w: 1.0}
    end
  end

  describe "Builder.point/3" do
    test "point() creates tuples with w=1" do
      a = Builder.point(4, -4, 3)

      assert a == %Rayz.Tuple{x: 4, y: -4, z: 3, w: 1.0}
    end
  end

  describe "Builder.vector/3" do
    test "vector() creates tuples with w=0" do
      a = Builder.vector(4, -4, 3)

      assert a == %Rayz.Tuple{x: 4, y: -4, z: 3, w: 0}
    end
  end

  describe "Builder.color/3" do
    test "Colors are (red, green, blue) tuples" do
      c = Builder.color(-0.5, 0.4, 1.7)

      assert c.red   == -0.5
      assert c.green ==  0.4
      assert c.blue  ==  1.7
    end
  end

end
