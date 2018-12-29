defmodule Rayz.CanvasTest do
  use ExUnit.Case, async: true
  doctest Rayz.Canvas

  test "can get a pixel's color" do
    c = Rayz.Canvas.new_canvas(2, 2)
    red = Rayz.Color.new_color(1, 0, 0)
    c = Rayz.Canvas.write_pixel(c, 0, 0, red)

    assert Rayz.Canvas.pixel_at(c, 0, 0) == red
  end

  test "trying to write out of bounds leaves canvas unchanged" do
    max_canvas_size = 2
    canvas1 = Rayz.Canvas.new_canvas(max_canvas_size, max_canvas_size)
    red     = Rayz.Color.new_color(1, 0, 0)

    too_large = max_canvas_size + 1
    canvas2 = Rayz.Canvas.write_pixel(canvas1, 0, too_large, red)
    assert canvas1 == canvas2

    canvas3 = Rayz.Canvas.write_pixel(canvas1, too_large, 0, red)
    assert canvas1 == canvas3

    too_small = -1
    canvas4 = Rayz.Canvas.write_pixel(canvas1, 0, too_small, red)
    assert canvas1 == canvas4

    canvas5 = Rayz.Canvas.write_pixel(canvas1, too_small, 0, red)
    assert canvas1 == canvas5

  end

  test "can write a pixel in the canvas" do
    c = Rayz.Canvas.new_canvas(10, 20)
    red = Rayz.Color.new_color(1, 0, 0)
    c = Rayz.Canvas.write_pixel(c, 2, 3, red)

    assert c[2][3] == red
  end

  test "can create a canvas" do
    c = Rayz.Canvas.new_canvas(2, 3)

    expected = %{
  0 => %{
    0 => %Rayz.Color{blue: 0, green: 0, red: 0},
    1 => %Rayz.Color{blue: 0, green: 0, red: 0},
    2 => %Rayz.Color{blue: 0, green: 0, red: 0}
  },
  1 => %{
    0 => %Rayz.Color{blue: 0, green: 0, red: 0},
    1 => %Rayz.Color{blue: 0, green: 0, red: 0},
    2 => %Rayz.Color{blue: 0, green: 0, red: 0}
  },
  :x => 2,
  :y => 3
}
    assert c == expected
  end
end
