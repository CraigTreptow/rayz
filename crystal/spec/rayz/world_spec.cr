require "../spec_helper"

describe "World" do
  it "Creating a world" do
    w = Rayz::World.new
    w.objects.size.should eq(0)
    w.light.should be_nil
  end

  it "The default world" do
    light = Rayz::PointLight.new(Rayz::Point.new(-10.0, 10.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    s1 = Rayz::Sphere.new
    s1.material.color = Rayz::Color.new(0.8, 1.0, 0.6)
    s1.material.diffuse = 0.7
    s1.material.specular = 0.2
    s2 = Rayz::Sphere.new
    s2.transform = Rayz::Transformations.scaling(0.5, 0.5, 0.5)

    w = Rayz::World.default_world
    w.light.should eq(light)
    w.objects.size.should eq(2)
    w.objects[0].material.should eq(s1.material)
    w.objects[1].transform.should eq(s2.transform)
  end

  it "Intersect a world with a ray" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    xs = w.intersect(r)
    xs.size.should eq(4)
    xs[0].t.should be_close(4.0, 0.0001)
    xs[1].t.should be_close(4.5, 0.0001)
    xs[2].t.should be_close(5.5, 0.0001)
    xs[3].t.should be_close(6.0, 0.0001)
  end

  it "Shading an intersection" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    shape = w.objects[0]
    i = Rayz::Intersection.new(4.0, shape)
    comps = i.prepare_computations(r)
    c = w.shade_hit(comps)
    c.should eq(Rayz::Color.new(0.38066, 0.47583, 0.2855))
  end

  it "Shading an intersection from the inside" do
    w = Rayz::World.default_world
    w.light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.25, 0.0), Rayz::Color.new(1.0, 1.0, 1.0))
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    shape = w.objects[1]
    i = Rayz::Intersection.new(0.5, shape)
    comps = i.prepare_computations(r)
    c = w.shade_hit(comps)
    c.should eq(Rayz::Color.new(0.90498, 0.90498, 0.90498))
  end

  it "The color when a ray misses" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 1.0, 0.0))
    c = w.color_at(r)
    c.should eq(Rayz::Color.new(0.0, 0.0, 0.0))
  end

  it "The color when a ray hits" do
    w = Rayz::World.default_world
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, -5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    c = w.color_at(r)
    c.should eq(Rayz::Color.new(0.38066, 0.47583, 0.2855))
  end

  it "The color with an intersection behind the ray" do
    w = Rayz::World.default_world
    outer = w.objects[0]
    outer.material.ambient = 1.0
    inner = w.objects[1]
    inner.material.ambient = 1.0
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 0.75), Rayz::Vector.new(0.0, 0.0, -1.0))
    c = w.color_at(r)
    c.should eq(inner.material.color)
  end

  it "There is no shadow when nothing is collinear with point and light" do
    w = Rayz::World.default_world
    p = Rayz::Point.new(0.0, 10.0, 0.0)
    w.is_shadowed?(p).should be_false
  end

  it "The shadow when an object is between the point and the light" do
    w = Rayz::World.default_world
    p = Rayz::Point.new(10.0, -10.0, 10.0)
    w.is_shadowed?(p).should be_true
  end

  it "There is no shadow when an object is behind the light" do
    w = Rayz::World.default_world
    p = Rayz::Point.new(-20.0, 20.0, -20.0)
    w.is_shadowed?(p).should be_false
  end

  it "There is no shadow when an object is behind the point" do
    w = Rayz::World.default_world
    p = Rayz::Point.new(-2.0, 2.0, -2.0)
    w.is_shadowed?(p).should be_false
  end

  it "shade_hit() is given an intersection in shadow" do
    w = Rayz::World.new
    w.light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    s1 = Rayz::Sphere.new
    w.objects << s1
    s2 = Rayz::Sphere.new
    s2.transform = Rayz::Transformations.translation(0.0, 0.0, 10.0)
    w.objects << s2
    r = Rayz::Ray.new(Rayz::Point.new(0.0, 0.0, 5.0), Rayz::Vector.new(0.0, 0.0, 1.0))
    i = Rayz::Intersection.new(4.0, s2)
    comps = i.prepare_computations(r)
    c = w.shade_hit(comps)
    c.should eq(Rayz::Color.new(0.1, 0.1, 0.1))
  end
end
