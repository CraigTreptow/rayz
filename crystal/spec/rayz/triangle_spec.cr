require "../spec_helper"

module Rayz
  describe Triangle do
    it "constructing a triangle" do
      p1 = Point.new(0.0, 1.0, 0.0)
      p2 = Point.new(-1.0, 0.0, 0.0)
      p3 = Point.new(1.0, 0.0, 0.0)
      t = Triangle.new(p1, p2, p3)
      t.p1.x.should eq(p1.x); t.p1.y.should eq(p1.y); t.p1.z.should eq(p1.z)
      t.p2.x.should eq(p2.x); t.p2.y.should eq(p2.y); t.p2.z.should eq(p2.z)
      t.p3.x.should eq(p3.x); t.p3.y.should eq(p3.y); t.p3.z.should eq(p3.z)
      t.e1.x.should be_close(-1.0, 1e-5); t.e1.y.should be_close(-1.0, 1e-5); t.e1.z.should be_close(0.0, 1e-5)
      t.e2.x.should be_close(1.0, 1e-5); t.e2.y.should be_close(-1.0, 1e-5); t.e2.z.should be_close(0.0, 1e-5)
      t.normal.x.should be_close(0.0, 1e-5); t.normal.y.should be_close(0.0, 1e-5); t.normal.z.should be_close(-1.0, 1e-5)
    end

    it "intersecting a ray parallel to the triangle" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      r = Ray.new(Point.new(0.0, -1.0, -2.0), Vector.new(0.0, 1.0, 0.0))
      t.local_intersect(r).should be_empty
    end

    it "ray misses the p1-p3 edge" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      r = Ray.new(Point.new(1.0, 1.0, -2.0), Vector.new(0.0, 0.0, 1.0))
      t.local_intersect(r).should be_empty
    end

    it "ray misses the p1-p2 edge" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      r = Ray.new(Point.new(-1.0, 1.0, -2.0), Vector.new(0.0, 0.0, 1.0))
      t.local_intersect(r).should be_empty
    end

    it "ray misses the p2-p3 edge" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      r = Ray.new(Point.new(0.0, -1.0, -2.0), Vector.new(0.0, 0.0, 1.0))
      t.local_intersect(r).should be_empty
    end

    it "ray strikes a triangle" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      r = Ray.new(Point.new(0.0, 0.5, -2.0), Vector.new(0.0, 0.0, 1.0))
      xs = t.local_intersect(r)
      xs.size.should eq(1)
      xs[0].t.should be_close(2.0, 1e-5)
    end

    it "finding the normal on a triangle" do
      t = Triangle.new(Point.new(0.0, 1.0, 0.0), Point.new(-1.0, 0.0, 0.0), Point.new(1.0, 0.0, 0.0))
      n1 = t.local_normal_at(Point.new(0.0, 0.5, 0.0))
      n2 = t.local_normal_at(Point.new(-0.5, 0.75, 0.0))
      n3 = t.local_normal_at(Point.new(0.5, 0.25, 0.0))
      [n1, n2, n3].each do |n|
        n.x.should be_close(t.normal.x, 1e-5)
        n.y.should be_close(t.normal.y, 1e-5)
        n.z.should be_close(t.normal.z, 1e-5)
      end
    end
  end
end
