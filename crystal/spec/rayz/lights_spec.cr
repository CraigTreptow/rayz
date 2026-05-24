require "../spec_helper"

describe "PointLight" do
  it "A point light has a position and intensity" do
    intensity = Rayz::Color.new(1.0, 1.0, 1.0)
    position = Rayz::Point.new(0.0, 0.0, 0.0)
    light = Rayz::PointLight.new(position, intensity)
    light.position.should eq(position)
    light.intensity.should eq(intensity)
  end
end
