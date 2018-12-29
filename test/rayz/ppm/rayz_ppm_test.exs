defmodule Rayz.PPMTest do
  use ExUnit.Case, async: true
  doctest Rayz.Canvas

  test "PPM files are terminated by a newline" do
    canvas = Rayz.Canvas.new_canvas(5, 3)

    body = Rayz.PPM.body(canvas)

    assert String.ends_with?(body, "\n")
  end

  test "generates correct PPM body" do
    canvas = Rayz.Canvas.new_canvas(5, 3)
    c1 = Rayz.Color.new_color(1.5, 0, 0)
    c2 = Rayz.Color.new_color(0, 0.5, 0)
    c3 = Rayz.Color.new_color(-0.5, 0, 1)
    canvas = Rayz.Canvas.write_pixel(canvas, 0, 0, c1)
    canvas = Rayz.Canvas.write_pixel(canvas, 0, 1, c2)
    canvas = Rayz.Canvas.write_pixel(canvas, 0, 2, c3)

    body = Rayz.PPM.body(canvas)

    assert body == """
    255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 128 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 255 0 0 0 0 0 0 0 0 0 0 0 0
    """
  end

  @tag :pending
  test "splitting long lines in PPM files" do
    canvas = Rayz.Canvas.new_canvas(2, 71)
    #When every pixel of c is set to color(1, 0.8, 0.6)

    body = Rayz.PPM.body(canvas)

    assert body == """
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
    153 255 204 153 255 204 153 255 204 153 255 204 153
    255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
    153 255 204 153 255 204 153 255 204 153 255 204 153
    """
  end

  test "clamping low values" do
    assert Rayz.PPM.clamp(-0.1)  == 0
    assert Rayz.PPM.clamp(0)     == 0
    assert Rayz.PPM.clamp(255.1) == 255
    assert Rayz.PPM.clamp(256)   == 255
    assert Rayz.PPM.clamp(0.34)  == 87
  end

  test "generates correct PPM header" do
    c = Rayz.Canvas.new_canvas(40, 80)
    max_color_value = 255

    header = Rayz.PPM.header(c, max_color_value)

    assert header == """
    P3
    40 80
    255
    """
  end
end
