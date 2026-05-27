require "../spec_helper"

module Rayz
  describe Spotlight do
    it "creating a spotlight" do
      light = Spotlight.new(
        Point.new(0.0, 10.0, 0.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(0.0, -1.0, 0.0),
        Math::PI / 6.0
      )
      light.position.should eq(Point.new(0.0, 10.0, 0.0))
      light.direction.should eq(Vector.new(0.0, -1.0, 0.0))
      light.cone_angle.should be_close(Math::PI / 6.0, 1e-5)
      light.fade_angle.should be_close(Math::PI / 6.0, 1e-5)
    end

    it "fade_angle defaults to cone_angle for a hard edge" do
      light = Spotlight.new(
        Point.new(0.0, 10.0, 0.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(0.0, -1.0, 0.0),
        Math::PI / 4.0
      )
      light.cone_angle.should be_close(light.fade_angle, 1e-5)
    end

    it "point directly under spotlight is fully lit" do
      w = World.new
      floor = Plane.new
      w.objects << floor
      light = Spotlight.new(
        Point.new(0.0, 5.0, 0.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(0.0, -1.0, 0.0),
        Math::PI / 4.0
      )
      w.light = light
      intensity = light.intensity_at(Point.new(0.0, 0.001, 0.0), w)
      intensity.should be_close(1.0, 1e-5)
    end

    it "point outside the cone has zero intensity" do
      w = World.new
      light = Spotlight.new(
        Point.new(0.0, 5.0, 0.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(0.0, -1.0, 0.0),
        Math::PI / 6.0
      )
      w.light = light
      # Far to the side — well outside the 30-degree cone
      intensity = light.intensity_at(Point.new(10.0, 0.0, 0.0), w)
      intensity.should be_close(0.0, 1e-5)
    end

    it "point in the fade zone has partial intensity" do
      w = World.new
      light = Spotlight.new(
        Point.new(0.0, 5.0, 0.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(0.0, -1.0, 0.0),
        Math::PI / 4.0, # outer cone: 45°
        Math::PI / 8.0  # inner cone: 22.5°
      )
      w.light = light
      # Point at 35° from axis — between inner (22.5°) and outer (45°)
      angle = 35.0 * Math::PI / 180.0
      x = Math.sin(angle) * 5.0
      y = Math.cos(angle) * 5.0 # reuse for distance
      intensity = light.intensity_at(Point.new(x, 5.0 - y, 0.0), w)
      intensity.should be > 0.0
      intensity.should be < 1.0
    end

    it "world shades correctly with a spotlight" do
      w = World.default_world
      w.light = Spotlight.new(
        Point.new(-10.0, 10.0, -10.0),
        Color.new(1.0, 1.0, 1.0),
        Vector.new(1.0, -1.0, 1.0),
        Math::PI / 3.0
      )
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      xs = w.intersect(r)
      hit = Rayz.hit(xs).not_nil!
      comps = hit.prepare_computations(r, xs)
      c = w.shade_hit(comps)
      c.red.should be >= 0.0
      c.green.should be >= 0.0
      c.blue.should be >= 0.0
    end
  end
end
