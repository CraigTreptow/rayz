defmodule RayzCanvasTest do
  use ExUnit.Case
  doctest Rayz.Canvas

  describe "Rayz.Canvas.ppm_body/1" do
    test "generates correct PPM body" do
      canvas = Builder.canvas(5, 3)
      c1 = Builder.color(1.5, 0, 0)
      c2 = Builder.color(0, 0.5, 0)
      c3 = Builder.color(-0.5, 0, 1)
      canvas = 
        canvas
        |> Rayz.Canvas.write_pixel(0, 0, c1)
        |> Rayz.Canvas.write_pixel(0, 1, c2)
        |> Rayz.Canvas.write_pixel(0, 2, c3)

      body = Rayz.Canvas.ppm_body(canvas)

      assert body == """
      255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      0 128 0 0 0 0 0 0 0 0 0 0 0 0 0
      0 0 255 0 0 0 0 0 0 0 0 0 0 0 0
      """
    end

    @tag :skip
    test "Splitting long lines in PPM files" do
      color  = Builder.color(1, 0.8, 0.6)
      canvas = Builder.canvas(10, 2, color)
      body   = Rayz.Canvas.ppm_body(canvas)

      assert body == """
        255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        153 255 204 153 255 204 153 255 204 153 255 204 153
        255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        153 255 204 153 255 204 153 255 204 153 255 204 153
      """
    end

    test "PPM files are terminated by a newline" do
      canvas = Builder.canvas(5, 3)
      body   = Rayz.Canvas.ppm_body(canvas)

      assert String.ends_with?(body, "\n") == true
    end
  end

  describe "Rayz.Canvas.ppm_header/2" do
    test "generates correct PPM header" do
      c = Builder.canvas(40, 80)

      header = Rayz.Canvas.ppm_header(c)

      assert header == """
      P3
      40 80
      255
      """
    end
  end

  describe "Rayz.Color.write_pixel/4" do
    test "Writing pixels to a canvas" do
      c = Builder.canvas(10, 20)
      red = Builder.color(1, 0, 0)

      c = Rayz.Canvas.write_pixel(c, 2, 3, red)

      retrieved_color = Rayz.Canvas.pixel_at(c, 2, 3)

      assert Rayz.Color.equal?(retrieved_color, red) == true
    end

    test "Writing pixels to a canvas - beginning" do
      c = Builder.canvas(10, 20)
      red = Builder.color(1, 0, 0)

      c = Rayz.Canvas.write_pixel(c, 0, 0, red)

      retrieved_color = Rayz.Canvas.pixel_at(c, 0, 0)

      assert Rayz.Color.equal?(retrieved_color, red) == true
    end

    test "Writing pixels to a canvas - end" do
      c = Builder.canvas(10, 20)
      red = Builder.color(1, 0, 0)

      c = Rayz.Canvas.write_pixel(c, 9, 19, red)

      retrieved_color = Rayz.Canvas.pixel_at(c, 9, 19)

      assert Rayz.Color.equal?(retrieved_color, red) == true
    end
  end

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
