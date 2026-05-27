require "../spec_helper"

describe "Material" do
  it "The default material" do
    m = Rayz::Material.new
    m.color.should eq(Rayz::Color.new(1.0, 1.0, 1.0))
    m.ambient.should be_close(0.1, 0.0001)
    m.diffuse.should be_close(0.9, 0.0001)
    m.specular.should be_close(0.9, 0.0001)
    m.shininess.should be_close(200.0, 0.0001)
  end

  it "Reflectivity for the default material" do
    Rayz::Material.new.reflective.should be_close(0.0, 0.0001)
  end

  it "Transparency and Refractive Index for the default material" do
    m = Rayz::Material.new
    m.transparency.should be_close(0.0, 0.0001)
    m.refractive_index.should be_close(1.0, 0.0001)
  end

  it "Lighting with the eye between the light and the surface" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, 0.0, -1.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv)
    result.should eq(Rayz::Color.new(1.9, 1.9, 1.9))
  end

  it "Lighting with the eye between light and surface, eye offset 45 degrees" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, Math.sqrt(2.0) / 2.0, -Math.sqrt(2.0) / 2.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv)
    result.should eq(Rayz::Color.new(1.0, 1.0, 1.0))
  end

  it "Lighting with eye opposite surface, light offset 45 degrees" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, 0.0, -1.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 10.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv)
    result.should eq(Rayz::Color.new(0.7364, 0.7364, 0.7364))
  end

  it "Lighting with eye in the path of the reflection vector" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, -Math.sqrt(2.0) / 2.0, -Math.sqrt(2.0) / 2.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 10.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv)
    result.should eq(Rayz::Color.new(1.6364, 1.6364, 1.6364))
  end

  it "Lighting with the light behind the surface" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, 0.0, -1.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, 10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv)
    result.should eq(Rayz::Color.new(0.1, 0.1, 0.1))
  end

  it "Lighting with the surface in shadow" do
    m = Rayz::Material.new
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    eyev = Rayz::Vector.new(0.0, 0.0, -1.0)
    normalv = Rayz::Vector.new(0.0, 0.0, -1.0)
    light = Rayz::PointLight.new(Rayz::Point.new(0.0, 0.0, -10.0), Rayz::Color.new(1.0, 1.0, 1.0))
    result = Rayz.lighting(m, light, position, eyev, normalv, 0.0)
    result.should eq(Rayz::Color.new(0.1, 0.1, 0.1))
  end
end
