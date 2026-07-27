require "../spec_helper"

module Rayz
  describe Group do
    it "creating a new group" do
      g = Group.new
      g.transform.should eq(Matrix.identity)
      g.empty?.should be_true
    end

    it "adding a child to a group" do
      g = Group.new
      s = Sphere.new
      g.add_child(s)
      g.empty?.should be_false
      g.includes?(s).should be_true
      s.parent.should_not be_nil
      s.parent.same?(g).should be_true
    end

    it "intersecting a ray with an empty group" do
      g = Group.new
      r = Ray.new(Point.new(0.0, 0.0, 0.0), Vector.new(0.0, 0.0, 1.0))
      xs = g.local_intersect(r)
      xs.should be_empty
    end

    it "intersecting a ray with a nonempty group" do
      g = Group.new
      s1 = Sphere.new
      s2 = Sphere.new
      s2.transform = Transformations.translation(0.0, 0.0, -3.0)
      s3 = Sphere.new
      s3.transform = Transformations.translation(5.0, 0.0, 0.0)
      g.add_child(s1)
      g.add_child(s2)
      g.add_child(s3)
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      xs = g.local_intersect(r)
      xs.size.should eq(4)
      xs[0].object.same?(s2).should be_true
      xs[1].object.same?(s2).should be_true
      xs[2].object.same?(s1).should be_true
      xs[3].object.same?(s1).should be_true
    end

    it "intersecting a transformed group" do
      g = Group.new
      g.transform = Transformations.scaling(2.0, 2.0, 2.0)
      s = Sphere.new
      s.transform = Transformations.translation(5.0, 0.0, 0.0)
      g.add_child(s)
      r = Ray.new(Point.new(10.0, 0.0, -10.0), Vector.new(0.0, 0.0, 1.0))
      xs = g.intersect(r)
      xs.size.should eq(2)
    end

    it "cached bounds are invalidated when a child is added after the cache is primed" do
      g = Group.new
      s1 = Sphere.new
      g.add_child(s1)

      r = Ray.new(Point.new(10.0, 0.0, -10.0), Vector.new(0.0, 0.0, 1.0))
      g.local_intersect(r).should be_empty # primes @cached_bounds, misses s1

      s2 = Sphere.new
      s2.transform = Transformations.translation(10.0, 0.0, 0.0)
      g.add_child(s2)

      xs = g.local_intersect(r)
      xs.size.should eq(2)
      xs[0].object.same?(s2).should be_true
    end

    it "cached bounds are invalidated when a child's transform changes after the cache is primed" do
      g = Group.new
      s = Sphere.new
      g.add_child(s)

      r = Ray.new(Point.new(10.0, 0.0, -10.0), Vector.new(0.0, 0.0, 1.0))
      g.local_intersect(r).should be_empty # primes @cached_bounds around the untransformed sphere

      s.transform = Transformations.translation(10.0, 0.0, 0.0)

      xs = g.local_intersect(r)
      xs.size.should eq(2)
    end

    it "converting a point from world to object space" do
      g1 = Group.new
      g1.transform = Transformations.rotation_y(Math::PI / 2.0)
      g2 = Group.new
      g2.transform = Transformations.scaling(2.0, 2.0, 2.0)
      g1.add_child(g2)
      s = Sphere.new
      s.transform = Transformations.translation(5.0, 0.0, 0.0)
      g2.add_child(s)
      p = s.world_to_object(Point.new(-2.0, 0.0, -10.0))
      p.x.should be_close(0.0, 1e-5)
      p.y.should be_close(0.0, 1e-5)
      p.z.should be_close(-1.0, 1e-5)
    end

    it "converting a normal from object to world space" do
      g1 = Group.new
      g1.transform = Transformations.rotation_y(Math::PI / 2.0)
      g2 = Group.new
      g2.transform = Transformations.scaling(1.0, 2.0, 3.0)
      g1.add_child(g2)
      s = Sphere.new
      s.transform = Transformations.translation(5.0, 0.0, 0.0)
      g2.add_child(s)
      v = Math.sqrt(3.0) / 3.0
      n = s.normal_to_world(Vector.new(v, v, v))
      n.x.should be_close(0.2857, 1e-4)
      n.y.should be_close(0.4286, 1e-4)
      n.z.should be_close(-0.8571, 1e-4)
    end

    it "finding the normal on a child object" do
      g1 = Group.new
      g1.transform = Transformations.rotation_y(Math::PI / 2.0)
      g2 = Group.new
      g2.transform = Transformations.scaling(1.0, 2.0, 3.0)
      g1.add_child(g2)
      s = Sphere.new
      s.transform = Transformations.translation(5.0, 0.0, 0.0)
      g2.add_child(s)
      n = s.normal_at(Point.new(1.7321, 1.1547, -5.5774))
      n.x.should be_close(0.2857, 1e-4)
      n.y.should be_close(0.4286, 1e-4)
      n.z.should be_close(-0.8571, 1e-4)
    end
  end
end
