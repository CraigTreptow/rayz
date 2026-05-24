require "../spec_helper"

class TestShape < Rayz::Shape
  def local_intersect(local_ray : Rayz::Ray) : Array(Rayz::Intersection)
    [] of Rayz::Intersection
  end

  def local_normal_at(local_point : Rayz::Point) : Rayz::Tuple
    Rayz::Vector.new(0.0, 0.0, 0.0)
  end
end

describe "Intersection" do
  it "An intersection encapsulates t and object" do
    s = TestShape.new
    i = Rayz::Intersection.new(3.5, s)
    i.t.should eq(3.5)
    i.object.should eq(s)
  end

  it "Aggregating intersections" do
    s = TestShape.new
    i1 = Rayz::Intersection.new(1, s)
    i2 = Rayz::Intersection.new(2, s)
    xs = Rayz.intersections(i1, i2)
    xs.size.should eq(2)
    xs[0].t.should eq(1.0)
    xs[1].t.should eq(2.0)
  end

  it "The hit, when all intersections have positive t" do
    s = TestShape.new
    i1 = Rayz::Intersection.new(1, s)
    i2 = Rayz::Intersection.new(2, s)
    xs = Rayz.intersections(i2, i1)
    Rayz.hit(xs).should eq(i1)
  end

  it "The hit, when some intersections have negative t" do
    s = TestShape.new
    i1 = Rayz::Intersection.new(-1, s)
    i2 = Rayz::Intersection.new(1, s)
    xs = Rayz.intersections(i2, i1)
    Rayz.hit(xs).should eq(i2)
  end

  it "The hit, when all intersections have negative t" do
    s = TestShape.new
    i1 = Rayz::Intersection.new(-2, s)
    i2 = Rayz::Intersection.new(-1, s)
    xs = Rayz.intersections(i2, i1)
    Rayz.hit(xs).should be_nil
  end

  it "The hit is always the lowest nonnegative intersection" do
    s = TestShape.new
    i1 = Rayz::Intersection.new(5, s)
    i2 = Rayz::Intersection.new(7, s)
    i3 = Rayz::Intersection.new(-3, s)
    i4 = Rayz::Intersection.new(2, s)
    xs = Rayz.intersections(i1, i2, i3, i4)
    Rayz.hit(xs).should eq(i4)
  end
end
