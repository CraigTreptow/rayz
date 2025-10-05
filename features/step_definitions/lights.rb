# Step definitions for point light operations

Given("intensity ← color\\({float}, {float}, {float})") do |r, g, b|
  @intensity = Rayz::Color.new(red: r, green: g, blue: b)
end

Given("position ← point\\({float}, {float}, {float})") do |x, y, z|
  @position = Rayz::Point.new(x: x, y: y, z: z)
end

When("light ← point_light\\(position, intensity)") do
  @light = Rayz::PointLight.new(@position, @intensity)
end

Then("light.position = position") do
  assert_equal(@light.position, @position)
end

Then("light.intensity = intensity") do
  assert_equal(@light.intensity, @intensity)
end
