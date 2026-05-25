require "../spec_helper"

module Rayz
  describe SmoothTriangle do
    it "constructing a smooth triangle" do
      p1 = Point.new(0.0, 1.0, 0.0)
      p2 = Point.new(-1.0, 0.0, 0.0)
      p3 = Point.new(1.0, 0.0, 0.0)
      n1 = Vector.new(0.0, 1.0, 0.0)
      n2 = Vector.new(-1.0, 0.0, 0.0)
      n3 = Vector.new(1.0, 0.0, 0.0)
      tri = SmoothTriangle.new(p1, p2, p3, n1, n2, n3)
      tri.p1.x.should eq(p1.x); tri.p1.y.should eq(p1.y); tri.p1.z.should eq(p1.z)
      tri.p2.x.should eq(p2.x); tri.p2.y.should eq(p2.y); tri.p2.z.should eq(p2.z)
      tri.p3.x.should eq(p3.x); tri.p3.y.should eq(p3.y); tri.p3.z.should eq(p3.z)
      tri.n1.x.should eq(n1.x); tri.n1.y.should eq(n1.y); tri.n1.z.should eq(n1.z)
      tri.n2.x.should eq(n2.x); tri.n2.y.should eq(n2.y); tri.n2.z.should eq(n2.z)
      tri.n3.x.should eq(n3.x); tri.n3.y.should eq(n3.y); tri.n3.z.should eq(n3.z)
    end

    it "an intersection with a smooth triangle stores u/v" do
      tri = SmoothTriangle.new(
        Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0),
        Vector.new(0.0, 1.0, 0.0), Vector.new(-1.0, 0.0, 0.0), Vector.new(1.0, 0.0, 0.0)
      )
      r = Ray.new(Point.new(-0.2, 0.3, -2.0), Vector.new(0.0, 0.0, 1.0))
      xs = tri.local_intersect(r)
      xs[0].u.not_nil!.should be_close(0.45, 1e-4)
      xs[0].v.not_nil!.should be_close(0.25, 1e-4)
    end

    it "a smooth triangle uses u/v to interpolate the normal" do
      tri = SmoothTriangle.new(
        Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0),
        Vector.new(0.0, 1.0, 0.0), Vector.new(-1.0, 0.0, 0.0), Vector.new(1.0, 0.0, 0.0)
      )
      i = Intersection.new(1.0, tri, 0.45, 0.25)
      n = tri.normal_at(Point.new(0.0, 0.0, 0.0), i)
      n.x.should be_close(-0.5547, 1e-4)
      n.y.should be_close(0.83205, 1e-4)
      n.z.should be_close(0.0, 1e-4)
    end

    it "preparing the normal on a smooth triangle" do
      tri = SmoothTriangle.new(
        Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0),
        Vector.new(0.0, 1.0, 0.0), Vector.new(-1.0, 0.0, 0.0), Vector.new(1.0, 0.0, 0.0)
      )
      i = Intersection.new(1.0, tri, 0.45, 0.25)
      r = Ray.new(Point.new(-0.2, 0.3, -2.0), Vector.new(0.0, 0.0, 1.0))
      xs = Rayz.intersections(i)
      comps = i.prepare_computations(r, xs)
      comps.normalv.x.should be_close(-0.5547, 1e-4)
      comps.normalv.y.should be_close(0.83205, 1e-4)
      comps.normalv.z.should be_close(0.0, 1e-4)
    end
  end
end
