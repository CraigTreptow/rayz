require "../spec_helper"

module Rayz
  describe Cube do
    describe "local_intersect" do
      [
        {"+x", Point.new(5.0, 0.5, 0.0), Vector.new(-1.0, 0.0, 0.0), 4.0, 6.0},
        {"-x", Point.new(-5.0, 0.5, 0.0), Vector.new(1.0, 0.0, 0.0), 4.0, 6.0},
        {"+y", Point.new(0.5, 5.0, 0.0), Vector.new(0.0, -1.0, 0.0), 4.0, 6.0},
        {"-y", Point.new(0.5, -5.0, 0.0), Vector.new(0.0, 1.0, 0.0), 4.0, 6.0},
        {"+z", Point.new(0.5, 0.0, 5.0), Vector.new(0.0, 0.0, -1.0), 4.0, 6.0},
        {"-z", Point.new(0.5, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 4.0, 6.0},
        {"inside", Point.new(0.0, 0.5, 0.0), Vector.new(0.0, 0.0, 1.0), -1.0, 1.0},
      ].each do |label, origin, direction, t1, t2|
        it "ray intersects cube face #{label}" do
          c = Cube.new
          r = Ray.new(origin, direction)
          xs = c.local_intersect(r)
          xs.size.should eq(2)
          xs[0].t.should be_close(t1, 1e-5)
          xs[1].t.should be_close(t2, 1e-5)
        end
      end

      it "a ray parallel to an axis, grazing a face exactly at that axis's boundary" do
        c = Cube.new
        r = Ray.new(Point.new(1.0, 0.5, 0.0), Vector.new(0.0, 0.0, 1.0))
        xs = c.local_intersect(r)
        xs.size.should eq(2)
        xs[0].t.should be_close(-1.0, 1e-5)
        xs[1].t.should be_close(1.0, 1e-5)
      end

      [
        {Point.new(-2.0, 0.0, 0.0), Vector.new(0.2673, 0.5345, 0.8018)},
        {Point.new(0.0, -2.0, 0.0), Vector.new(0.8018, 0.2673, 0.5345)},
        {Point.new(0.0, 0.0, -2.0), Vector.new(0.5345, 0.8018, 0.2673)},
        {Point.new(2.0, 0.0, 2.0), Vector.new(0.0, 0.0, -1.0)},
        {Point.new(0.0, 2.0, 2.0), Vector.new(0.0, -1.0, 0.0)},
        {Point.new(2.0, 2.0, 0.0), Vector.new(-1.0, 0.0, 0.0)},
      ].each_with_index do |(origin, direction), i|
        it "ray misses cube (case #{i + 1})" do
          c = Cube.new
          r = Ray.new(origin, direction)
          xs = c.local_intersect(r)
          xs.size.should eq(0)
        end
      end
    end

    describe "local_normal_at" do
      [
        {Point.new(1.0, 0.5, -0.8), Vector.new(1.0, 0.0, 0.0)},
        {Point.new(-1.0, -0.2, 0.9), Vector.new(-1.0, 0.0, 0.0)},
        {Point.new(-0.4, 1.0, -0.1), Vector.new(0.0, 1.0, 0.0)},
        {Point.new(0.3, -1.0, -0.7), Vector.new(0.0, -1.0, 0.0)},
        {Point.new(-0.6, 0.3, 1.0), Vector.new(0.0, 0.0, 1.0)},
        {Point.new(0.4, 0.4, -1.0), Vector.new(0.0, 0.0, -1.0)},
        {Point.new(1.0, 1.0, 1.0), Vector.new(1.0, 0.0, 0.0)},
        {Point.new(-1.0, -1.0, -1.0), Vector.new(-1.0, 0.0, 0.0)},
      ].each_with_index do |(point, expected_normal), i|
        it "normal on surface of cube (case #{i + 1})" do
          c = Cube.new
          n = c.local_normal_at(point)
          n.x.should be_close(expected_normal.x, 1e-5)
          n.y.should be_close(expected_normal.y, 1e-5)
          n.z.should be_close(expected_normal.z, 1e-5)
        end
      end
    end
  end
end
