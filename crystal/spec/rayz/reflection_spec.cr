require "../spec_helper"

describe "glass_sphere" do
  it "A helper for producing a sphere with a glassy material" do
    s = Rayz.glass_sphere
    s.transform.should eq(Rayz::Matrix.identity)
    s.material.transparency.should be_close(1.0, 0.0001)
    s.material.refractive_index.should be_close(1.5, 0.0001)
  end
end

describe "prepare_computations" do
  it "Precomputing the reflection vector" do
    shape = Rayz::Plane.new
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 1.0, -1.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    i = Rayz::Intersection.new(Math.sqrt(2.0), shape)
    comps = i.prepare_computations(r)
    comps.reflectv.should eq(Rayz::Vector.new(0.0, Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0))
  end

  it "The under point is offset below the surface" do
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    shape = Rayz.glass_sphere
    shape.transform = Rayz::Transformations.translation(0.0, 0.0, 1.0)
    i = Rayz::Intersection.new(5.0, shape)
    xs = [i]
    comps = i.prepare_computations(r, xs)
    (comps.under_point.z > Rayz::Util::EPSILON / 2).should be_true
    (comps.point.z < comps.under_point.z).should be_true
  end

  it "Finding n1 and n2: index 0" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[0].prepare_computations(r, xs)
    comps.n1.should be_close(1.0, 0.0001)
    comps.n2.should be_close(1.5, 0.0001)
  end

  it "Finding n1 and n2: index 1" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[1].prepare_computations(r, xs)
    comps.n1.should be_close(1.5, 0.0001)
    comps.n2.should be_close(2.0, 0.0001)
  end

  it "Finding n1 and n2: index 2" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[2].prepare_computations(r, xs)
    comps.n1.should be_close(2.0, 0.0001)
    comps.n2.should be_close(2.5, 0.0001)
  end

  it "Finding n1 and n2: index 3" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[3].prepare_computations(r, xs)
    comps.n1.should be_close(2.5, 0.0001)
    comps.n2.should be_close(2.5, 0.0001)
  end

  it "Finding n1 and n2: index 4" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[4].prepare_computations(r, xs)
    comps.n1.should be_close(2.5, 0.0001)
    comps.n2.should be_close(1.5, 0.0001)
  end

  it "Finding n1 and n2: index 5" do
    a = Rayz.glass_sphere
    a.transform = Rayz::Transformations.scaling(2.0, 2.0, 2.0)
    a.material.refractive_index = 1.5
    b = Rayz.glass_sphere
    b.transform = Rayz::Transformations.translation(0.0, 0.0, -0.25)
    b.material.refractive_index = 2.0
    c = Rayz.glass_sphere
    c.transform = Rayz::Transformations.translation(0.0, 0.0, 0.25)
    c.material.refractive_index = 2.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -4.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [
      Rayz::Intersection.new(2.0, a),
      Rayz::Intersection.new(2.75, b),
      Rayz::Intersection.new(3.25, c),
      Rayz::Intersection.new(4.75, b),
      Rayz::Intersection.new(5.25, c),
      Rayz::Intersection.new(6.0, a),
    ]
    comps = xs[5].prepare_computations(r, xs)
    comps.n1.should be_close(1.5, 0.0001)
    comps.n2.should be_close(1.0, 0.0001)
  end
end

describe "World reflection" do
  it "The reflected color for a nonreflective material" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    shape = w.objects[1]
    shape.material.ambient = 1.0
    i = Rayz::Intersection.new(1.0, shape)
    comps = i.prepare_computations(r)
    color = w.reflected_color(comps)
    color.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end

  it "The reflected color for a reflective material" do
    w = Rayz::World.default_world
    shape = Rayz::Plane.new
    shape.material.reflective = 0.5
    shape.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    w.objects << shape
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, -3.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    i = Rayz::Intersection.new(Math.sqrt(2.0), shape)
    comps = i.prepare_computations(r)
    color = w.reflected_color(comps)
    color.should eq(Rayz::Color.new(0.19032, 0.2379, 0.14274))
  end

  it "shade_hit() with a reflective material" do
    w = Rayz::World.default_world
    shape = Rayz::Plane.new
    shape.material.reflective = 0.5
    shape.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    w.objects << shape
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, -3.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    i = Rayz::Intersection.new(Math.sqrt(2.0), shape)
    comps = i.prepare_computations(r)
    color = w.shade_hit(comps)
    color.should eq(Rayz::Color.new(0.87677, 0.92436, 0.82918))
  end

  it "color_at() with mutually reflective surfaces terminates" do
    w = Rayz::World.new
    w.light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Color.new(1.0, 1.0, 1.0))
    lower = Rayz::Plane.new
    lower.material.reflective = 1.0
    lower.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    w.objects << lower
    upper = Rayz::Plane.new
    upper.material.reflective = 1.0
    upper.transform = Rayz::Transformations.translation(0.0, 1.0, 0.0)
    w.objects << upper
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    w.color_at(r) # should not infinite-loop
  end

  it "The reflected color at the maximum recursive depth" do
    w = Rayz::World.default_world
    shape = Rayz::Plane.new
    shape.material.reflective = 0.5
    shape.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    w.objects << shape
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, -3.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    i = Rayz::Intersection.new(Math.sqrt(2.0), shape)
    comps = i.prepare_computations(r)
    color = w.reflected_color(comps, 0)
    color.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end
end

describe "World refraction" do
  it "The refracted color with an opaque surface" do
    w = Rayz::World.default_world
    shape = w.objects[0]
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [Rayz::Intersection.new(4.0, shape), Rayz::Intersection.new(6.0, shape)]
    comps = xs[0].prepare_computations(r, xs)
    c = w.refracted_color(comps, 5)
    c.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end

  it "The refracted color at the maximum recursive depth" do
    w = Rayz::World.default_world
    shape = w.objects[0]
    shape.material.transparency = 1.0
    shape.material.refractive_index = 1.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [Rayz::Intersection.new(4.0, shape), Rayz::Intersection.new(6.0, shape)]
    comps = xs[0].prepare_computations(r, xs)
    c = w.refracted_color(comps, 0)
    c.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end

  it "The refracted color under total internal reflection" do
    w = Rayz::World.default_world
    shape = w.objects[0]
    shape.material.transparency = 1.0
    shape.material.refractive_index = 1.5
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, Math.sqrt(2.0) / 2.0),
      Rayz::Vector.new(0.0, 1.0, 0.0)
    )
    xs = [
      Rayz::Intersection.new(-Math.sqrt(2.0) / 2.0, shape),
      Rayz::Intersection.new(Math.sqrt(2.0) / 2.0, shape),
    ]
    comps = xs[1].prepare_computations(r, xs)
    c = w.refracted_color(comps, 5)
    c.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end

  it "The refracted color with a refracted ray" do
    w = Rayz::World.default_world
    a = w.objects[0]
    a.material.ambient = 1.0
    a.material.pattern = Rayz::TestPattern.new
    b = w.objects[1]
    b.material.transparency = 1.0
    b.material.refractive_index = 1.5
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.1), Rayz::Vector.new(0.0, 1.0, 0.0))
    xs = [
      Rayz::Intersection.new(-0.9899, a),
      Rayz::Intersection.new(-0.4899, b),
      Rayz::Intersection.new(0.4899, b),
      Rayz::Intersection.new(0.9899, a),
    ]
    comps = xs[2].prepare_computations(r, xs)
    c = w.refracted_color(comps, 5)
    c.should eq(Rayz::Color.new(0.0, 0.99888, 0.04725))
  end

  it "shade_hit() with a transparent material" do
    w = Rayz::World.default_world
    floor = Rayz::Plane.new
    floor.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    floor.material.transparency = 0.5
    floor.material.refractive_index = 1.5
    w.objects << floor
    ball = Rayz::Sphere.new
    ball.material.color = Rayz::Color.new(1.0, 0.0, 0.0)
    ball.material.ambient = 0.5
    ball.transform = Rayz::Transformations.translation(0.0, -3.5, -0.5)
    w.objects << ball
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, -3.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    xs = [Rayz::Intersection.new(Math.sqrt(2.0), floor)]
    comps = xs[0].prepare_computations(r, xs)
    color = w.shade_hit(comps, 5)
    color.should eq(Rayz::Color.new(0.93642, 0.68642, 0.68642))
  end

  it "shade_hit() with a reflective, transparent material" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, -3.0),
      Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, Math.sqrt(2.0) / 2.0)
    )
    floor = Rayz::Plane.new
    floor.transform = Rayz::Transformations.translation(0.0, -1.0, 0.0)
    floor.material.reflective = 0.5
    floor.material.transparency = 0.5
    floor.material.refractive_index = 1.5
    w.objects << floor
    ball = Rayz::Sphere.new
    ball.material.color = Rayz::Color.new(1.0, 0.0, 0.0)
    ball.material.ambient = 0.5
    ball.transform = Rayz::Transformations.translation(0.0, -3.5, -0.5)
    w.objects << ball
    xs = [Rayz::Intersection.new(Math.sqrt(2.0), floor)]
    comps = xs[0].prepare_computations(r, xs)
    color = w.shade_hit(comps, 5)
    color.should eq(Rayz::Color.new(0.93391, 0.69643, 0.69243))
  end
end

describe "Schlick" do
  it "The Schlick approximation under total internal reflection" do
    shape = Rayz.glass_sphere
    r = Rayz::Ray.new(
      Rayz::Point.new(0.0, 0.0, Math.sqrt(2.0) / 2.0),
      Rayz::Vector.new(0.0, 1.0, 0.0)
    )
    xs = [
      Rayz::Intersection.new(-Math.sqrt(2.0) / 2.0, shape),
      Rayz::Intersection.new(Math.sqrt(2.0) / 2.0, shape),
    ]
    comps = xs[1].prepare_computations(r, xs)
    Rayz.schlick(comps).should be_close(1.0, 0.0001)
  end

  it "The Schlick approximation with a perpendicular viewing angle" do
    shape = Rayz.glass_sphere
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    xs = [Rayz::Intersection.new(-1.0, shape), Rayz::Intersection.new(1.0, shape)]
    comps = xs[1].prepare_computations(r, xs)
    Rayz.schlick(comps).should be_close(0.04, 0.0001)
  end

  it "The Schlick approximation with small angle and n2 > n1" do
    shape = Rayz.glass_sphere
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.99, -2.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = [Rayz::Intersection.new(1.8589, shape)]
    comps = xs[0].prepare_computations(r, xs)
    Rayz.schlick(comps).should be_close(0.48873, 0.0001)
  end
end
