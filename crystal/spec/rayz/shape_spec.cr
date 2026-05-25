require "../spec_helper"

module Rayz
  class TestShape < Shape
    property saved_ray : Ray?

    def initialize
      super
      @saved_ray = nil
    end

    def local_intersect(local_ray : Ray) : Array(Intersection)
      @saved_ray = local_ray
      [] of Intersection
    end

    def local_normal_at(local_point : Point) : Tuple
      Vector.new(local_point.x, local_point.y, local_point.z)
    end
  end

  describe Shape do
    it "default transform is identity" do
      s = TestShape.new
      s.transform.should eq(Matrix.identity)
    end

    it "assigning a transform" do
      s = TestShape.new
      s.transform = Transformations.translation(2.0, 3.0, 4.0)
      s.transform.should eq(Transformations.translation(2.0, 3.0, 4.0))
    end

    it "default material" do
      s = TestShape.new
      s.material.ambient.should be_close(0.1, 1e-5)
    end

    it "assigning a material" do
      s = TestShape.new
      m = Material.new
      m.ambient = 1.0
      s.material = m
      s.material.ambient.should be_close(1.0, 1e-5)
    end

    it "intersecting a scaled shape with a ray" do
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      s = TestShape.new
      s.transform = Transformations.scaling(2.0, 2.0, 2.0)
      s.intersect(r)
      saved = s.saved_ray.not_nil!
      saved.origin.x.should be_close(0.0, 1e-5)
      saved.origin.y.should be_close(0.0, 1e-5)
      saved.origin.z.should be_close(-2.5, 1e-5)
      saved.direction.x.should be_close(0.0, 1e-5)
      saved.direction.y.should be_close(0.0, 1e-5)
      saved.direction.z.should be_close(0.5, 1e-5)
    end

    it "intersecting a translated shape with a ray" do
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      s = TestShape.new
      s.transform = Transformations.translation(5.0, 0.0, 0.0)
      s.intersect(r)
      saved = s.saved_ray.not_nil!
      saved.origin.x.should be_close(-5.0, 1e-5)
      saved.origin.y.should be_close(0.0, 1e-5)
      saved.origin.z.should be_close(-5.0, 1e-5)
      saved.direction.x.should be_close(0.0, 1e-5)
      saved.direction.y.should be_close(0.0, 1e-5)
      saved.direction.z.should be_close(1.0, 1e-5)
    end

    it "computing the normal on a translated shape" do
      s = TestShape.new
      s.transform = Transformations.translation(0.0, 1.0, 0.0)
      n = s.normal_at(Point.new(0.0, 1.70711, -0.70711))
      n.x.should be_close(0.0, 1e-4)
      n.y.should be_close(0.70711, 1e-4)
      n.z.should be_close(-0.70711, 1e-4)
    end

    it "computing the normal on a transformed shape" do
      s = TestShape.new
      s.transform = Transformations.scaling(1.0, 0.5, 1.0) * Transformations.rotation_z(Math::PI / 5.0)
      v = Math.sqrt(2.0) / 2.0
      n = s.normal_at(Point.new(0.0, v, -v))
      n.x.should be_close(0.0, 1e-4)
      n.y.should be_close(0.97014, 1e-4)
      n.z.should be_close(-0.24254, 1e-4)
    end

    it "a shape has a parent attribute defaulting to nil" do
      s = TestShape.new
      s.parent.should be_nil
    end
  end
end
