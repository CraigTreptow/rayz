require "../spec_helper"

describe "Ray" do
  it "Creating and querying a ray" do
    origin = Rayz::Point.new(1.0, 2.0, 3.0)
    direction = Rayz::Vector.new(4.0, 5.0, 6.0)
    r = Rayz::Ray.new(origin, direction)
    r.origin.should eq(origin)
    r.direction.should eq(direction)
  end

  it "Computing a point from a distance" do
    r = Rayz::Ray.new(Rayz::Point.new(2.0, 3.0, 4.0), Rayz::Vector.new(1.0, 0.0, 0.0))
    r.position(0).should eq(Rayz::Point.new(2.0, 3.0, 4.0))
    r.position(1).should eq(Rayz::Point.new(3.0, 3.0, 4.0))
    r.position(-1).should eq(Rayz::Point.new(1.0, 3.0, 4.0))
    r.position(2.5).should eq(Rayz::Point.new(4.5, 3.0, 4.0))
  end

  it "Translating a ray" do
    r = Rayz::Ray.new(Rayz::Point.new(1.0, 2.0, 3.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    m = Rayz::Transformations.translation(3, 4, 5)
    r2 = r.transform(m)
    r2.origin.should eq(Rayz::Point.new(4.0, 6.0, 8.0))
    r2.direction.should eq(Rayz::Vector.new(0.0, 1.0, 0.0))
  end

  it "Scaling a ray" do
    r = Rayz::Ray.new(Rayz::Point.new(1.0, 2.0, 3.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    m = Rayz::Transformations.scaling(2, 3, 4)
    r2 = r.transform(m)
    r2.origin.should eq(Rayz::Point.new(2.0, 6.0, 12.0))
    r2.direction.should eq(Rayz::Vector.new(0.0, 3.0, 0.0))
  end
end
