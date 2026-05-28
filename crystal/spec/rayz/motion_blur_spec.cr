require "../spec_helper"

module Rayz
  describe "Motion Blur" do
    it "ray has a default time of 0.0" do
      r = Ray.new(Point.new(0.0, 0.0, 0.0), Vector.new(0.0, 0.0, 1.0))
      r.time.should be_close(0.0, 1e-5)
    end

    it "ray preserves time through transform" do
      r = Ray.new(Point.new(0.0, 0.0, 0.0), Vector.new(0.0, 0.0, 1.0), 0.5)
      r2 = r.transform(Transformations.translation(1.0, 0.0, 0.0))
      r2.time.should be_close(0.5, 1e-5)
    end

    it "shape has no motion_transform by default" do
      s = Sphere.new
      s.motion_transform.should be_nil
    end

    it "motion_transform shifts shape position at time > 0" do
      s = Sphere.new
      s.motion_transform = ->(t : Float64) {
        Transformations.translation(t * 2.0, 0.0, 0.0)
      }

      r0 = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0.0)
      r1 = Ray.new(Point.new(2.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 1.0)

      xs0 = s.intersect(r0)
      xs1 = s.intersect(r1)

      xs0.size.should eq(2)
      xs1.size.should eq(2)
    end

    it "static shape intersects the same regardless of ray time" do
      s = Sphere.new
      r0 = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0.0)
      r1 = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0), 0.7)
      xs0 = s.intersect(r0)
      xs1 = s.intersect(r1)
      xs0.size.should eq(xs1.size)
      xs0[0].t.should be_close(xs1[0].t, 1e-5)
    end

    it "camera has motion_blur disabled by default" do
      c = Camera.new(100, 50, Math::PI / 3.0)
      c.motion_blur.should be_false
    end

    it "camera with motion_blur renders without error" do
      w = World.default_world
      c = Camera.new(11, 11, Math::PI / 2.0, samples_per_pixel: 4, motion_blur: true)
      c.transform = Transformations.view_transform(
        Point.new(0.0, 0.0, -5.0),
        Point.new(0.0, 0.0, 0.0),
        Vector.new(0.0, 1.0, 0.0)
      )
      image = c.render(w)
      image.width.should eq(11)
      image.height.should eq(11)
    end
  end
end
