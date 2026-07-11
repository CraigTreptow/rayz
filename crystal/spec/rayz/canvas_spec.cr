require "../spec_helper"

describe "Canvas" do
  it "Creating a canvas" do
    c = Rayz::Canvas.new(10, 20)
    c.width.should eq(10)
    c.height.should eq(20)
    black = Rayz::Color.new(0, 0, 0)
    (0...20).each do |row|
      (0...10).each do |col|
        c.pixel_at(col, row).should eq(black)
      end
    end
  end

  it "Writing pixels to a canvas" do
    c = Rayz::Canvas.new(10, 20)
    red = Rayz::Color.new(1, 0, 0)
    c.write_pixel(2, 3, red)
    c.pixel_at(2, 3).should eq(red)
  end

  it "Constructing the PPM header" do
    c = Rayz::Canvas.new(5, 3)
    ppm = c.to_ppm
    lines = ppm.lines
    lines[0].chomp.should eq("P3")
    lines[1].chomp.should eq("5 3")
    lines[2].chomp.should eq("255")
  end

  it "Constructing the PPM pixel data" do
    c = Rayz::Canvas.new(5, 3)
    color1 = Rayz::Color.new(1.5, 0, 0)
    color2 = Rayz::Color.new(0, 0.5, 0)
    color3 = Rayz::Color.new(-0.5, 0, 1)
    c.write_pixel(0, 0, color1)
    c.write_pixel(2, 1, color2)
    c.write_pixel(4, 2, color3)
    ppm = c.to_ppm
    lines = ppm.lines
    lines[3].chomp.should eq("0 0 0 0 0 0 0 0 0 0 0 0 0 0 255")
    lines[4].chomp.should eq("0 0 0 0 0 0 0 128 0 0 0 0 0 0 0")
    lines[5].chomp.should eq("255 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
  end

  it "PPM files are terminated by a newline character" do
    c = Rayz::Canvas.new(5, 3)
    ppm = c.to_ppm
    ppm[-1].should eq('\n')
  end
end
