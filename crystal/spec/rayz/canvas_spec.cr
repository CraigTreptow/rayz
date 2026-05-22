require "../spec_helper"

describe "Canvas" do
  it "Creating a canvas" do
    c = Rayz::Canvas.new(10, 20)
    c.width.should eq(10)
    c.height.should eq(20)
    black = Rayz::Color.new(0.0, 0.0, 0.0)
    c.pixels.each do |row|
      row.each { |pixel| pixel.should eq(black) }
    end
  end

  it "Writing pixels to a canvas" do
    c = Rayz::Canvas.new(10, 20)
    red = Rayz::Color.new(1.0, 0.0, 0.0)
    c.write_pixel(2, 3, red)
    c.pixel_at(2, 3).should eq(red)
  end

  it "Constructing the PPM header" do
    c = Rayz::Canvas.new(5, 3)
    ppm = c.to_ppm
    lines = ppm.split("\n")
    lines[0].should eq("P3")
    lines[1].should eq("5 3")
    lines[2].should eq("255")
  end

  it "Constructing the PPM pixel data" do
    c = Rayz::Canvas.new(5, 3)
    color1 = Rayz::Color.new(1.5, 0.0, 0.0)
    color2 = Rayz::Color.new(0.0, 0.5, 0.0)
    color3 = Rayz::Color.new(-0.5, 0.0, 1.0)
    c.write_pixel(0, 0, color1)
    c.write_pixel(2, 1, color2)
    c.write_pixel(4, 2, color3)
    ppm = c.to_ppm
    lines = ppm.split("\n")
    lines[3].should eq("0 0 255 0 0 0 0 0 0 0 0 0 0 0 0")
    lines[4].should eq("0 0 0 0 0 0 0 128 0 0 0 0 0 0 0")
    lines[5].should eq("0 0 0 0 0 0 0 0 0 0 0 0 255 0 0")
  end

  it "PPM files are terminated by a newline character" do
    c = Rayz::Canvas.new(5, 3)
    c.to_ppm.ends_with?("\n").should be_true
  end
end
