defmodule RayzBuilderTest do
  use ExUnit.Case
  doctest Builder

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
