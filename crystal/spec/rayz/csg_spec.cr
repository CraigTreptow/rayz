require "../spec_helper"

module Rayz
  describe CSG do
    it "CSG is created with an operation and two shapes" do
      s1 = Sphere.new
      s2 = Cube.new
      c = CSG.new("union", s1, s2)
      c.operation.should eq("union")
      c.left.same?(s1).should be_true
      c.right.same?(s2).should be_true
      s1.parent.same?(c).should be_true
      s2.parent.same?(c).should be_true
    end

    describe "intersection_allowed?" do
      [
        {"union", true, true, true, false},
        {"union", true, true, false, true},
        {"union", true, false, true, false},
        {"union", true, false, false, true},
        {"union", false, true, true, false},
        {"union", false, true, false, false},
        {"union", false, false, true, true},
        {"union", false, false, false, true},
        {"intersection", true, true, true, true},
        {"intersection", true, true, false, false},
        {"intersection", true, false, true, true},
        {"intersection", true, false, false, false},
        {"intersection", false, true, true, true},
        {"intersection", false, true, false, true},
        {"intersection", false, false, true, false},
        {"intersection", false, false, false, false},
        {"difference", true, true, true, false},
        {"difference", true, true, false, true},
        {"difference", true, false, true, false},
        {"difference", true, false, false, true},
        {"difference", false, true, true, true},
        {"difference", false, true, false, true},
        {"difference", false, false, true, false},
        {"difference", false, false, false, false},
      ].each do |op, lhit, inl, inr, expected|
        it "#{op} lhit=#{lhit} inl=#{inl} inr=#{inr} => #{expected}" do
          c = CSG.new(op, Sphere.new, Cube.new)
          c.intersection_allowed?(lhit, inl, inr).should eq(expected)
        end
      end
    end

    describe "filter_intersections" do
      [
        {"union", 0, 3},
        {"intersection", 1, 2},
        {"difference", 0, 1},
      ].each do |op, x0, x1|
        it "filtering intersections for #{op}" do
          s1 = Sphere.new
          s2 = Cube.new
          c = CSG.new(op, s1, s2)
          xs = [
            Intersection.new(1.0, s1),
            Intersection.new(2.0, s2),
            Intersection.new(3.0, s1),
            Intersection.new(4.0, s2),
          ]
          result = c.filter_intersections(xs)
          result.size.should eq(2)
          result[0].t.should be_close(xs[x0].t, 1e-5)
          result[1].t.should be_close(xs[x1].t, 1e-5)
        end
      end
    end

    it "a ray misses a CSG object" do
      c = CSG.new("union", Sphere.new, Cube.new)
      r = Ray.new(Point.new(0.0, 2.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      xs = c.local_intersect(r)
      xs.should be_empty
    end

    it "a ray hits a CSG object" do
      s1 = Sphere.new
      s2 = Sphere.new
      s2.transform = Transformations.translation(0.0, 0.0, 0.5)
      c = CSG.new("union", s1, s2)
      r = Ray.new(Point.new(0.0, 0.0, -5.0), Vector.new(0.0, 0.0, 1.0))
      xs = c.local_intersect(r)
      xs.size.should eq(2)
      xs[0].t.should be_close(4.0, 1e-5)
      xs[0].object.same?(s1).should be_true
      xs[1].t.should be_close(6.5, 1e-5)
      xs[1].object.same?(s2).should be_true
    end
  end
end
