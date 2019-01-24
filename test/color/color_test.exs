defmodule RayzColorTest do
  use ExUnit.Case
  doctest Rayz.Color

  describe "Rayz.Color.add/2" do
    test "Adding colors" do
      c1 = Builder.color(0.9, 0.6, 0.75)
      c2 = Builder.color(0.7, 0.1, 0.25)

      c3 = Rayz.Color.add(c1, c2)
      expected_color = Builder.color(1.6, 0.7, 1.0)
      assert Rayz.Color.equal?(c3, expected_color) == true
    end
  end

  describe "Rayz.Color.subtract/2" do
    test "Subracting colors" do
      c1 = Builder.color(0.9, 0.6, 0.75)
      c2 = Builder.color(0.7, 0.1, 0.25)

      c3 = Rayz.Color.subtract(c1, c2)
      expected_color = Builder.color(0.2, 0.5, 0.5)
      assert Rayz.Color.equal?(c3, expected_color) == true
    end
  end

  describe "Rayz.Color.multiply/2" do
    test "Multiplying a color by a scalar" do
      c1 = Builder.color(0.2, 0.3, 0.4)

      c2 = Rayz.Color.multiply(c1, 2.0)
      expected_color = Builder.color(0.4, 0.6, 0.8)
      assert Rayz.Color.equal?(c2, expected_color) == true
    end

    test "Multiplying colors" do
      c1 = Builder.color(1.0, 0.2, 0.4)
      c2 = Builder.color(0.9, 1.0, 0.1)

      c2 = Rayz.Color.multiply(c1, c2)
      expected_color = Builder.color(0.9, 0.2, 0.04)
      assert Rayz.Color.equal?(c2, expected_color) == true
    end
  end
end
