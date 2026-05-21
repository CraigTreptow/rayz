require "../spec_helper"

describe "Colors" do
  it "Colors are (red, green, blue) tuples" do
    c = Rayz::Color.new(-0.5, 0.4, 1.7)
    c.red.should eq(-0.5)
    c.green.should eq(0.4)
    c.blue.should eq(1.7)
  end

  it "Adding colors" do
    c1 = Rayz::Color.new(0.9, 0.6, 0.75)
    c2 = Rayz::Color.new(0.7, 0.1, 0.25)
    (c1 + c2).should eq(Rayz::Color.new(1.6, 0.7, 1.0))
  end

  it "Subtracting colors" do
    c1 = Rayz::Color.new(0.9, 0.6, 0.75)
    c2 = Rayz::Color.new(0.7, 0.1, 0.25)
    (c1 - c2).should eq(Rayz::Color.new(0.2, 0.5, 0.5))
  end

  it "Multiplying a color by a scalar" do
    c = Rayz::Color.new(0.2, 0.3, 0.4)
    (c * 2.0).should eq(Rayz::Color.new(0.4, 0.6, 0.8))
  end

  it "Multiplying colors" do
    c1 = Rayz::Color.new(1, 0.2, 0.4)
    c2 = Rayz::Color.new(0.9, 1, 0.1)
    (c1 * c2).should eq(Rayz::Color.new(0.9, 0.2, 0.04))
  end
end
