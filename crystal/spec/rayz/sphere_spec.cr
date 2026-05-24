require "../spec_helper"

describe "Sphere" do
  it "A ray intersects a sphere at two points" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].t.should be_close(4.0, 0.0001)
    xs[1].t.should be_close(6.0, 0.0001)
  end

  it "A ray intersects a sphere at a tangent" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 1.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].t.should be_close(5.0, 0.0001)
    xs[1].t.should be_close(5.0, 0.0001)
  end

  it "A ray misses a sphere" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 2.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(0)
  end

  it "A ray originates inside a sphere" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].t.should be_close(-1.0, 0.0001)
    xs[1].t.should be_close(1.0, 0.0001)
  end

  it "A sphere is behind a ray" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].t.should be_close(-6.0, 0.0001)
    xs[1].t.should be_close(-4.0, 0.0001)
  end

  it "Intersect sets the object on the intersection" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].object.should eq(s)
    xs[1].object.should eq(s)
  end

  it "A sphere's default transformation" do
    s = Rayz::Sphere.new
    s.transform.should eq(Rayz::Matrix.identity)
  end

  it "Changing a sphere's transformation" do
    s = Rayz::Sphere.new
    t = Rayz::Transformations.translation(2, 3, 4)
    s.transform = t
    s.transform.should eq(t)
  end

  it "Intersecting a scaled sphere with a ray" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    s.transform = Rayz::Transformations.scaling(2, 2, 2)
    xs = s.intersect(r)
    xs.size.should eq(2)
    xs[0].t.should be_close(3.0, 0.0001)
    xs[1].t.should be_close(7.0, 0.0001)
  end

  it "Intersecting a translated sphere with a ray" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    s = Rayz::Sphere.new
    s.transform = Rayz::Transformations.translation(5, 0, 0)
    xs = s.intersect(r)
    xs.size.should eq(0)
  end

  it "The normal on a sphere at a point on the x axis" do
    s = Rayz::Sphere.new
    n = s.normal_at(Rayz::Point.new(1.0, 0.0, 0.0))
    n.should eq(Rayz::Vector.new(1.0, 0.0, 0.0))
  end

  it "The normal on a sphere at a point on the y axis" do
    s = Rayz::Sphere.new
    n = s.normal_at(Rayz::Point.new(0.0, 1.0, 0.0))
    n.should eq(Rayz::Vector.new(0.0, 1.0, 0.0))
  end

  it "The normal on a sphere at a point on the z axis" do
    s = Rayz::Sphere.new
    n = s.normal_at(Rayz::Point.new(0.0, 0.0, 1.0))
    n.should eq(Rayz::Vector.new(0.0, 0.0, 1.0))
  end

  it "The normal on a sphere at a nonaxial point" do
    s = Rayz::Sphere.new
    v = Math.sqrt(3.0) / 3.0
    n = s.normal_at(Rayz::Point.new(v, v, v))
    n.should eq(Rayz::Vector.new(v, v, v))
  end

  it "The normal is a normalized vector" do
    s = Rayz::Sphere.new
    v = Math.sqrt(3.0) / 3.0
    n = s.normal_at(Rayz::Point.new(v, v, v))
    n.should eq(n.normalize)
  end

  it "Computing the normal on a translated sphere" do
    s = Rayz::Sphere.new
    s.transform = Rayz::Transformations.translation(0, 1, 0)
    n = s.normal_at(Rayz::Point.new(0.0, 1.70711, -0.70711))
    n.should eq(Rayz::Vector.new(0.0, 0.70711, -0.70711))
  end

  it "Computing the normal on a transformed sphere" do
    s = Rayz::Sphere.new
    s.transform = Rayz::Transformations.scaling(1, 0.5, 1) * Rayz::Transformations.rotation_z(Math::PI / 5)
    n = s.normal_at(Rayz::Point.new(0.0, Math.sqrt(2.0) / 2.0, -Math.sqrt(2.0) / 2.0))
    n.should eq(Rayz::Vector.new(0.0, 0.97014, -0.24254))
  end

  it "A sphere has a default material" do
    s = Rayz::Sphere.new
    s.material.should eq(Rayz::Material.new)
  end

  it "A sphere may be assigned a material" do
    s = Rayz::Sphere.new
    m = Rayz::Material.new
    m.ambient = 1.0
    s.material = m
    s.material.should eq(m)
  end

  it "A helper for producing a sphere with a glassy material" do
    s = Rayz.glass_sphere
    s.transform.should eq(Rayz::Matrix.identity)
    s.material.transparency.should be_close(1.0, 0.0001)
    s.material.refractive_index.should be_close(1.5, 0.0001)
  end
end
