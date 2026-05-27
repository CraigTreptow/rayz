require "../spec_helper"

module Rayz
  describe AreaLight do
    it "creating an area light" do
      corner = Point.new(0.0, 0.0, 0.0)
      v1 = Vector.new(2.0, 0.0, 0.0)
      v2 = Vector.new(0.0, 0.0, 1.0)
      light = AreaLight.new(corner, v1, v2, 4, 2, Color.new(1.0, 1.0, 1.0))
      light.corner.should eq(corner)
      light.uvec.should eq(Vector.new(0.5, 0.0, 0.0))
      light.vvec.should eq(Vector.new(0.0, 0.0, 0.5))
      light.usteps.should eq(4)
      light.vsteps.should eq(2)
      light.samples.should eq(8)
      light.intensity.should eq(Color.new(1.0, 1.0, 1.0))
    end

    [
      {0, 0, Point.new(0.25, 0.0, 0.25)},
      {1, 0, Point.new(0.75, 0.0, 0.25)},
      {0, 1, Point.new(0.25, 0.0, 0.75)},
      {2, 0, Point.new(1.25, 0.0, 0.25)},
      {3, 1, Point.new(1.75, 0.0, 0.75)},
    ].each do |(u, v, expected)|
      it "finding a single point on an area light (u=#{u}, v=#{v})" do
        corner = Point.new(0.0, 0.0, 0.0)
        v1 = Vector.new(2.0, 0.0, 0.0)
        v2 = Vector.new(0.0, 0.0, 1.0)
        light = AreaLight.new(corner, v1, v2, 4, 2, Color.new(1.0, 1.0, 1.0))
        pt = light.point_on_light(u.to_f, v.to_f)
        pt.x.should be_close(expected.x, 1e-5)
        pt.y.should be_close(expected.y, 1e-5)
        pt.z.should be_close(expected.z, 1e-5)
      end
    end

    [
      {Point.new(0.0, 0.0, 2.0), 0.0},
      {Point.new(1.0, -1.0, 2.0), 0.25},
      {Point.new(1.5, 0.0, 2.0), 0.5},
      {Point.new(1.25, 1.25, 3.0), 0.75},
      {Point.new(0.0, 0.0, -2.0), 1.0},
    ].each do |(point, expected)|
      it "the area light intensity function (#{point.x}, #{point.y}, #{point.z})" do
        w = World.default_world
        corner = Point.new(-0.5, -0.5, -5.0)
        v1 = Vector.new(1.0, 0.0, 0.0)
        v2 = Vector.new(0.0, 1.0, 0.0)
        light = AreaLight.new(corner, v1, v2, 2, 2, Color.new(1.0, 1.0, 1.0))
        intensity = light.intensity_at(point, w)
        intensity.should be_close(expected, 1e-5)
      end
    end

    it "lighting with an area light" do
      corner = Point.new(-0.5, -0.5, -5.0)
      v1 = Vector.new(1.0, 0.0, 0.0)
      v2 = Vector.new(0.0, 1.0, 0.0)
      light = AreaLight.new(corner, v1, v2, 2, 2, Color.new(1.0, 1.0, 1.0))
      shape = Sphere.new
      shape.material.ambient = 0.1
      shape.material.diffuse = 0.9
      shape.material.specular = 0.0
      shape.material.color = Color.new(1.0, 1.0, 1.0)
      eye = Point.new(0.0, 0.0, -5.0)
      pt = Point.new(0.0, 0.0, -1.0)
      eyev = Vector.new(0.0, 0.0, 1.0)
      normalv = Vector.new(0.0, 0.0, -1.0)
      result = Rayz.lighting(shape.material, light, pt, eyev, normalv, 1.0, shape)
      result.red.should be_close(1.0, 1e-4)
      result.green.should be_close(1.0, 1e-4)
      result.blue.should be_close(1.0, 1e-4)
    end
  end
end
