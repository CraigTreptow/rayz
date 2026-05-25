require "../spec_helper"

module Rayz
  describe Cylinder do
    describe "local_intersect" do
      it "ray misses cylinder (tangent along y)" do
        cyl = Cylinder.new
        dir = Vector.new(0.0, 1.0, 0.0).normalize
        direction = Vector.new(dir.x, dir.y, dir.z)
        r = Ray.new(Point.new(1.0, 0.0, 0.0), direction)
        xs = cyl.local_intersect(r)
        xs.size.should eq(0)
      end

      it "ray misses cylinder (inside, pointing up)" do
        cyl = Cylinder.new
        dir = Vector.new(0.0, 1.0, 0.0).normalize
        direction = Vector.new(dir.x, dir.y, dir.z)
        r = Ray.new(Point.new(0.0, 0.0, 0.0), direction)
        xs = cyl.local_intersect(r)
        xs.size.should eq(0)
      end

      it "ray misses cylinder (diagonal)" do
        cyl = Cylinder.new
        dir = Vector.new(1.0, 1.0, 1.0).normalize
        direction = Vector.new(dir.x, dir.y, dir.z)
        r = Ray.new(Point.new(0.0, 0.0, -5.0), direction)
        xs = cyl.local_intersect(r)
        xs.size.should eq(0)
      end

      [
        {Point.new(1.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 5.0, 5.0},
        {Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 4.0, 6.0},
        {Point.new(0.5, 0.0, -5.0), Vector.new(0.1, 1.0, 1.0), 6.80798, 7.08872},
      ].each_with_index do |(origin, dir_raw, t0, t1), i|
        it "ray strikes cylinder (case #{i + 1})" do
          cyl = Cylinder.new
          dir = dir_raw.normalize
          direction = Vector.new(dir.x, dir.y, dir.z)
          r = Ray.new(origin, direction)
          xs = cyl.local_intersect(r)
          xs.size.should eq(2)
          xs[0].t.should be_close(t0, 1e-4)
          xs[1].t.should be_close(t1, 1e-4)
        end
      end
    end

    describe "local_normal_at" do
      [
        {Point.new(1.0, 0.0, 0.0), Vector.new(1.0, 0.0, 0.0)},
        {Point.new(0.0, 5.0, -1.0), Vector.new(0.0, 0.0, -1.0)},
        {Point.new(0.0, -2.0, 1.0), Vector.new(0.0, 0.0, 1.0)},
        {Point.new(-1.0, 1.0, 0.0), Vector.new(-1.0, 0.0, 0.0)},
      ].each_with_index do |(point, expected), i|
        it "normal on cylinder surface (case #{i + 1})" do
          cyl = Cylinder.new
          n = cyl.local_normal_at(point)
          n.x.should be_close(expected.x, 1e-5)
          n.y.should be_close(expected.y, 1e-5)
          n.z.should be_close(expected.z, 1e-5)
        end
      end
    end

    it "default minimum and maximum are infinite" do
      cyl = Cylinder.new
      cyl.minimum.should eq(-Float64::INFINITY)
      cyl.maximum.should eq(Float64::INFINITY)
    end

    it "default closed is false" do
      cyl = Cylinder.new
      cyl.closed.should be_false
    end

    describe "constrained cylinder" do
      [
        {Point.new(0.0, 1.5, 0.0), Vector.new(0.1, 1.0, 0.0), 0},
        {Point.new(0.0, 3.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0},
        {Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0},
        {Point.new(0.0, 2.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0},
        {Point.new(0.0, 1.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0},
        {Point.new(0.0, 1.5, -2.0), Vector.new(0.0, 0.0, 1.0), 2},
      ].each_with_index do |(origin, dir_raw, count), i|
        it "intersecting constrained cylinder (case #{i + 1})" do
          cyl = Cylinder.new
          cyl.minimum = 1.0
          cyl.maximum = 2.0
          dir = dir_raw.normalize
          direction = Vector.new(dir.x, dir.y, dir.z)
          r = Ray.new(origin, direction)
          xs = cyl.local_intersect(r)
          xs.size.should eq(count)
        end
      end
    end

    describe "closed cylinder caps" do
      [
        {Point.new(0.0, 3.0, 0.0), Vector.new(0.0, -1.0, 0.0), 2},
        {Point.new(0.0, 3.0, -2.0), Vector.new(0.0, -1.0, 2.0), 2},
        {Point.new(0.0, 4.0, -2.0), Vector.new(0.0, -1.0, 1.0), 2},
        {Point.new(0.0, 0.0, -2.0), Vector.new(0.0, 1.0, 2.0), 2},
        {Point.new(0.0, -1.0, -2.0), Vector.new(0.0, 1.0, 1.0), 2},
      ].each_with_index do |(origin, dir_raw, count), i|
        it "intersecting caps of closed cylinder (case #{i + 1})" do
          cyl = Cylinder.new
          cyl.minimum = 1.0
          cyl.maximum = 2.0
          cyl.closed = true
          dir = dir_raw.normalize
          direction = Vector.new(dir.x, dir.y, dir.z)
          r = Ray.new(origin, direction)
          xs = cyl.local_intersect(r)
          xs.size.should eq(count)
        end
      end
    end

    describe "cap normals" do
      [
        {Point.new(0.0, 1.0, 0.0), Vector.new(0.0, -1.0, 0.0)},
        {Point.new(0.5, 1.0, 0.0), Vector.new(0.0, -1.0, 0.0)},
        {Point.new(0.0, 1.0, 0.5), Vector.new(0.0, -1.0, 0.0)},
        {Point.new(0.0, 2.0, 0.0), Vector.new(0.0, 1.0, 0.0)},
        {Point.new(0.5, 2.0, 0.0), Vector.new(0.0, 1.0, 0.0)},
        {Point.new(0.0, 2.0, 0.5), Vector.new(0.0, 1.0, 0.0)},
      ].each_with_index do |(point, expected), i|
        it "normal on cylinder end cap (case #{i + 1})" do
          cyl = Cylinder.new
          cyl.minimum = 1.0
          cyl.maximum = 2.0
          cyl.closed = true
          n = cyl.local_normal_at(point)
          n.x.should be_close(expected.x, 1e-5)
          n.y.should be_close(expected.y, 1e-5)
          n.z.should be_close(expected.z, 1e-5)
        end
      end
    end
  end
end
