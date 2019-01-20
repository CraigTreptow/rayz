defmodule Rayz.ColorTest do
  use ExUnit.Case, async: true
  doctest Rayz.Color

  alias Rayz.Epsilon, as: Epsilon

  test "can multiply two colors" do
    c1 = Rayz.Color.new_color(1, 0.2, 0.4)
    c2 = Rayz.Color.new_color(0.9, 1, 0.1)

    x = Rayz.Color.multiply(c1, c2)

    assert Epsilon.equal?(x.red, 0.9)
    assert Epsilon.equal?(x.green, 0.2)
    assert Epsilon.equal?(x.blue, 0.04)
  end

  test "can multiply a color by a scalar" do
    c = Rayz.Color.new_color(0.2, 0.3, 0.4)

    x = Rayz.Color.multiply(c, 2)

    assert x.red == 0.4
    assert x.green == 0.6
    assert x.blue == 0.8
  end

  test "can subtract colors" do
    c1 = Rayz.Color.new_color(0.9, 0.6, 0.75)
    c2 = Rayz.Color.new_color(0.7, 0.1, 0.25)

    x = Rayz.Color.subtract(c1, c2)

    assert Epsilon.equal?(x.red, 0.2)
    assert Epsilon.equal?(x.green, 0.5)
    assert Epsilon.equal?(x.blue, 0.5)
  end

  test "can add colors" do
    c1 = Rayz.Color.new_color(0.9, 0.6, 0.75)
    c2 = Rayz.Color.new_color(0.7, 0.1, 0.25)

    x = Rayz.Color.add(c1, c2)

    assert x.red == 1.6
    assert x.green == 0.7
    assert x.blue == 1.0
  end

  test "creates a color" do
    c = Rayz.Color.new_color(-0.5, 0.4, 0.7)

    assert c.red == -0.5
    assert c.green == 0.4
    assert c.blue == 0.7
  end
end
