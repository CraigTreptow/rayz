require "../spec_helper"

module Rayz
  describe Cone do
    describe "local_intersect" do
      [
        {Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 5.0, 5.0},
        {Point.new(0.0, 0.0, -5.0), Vector.new(1.0, 1.0, 1.0), 8.66025, 8.66025},
        {Point.new(1.0, 1.0, -5.0), Vector.new(-0.5, -1.0, 1.0), 4.55006, 49.44994},
      ].each_with_index do |(origin, dir_raw, t0, t1), i|
        it "intersecting a cone with a ray (case #{i + 1})" do
          shape = Cone.new
          dir = dir_raw.normalize
          direction = Vector.new(dir.x, dir.y, dir.z)
          r = Ray.new(origin, direction)
          xs = shape.local_intersect(r)
          xs.size.should eq(2)
          xs[0].t.should be_close(t0, 1e-4)
          xs[1].t.should be_close(t1, 1e-4)
        end
      end

      it "intersecting a cone with a ray parallel to one half" do
        shape = Cone.new
        dir = Vector.new(0.0, 1.0, 1.0).normalize
        direction = Vector.new(dir.x, dir.y, dir.z)
        r = Ray.new(Point.new(0.0, 0.0, -1.0), direction)
        xs = shape.local_intersect(r)
        xs.size.should eq(1)
        xs[0].t.should be_close(0.35355, 1e-4)
      end

      [
        {Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 1.0, 0.0), 0},
        {Point.new(0.0, 0.0, -0.25), Vector.new(0.0, 1.0, 1.0), 2},
        {Point.new(0.0, 0.0, -0.25), Vector.new(0.0, 1.0, 0.0), 4},
      ].each_with_index do |(origin, dir_raw, count), i|
        it "intersecting a cone's end caps (case #{i + 1})" do
          shape = Cone.new
          shape.minimum = -0.5
          shape.maximum = 0.5
          shape.closed = true
          dir = dir_raw.normalize
          direction = Vector.new(dir.x, dir.y, dir.z)
          r = Ray.new(origin, direction)
          xs = shape.local_intersect(r)
          xs.size.should eq(count)
        end
      end
    end

    describe "local_normal_at" do
      [
        {Point.new(0.0, 0.0, 0.0), Vector.new(0.0, 0.0, 0.0)},
        {Point.new(1.0, 1.0, 1.0), Vector.new(1.0, -Math.sqrt(2.0), 1.0)},
        {Point.new(-1.0, -1.0, 0.0), Vector.new(-1.0, 1.0, 0.0)},
      ].each_with_index do |(point, expected), i|
        it "normal on cone (case #{i + 1})" do
          shape = Cone.new
          n = shape.local_normal_at(point)
          n.x.should be_close(expected.x, 1e-4)
          n.y.should be_close(expected.y, 1e-4)
          n.z.should be_close(expected.z, 1e-4)
        end
      end
    end
  end
end
