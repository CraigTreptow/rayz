require_relative "../../lib/rayz/stripe_pattern"
require_relative "../../lib/rayz/gradient_pattern"
require_relative "../../lib/rayz/ring_pattern"
require_relative "../../lib/rayz/checkers_pattern"
require_relative "../../lib/rayz/test_pattern"

# Pattern creation steps
Given("pattern ← stripe_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::StripePattern.new(instance_variable_get("@#{color1}"), instance_variable_get("@#{color2}"))
end

Given("pattern ← gradient_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::GradientPattern.new(instance_variable_get("@#{color1}"), instance_variable_get("@#{color2}"))
end

Given("pattern ← ring_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::RingPattern.new(instance_variable_get("@#{color1}"), instance_variable_get("@#{color2}"))
end

Given("pattern ← checkers_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::CheckersPattern.new(instance_variable_get("@#{color1}"), instance_variable_get("@#{color2}"))
end

Given("pattern ← test_pattern\\()") do
  @pattern = Rayz::TestPattern.new
end

# Pattern property checks
Then("pattern.a = {word}") do |color|
  assert_equal(instance_variable_get("@#{color}"), @pattern.a)
end

Then("pattern.b = {word}") do |color|
  assert_equal(instance_variable_get("@#{color}"), @pattern.b)
end

# Pattern color evaluation
Then("stripe_at\\(pattern, point\\({float}, {float}, {float})) = {word}") do |x, y, z, color|
  point = Rayz::Point.new(x: x, y: y, z: z)
  result = @pattern.pattern_at(point)
  assert_equal(instance_variable_get("@#{color}"), result)
end

Then("pattern_at\\(pattern, point\\({float}, {float}, {float})) = {word}") do |x, y, z, color|
  point = Rayz::Point.new(x: x, y: y, z: z)
  result = @pattern.pattern_at(point)
  assert_equal(instance_variable_get("@#{color}"), result)
end

Then("pattern_at\\(pattern, point\\({float}, {float}, {float})) = color\\({float}, {float}, {float})") do |x, y, z, r, g, b|
  point = Rayz::Point.new(x: x, y: y, z: z)
  result = @pattern.pattern_at(point)
  expected = Rayz::Color.new(red: r, green: g, blue: b)
  assert_equal(expected, result)
end

# Pattern transformation
Then("pattern.transform = identity_matrix") do
  assert_equal(Matrix.identity(4), @pattern.transform)
end

When("set_pattern_transform\\(pattern, {transform})") do |transform_name|
  @pattern.transform = instance_variable_get("@#{transform_name}")
end

Then("pattern.transform = {word}") do |transform_name|
  assert_equal(instance_variable_get("@#{transform_name}"), @pattern.transform)
end

# Pattern with object transformation
When("c ← stripe_at_object\\(pattern, object, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @c = @pattern.pattern_at_shape(@object, point)
end

When("c ← pattern_at_shape\\(pattern, shape, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @c = @pattern.pattern_at_shape(@shape, point)
end
