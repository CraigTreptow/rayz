defmodule Rayz.PPMTest do
  use ExUnit.Case
  doctest Rayz.Canvas

   test "generates correct PPM body" do
     canvas = Rayz.Canvas.create_canvas(5, 3)
     c1 = Rayz.Color.new_color(1.5, 0, 0)
     c2 = Rayz.Color.new_color(0, 0.5, 0)
     c3 = Rayz.Color.new_color(-0.5, 0, 1)
     canvas = Rayz.Canvas.write_pixel(canvas, 0, 0, c1)
     canvas = Rayz.Canvas.write_pixel(canvas, 2, 1, c2)
     canvas = Rayz.Canvas.write_pixel(canvas, 4, 2, c3)

     body = Rayz.PPM.body(canvas)

     assert body == """
     255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
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
    c = Rayz.Canvas.create_canvas(40, 80)
    max_color_value = 255

    header = Rayz.PPM.header(c, max_color_value)

    assert header == """
    P3
    40 80
    255
    """
  end
end
