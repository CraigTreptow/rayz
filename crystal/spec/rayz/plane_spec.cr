require "../spec_helper"

describe "Plane" do
  it "The normal of a plane is constant everywhere" do
    p = Rayz::Plane.new
    n1 = p.local_normal_at(Rayz::Point.new(0.0, 0.0, 0.0))
    n2 = p.local_normal_at(Rayz::Point.new(10.0, 0.0, -10.0))
    n3 = p.local_normal_at(Rayz::Point.new(-5.0, 0.0, 150.0))
    n1.should eq(Rayz::Vector.new(0.0, 1.0, 0.0))
    n2.should eq(Rayz::Vector.new(0.0, 1.0, 0.0))
    n3.should eq(Rayz::Vector.new(0.0, 1.0, 0.0))
  end

  it "Intersect with a ray parallel to the plane" do
    p = Rayz::Plane.new
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 10.0, 0.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = p.local_intersect(r)
    xs.should be_empty
  end

  it "Intersect with a coplanar ray" do
    p = Rayz::Plane.new
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = p.local_intersect(r)
    xs.should be_empty
  end

  it "A ray intersecting a plane from above" do
    p = Rayz::Plane.new
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 1.0, 0.0), Rayz::Vector.new(0.0, -1.0, 0.0))
    xs = p.local_intersect(r)
    xs.size.should eq(1)
    xs[0].t.should eq(1.0)
    xs[0].object.should eq(p)
  end

  it "A ray intersecting a plane from below" do
    p = Rayz::Plane.new
    r = Rayz::Ray.new(Rayz::Point.new(0.0, -1.0, 0.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    xs = p.local_intersect(r)
    xs.size.should eq(1)
    xs[0].t.should eq(1.0)
    xs[0].object.should eq(p)
  end
end
