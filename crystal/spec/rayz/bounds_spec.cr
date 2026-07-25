require "../spec_helper"

module Rayz
  describe Bounds do
    it "creating an empty bounding box" do
      box = Bounds.new
      box.min.x.should eq(Float64::INFINITY)
      box.max.x.should eq(-Float64::INFINITY)
    end

    it "creating a bounding box with volume" do
      box = Bounds.new(min: Point.new(-1.0, -2.0, -3.0), max: Point.new(3.0, 2.0, 1.0))
      box.min.x.should be_close(-1.0, 1e-5)
      box.max.x.should be_close(3.0, 1e-5)
    end

    it "a ray parallel to an axis, grazing the box exactly at that axis's boundary, still intersects" do
      box = Bounds.new(min: Point.new(-1.0, -1.0, -1.0), max: Point.new(1.0, 1.0, 1.0))
      r = Ray.new(Point.new(1.0, 0.5, 0.0), Vector.new(0.0, 0.0, 1.0))
      box.intersects?(r).should be_true
    end

    it "a sphere has a bounding box" do
      box = Rayz.bounds_of(Sphere.new)
      box.min.x.should be_close(-1.0, 1e-5)
      box.max.x.should be_close(1.0, 1e-5)
    end

    it "a plane has a bounding box" do
      box = Rayz.bounds_of(Plane.new)
      box.min.x.should eq(-Float64::INFINITY)
      box.max.y.should be_close(0.0, 1e-5)
      box.max.x.should eq(Float64::INFINITY)
    end

    it "a cube has a bounding box" do
      box = Rayz.bounds_of(Cube.new)
      box.min.x.should be_close(-1.0, 1e-5)
      box.max.x.should be_close(1.0, 1e-5)
    end

    it "an unbounded cylinder has a bounding box" do
      box = Rayz.bounds_of(Cylinder.new)
      box.min.x.should be_close(-1.0, 1e-5)
      box.min.y.should eq(-Float64::INFINITY)
      box.max.y.should eq(Float64::INFINITY)
    end

    it "a bounded cylinder has a bounding box" do
      cyl = Cylinder.new
      cyl.minimum = -5.0
      cyl.maximum = 3.0
      box = Rayz.bounds_of(cyl)
      box.min.y.should be_close(-5.0, 1e-5)
      box.max.y.should be_close(3.0, 1e-5)
    end

    it "an unbounded cone has a bounding box" do
      box = Rayz.bounds_of(Cone.new)
      box.min.x.should eq(-Float64::INFINITY)
      box.max.x.should eq(Float64::INFINITY)
    end

    it "a bounded cone has a bounding box" do
      cone = Cone.new
      cone.minimum = -5.0
      cone.maximum = 3.0
      box = Rayz.bounds_of(cone)
      box.min.x.should be_close(-5.0, 1e-5)
      box.min.y.should be_close(-5.0, 1e-5)
      box.max.x.should be_close(5.0, 1e-5)
      box.max.y.should be_close(3.0, 1e-5)
    end

    it "a triangle has a bounding box" do
      tri = Triangle.new(Point.new(-3.0, 7.0, 2.0), Point.new(6.0, 2.0, -4.0), Point.new(2.0, -1.0, -1.0))
      box = Rayz.bounds_of(tri)
      box.min.x.should be_close(-3.0, 1e-5)
      box.min.y.should be_close(-1.0, 1e-5)
      box.min.z.should be_close(-4.0, 1e-5)
      box.max.x.should be_close(6.0, 1e-5)
      box.max.y.should be_close(7.0, 1e-5)
      box.max.z.should be_close(2.0, 1e-5)
    end

    it "adding one bounding box to another" do
      box1 = Bounds.new(min: Point.new(-5.0, -2.0, 0.0), max: Point.new(7.0, 4.0, 4.0))
      box2 = Bounds.new(min: Point.new(8.0, -7.0, -2.0), max: Point.new(14.0, 2.0, 8.0))
      box3 = box1.merge(box2)
      box3.min.x.should be_close(-5.0, 1e-5)
      box3.min.y.should be_close(-7.0, 1e-5)
      box3.max.x.should be_close(14.0, 1e-5)
      box3.max.y.should be_close(4.0, 1e-5)
    end

    it "checking if a box contains a point" do
      box = Bounds.new(min: Point.new(5.0, -2.0, 0.0), max: Point.new(11.0, 4.0, 7.0))
      box.contains_point?(Point.new(5.0, -2.0, 0.0)).should be_true
      box.contains_point?(Point.new(11.0, 4.0, 7.0)).should be_true
      box.contains_point?(Point.new(8.0, 1.0, 3.0)).should be_true
      box.contains_point?(Point.new(3.0, 0.0, 3.0)).should be_false
      box.contains_point?(Point.new(8.0, -4.0, 3.0)).should be_false
      box.contains_point?(Point.new(8.0, 1.0, -1.0)).should be_false
    end

    it "checking if a box contains another box" do
      box = Bounds.new(min: Point.new(5.0, -2.0, 0.0), max: Point.new(11.0, 4.0, 7.0))
      box.contains_bounds?(Bounds.new(min: Point.new(5.0, -2.0, 0.0), max: Point.new(11.0, 4.0, 7.0))).should be_true
      box.contains_bounds?(Bounds.new(min: Point.new(6.0, -1.0, 1.0), max: Point.new(10.0, 3.0, 6.0))).should be_true
      box.contains_bounds?(Bounds.new(min: Point.new(4.0, -3.0, -1.0), max: Point.new(10.0, 3.0, 6.0))).should be_false
      box.contains_bounds?(Bounds.new(min: Point.new(6.0, -1.0, 1.0), max: Point.new(12.0, 5.0, 8.0))).should be_false
    end

    it "transforming a bounding box" do
      box = Bounds.new(min: Point.new(-1.0, -1.0, -1.0), max: Point.new(1.0, 1.0, 1.0))
      m = Transformations.rotation_x(Math::PI / 4.0) * Transformations.rotation_y(Math::PI / 4.0)
      box2 = box.transform(m)
      box2.min.x.should be_close(-1.4142, 1e-4)
      box2.min.y.should be_close(-1.7071, 1e-4)
      box2.min.z.should be_close(-1.7071, 1e-4)
      box2.max.x.should be_close(1.4142, 1e-4)
      box2.max.y.should be_close(1.7071, 1e-4)
      box2.max.z.should be_close(1.7071, 1e-4)
    end

    [
      {Point.new(5.0, 0.5, 0.0), Vector.new(-1.0, 0.0, 0.0), true},
      {Point.new(-5.0, 0.5, 0.0), Vector.new(1.0, 0.0, 0.0), true},
      {Point.new(0.5, 5.0, 0.0), Vector.new(0.0, -1.0, 0.0), true},
      {Point.new(0.5, -5.0, 0.0), Vector.new(0.0, 1.0, 0.0), true},
      {Point.new(0.5, 0.0, 5.0), Vector.new(0.0, 0.0, -1.0), true},
      {Point.new(0.5, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), true},
      {Point.new(0.0, 0.5, 0.0), Vector.new(0.0, 0.0, 1.0), true},
      {Point.new(-2.0, 0.0, 0.0), Vector.new(2.0, 4.0, 6.0), false},
      {Point.new(0.0, -2.0, 0.0), Vector.new(6.0, 2.0, 4.0), false},
      {Point.new(0.0, 0.0, -2.0), Vector.new(4.0, 6.0, 2.0), false},
      {Point.new(2.0, 0.0, 2.0), Vector.new(0.0, 0.0, -1.0), false},
      {Point.new(0.0, 2.0, 2.0), Vector.new(0.0, -1.0, 0.0), false},
      {Point.new(2.0, 2.0, 0.0), Vector.new(-1.0, 0.0, 0.0), false},
    ].each_with_index do |(origin, dir, expected), i|
      it "intersecting ray with unit box (case #{i + 1})" do
        box = Bounds.new(min: Point.new(-1.0, -1.0, -1.0), max: Point.new(1.0, 1.0, 1.0))
        d = dir.normalize
        r = Ray.new(origin, Vector.new(d.x, d.y, d.z))
        box.intersects?(r).should eq(expected)
      end
    end

    it "a group has a bounding box containing its children" do
      s = Sphere.new
      s.transform = Transformations.translation(2.0, 5.0, -3.0) * Transformations.scaling(2.0, 2.0, 2.0)
      c = Cylinder.new
      c.minimum = -2.0
      c.maximum = 2.0
      c.transform = Transformations.translation(-4.0, -1.0, 4.0) * Transformations.scaling(0.5, 1.0, 0.5)
      g = Group.new
      g.add_child(s)
      g.add_child(c)
      box = Rayz.bounds_of(g)
      box.min.x.should be_close(-4.5, 1e-4)
      box.min.y.should be_close(-3.0, 1e-4)
      box.min.z.should be_close(-5.0, 1e-4)
      box.max.x.should be_close(4.0, 1e-4)
      box.max.y.should be_close(7.0, 1e-4)
      box.max.z.should be_close(4.5, 1e-4)
    end

    it "intersecting ray+group skips children if box is missed" do
      child = Sphere.new
      shape = Group.new
      shape.add_child(child)
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 1.0, 0.0))
      xs = shape.intersect(r)
      xs.should be_empty
    end

    it "intersecting ray+group tests children if box is hit" do
      shape = Group.new
      shape.add_child(Sphere.new)
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      xs = shape.intersect(r)
      xs.size.should eq(2)
    end
  end
end
