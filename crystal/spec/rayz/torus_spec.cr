require "../spec_helper"

module Rayz
  describe Torus do
    it "default torus has major_radius=1 and minor_radius=0.25" do
      t = Torus.new
      t.major_radius.should be_close(1.0, 1e-5)
      t.minor_radius.should be_close(0.25, 1e-5)
    end

    it "constructing a torus with custom radii" do
      t = Torus.new(major_radius: 2.0, minor_radius: 0.5)
      t.major_radius.should be_close(2.0, 1e-5)
      t.minor_radius.should be_close(0.5, 1e-5)
    end

    it "a ray misses the torus (through center hole along Z)" do
      t = Torus.new
      r = Ray.new(Point.new(0.0, 0.0, -3.0), Vector.new(0.0, 0.0, 1.0))
      xs = t.local_intersect(r)
      xs.should be_empty
    end

    it "a ray through the ring returns 4 intersections" do
      t = Torus.new
      # Ray along Y through center (x=0,z=0) passes through both tube cross-sections
      r = Ray.new(Point.new(0.0, -3.0, 0.0), Vector.new(0.0, 1.0, 0.0))
      xs = t.local_intersect(r)
      xs.size.should eq(4)
    end

    it "a ray offset to the major circle returns 2 intersections" do
      t = Torus.new
      # Ray at x=1 (on the major circle) going in Y passes through one tube section
      r = Ray.new(Point.new(1.0, -5.0, 0.0), Vector.new(0.0, 1.0, 0.0))
      xs = t.local_intersect(r)
      xs.size.should eq(2)
    end

    it "a ray far from the torus misses" do
      t = Torus.new
      r = Ray.new(Point.new(10.0, 0.0, 0.0), Vector.new(0.0, 0.0, 1.0))
      xs = t.local_intersect(r)
      xs.should be_empty
    end

    it "torus bounds span the XY plane ring" do
      t = Torus.new(major_radius: 1.0, minor_radius: 0.25)
      b = t.bounds
      b.min.x.should be_close(-1.25, 1e-5)
      b.min.y.should be_close(-1.25, 1e-5)
      b.min.z.should be_close(-0.25, 1e-5)
      b.max.x.should be_close(1.25, 1e-5)
      b.max.y.should be_close(1.25, 1e-5)
      b.max.z.should be_close(0.25, 1e-5)
    end

    it "normal at a point on the torus is normalized" do
      t = Torus.new
      n = t.local_normal_at(Point.new(1.25, 0.0, 0.0))
      n.magnitude.should be_close(1.0, 1e-5)
    end

    it "normal at outermost point points outward in X" do
      t = Torus.new(major_radius: 1.0, minor_radius: 0.25)
      n = t.local_normal_at(Point.new(1.25, 0.0, 0.0))
      n.x.should be_close(1.0, 1e-4)
      n.y.should be_close(0.0, 1e-4)
      n.z.should be_close(0.0, 1e-4)
    end
  end
end
