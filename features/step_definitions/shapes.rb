require_relative "../../lib/rayz/test_shape"

Given("s ← test_shape\\()") do
  @s = Rayz::TestShape.new
end

Given("shape ← sphere\\()") do
  @shape = Rayz::Sphere.new
end


Then("s.saved_ray.origin = point\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  assert_equal(expected, @s.saved_ray.origin)
end

Then("s.saved_ray.direction = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(expected, @s.saved_ray.direction)
end

Then("s.parent is nothing") do
  # Parent functionality not implemented yet - will be for groups
  parent = @s.instance_variable_get(:@parent) if @s.instance_variable_defined?(:@parent)
  assert_nil(parent)
end
