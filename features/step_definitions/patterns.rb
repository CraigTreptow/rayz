require_relative "../../lib/rayz/stripe_pattern"
require_relative "../../lib/rayz/gradient_pattern"
require_relative "../../lib/rayz/ring_pattern"
require_relative "../../lib/rayz/checkers_pattern"
require_relative "../../lib/rayz/test_pattern"

# Object creation for patterns
Given("object ← sphere\\()") do
  @object = Rayz::Sphere.new
end

# Transform setting for object
When(/^set_transform\(object, (scaling|translation)\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |transform_type, x, y, z|
  if transform_type == "scaling"
    @object.transform = Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
  elsif transform_type == "translation"
    @object.transform = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
  end
end

# Transform setting for shape
When(/^set_transform\(shape, (scaling|translation)\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |transform_type, x, y, z|
  if transform_type == "scaling"
    @shape.transform = Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
  elsif transform_type == "translation"
    @shape.transform = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
  end
end

# Generic color assertion (c = white, c = black, etc.) - only matches simple variable names without dots
Then(/^c = ([a-z_]+)$/) do |color_name|
  expected = instance_variable_get("@#{color_name}")
  assert_equal(expected, @c)
end

# Pattern creation steps
Given("pattern ← stripe_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::StripePattern.new(a: instance_variable_get("@#{color1}"), b: instance_variable_get("@#{color2}"))
end

Given("pattern ← gradient_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::GradientPattern.new(a: instance_variable_get("@#{color1}"), b: instance_variable_get("@#{color2}"))
end

Given("pattern ← ring_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::RingPattern.new(a: instance_variable_get("@#{color1}"), b: instance_variable_get("@#{color2}"))
end

Given("pattern ← checkers_pattern\\({word}, {word})") do |color1, color2|
  @pattern = Rayz::CheckersPattern.new(a: instance_variable_get("@#{color1}"), b: instance_variable_get("@#{color2}"))
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
Then(/^stripe_at\(pattern, point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\) = (\w+)$/) do |x, y, z, color|
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  result = @pattern.pattern_at(point)
  assert_equal(instance_variable_get("@#{color}"), result)
end

Then(/^pattern_at\(pattern, point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\) = (\w+)$/) do |x, y, z, color|
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  result = @pattern.pattern_at(point)
  assert_equal(instance_variable_get("@#{color}"), result)
end

Then(/^pattern_at\(pattern, point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\) = color\(([^,]+),\s*([^,]+),\s*([^)]+)\)$/) do |x, y, z, r, g, b|
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  result = @pattern.pattern_at(point)
  expected = Rayz::Color.new(red: r.to_f, green: g.to_f, blue: b.to_f)
  assert_equal(expected, result)
end

# Pattern transformation
When("set_pattern_transform\\(pattern, {transform})") do |transform_name|
  @pattern.transform = instance_variable_get("@#{transform_name}")
end

When(/^set_pattern_transform\(pattern, (scaling|translation)\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |transform_type, x, y, z|
  if transform_type == "scaling"
    @pattern.transform = Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
  elsif transform_type == "translation"
    @pattern.transform = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
  end
end

Then("pattern.transform = {word}") do |transform_name|
  if transform_name == "identity_matrix"
    assert_equal(Matrix.identity(4), @pattern.transform)
  else
    assert_equal(instance_variable_get("@#{transform_name}"), @pattern.transform)
  end
end

Then(/^pattern\.transform = (translation|scaling)\(([^,]+),\s*([^,]+),\s*([^)]+)\)$/) do |transform_type, x, y, z|
  expected = if transform_type == "translation"
    Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
  else
    Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
  end
  assert_equal(expected, @pattern.transform)
end

# Pattern with object transformation
When(/^c ← stripe_at_object\(pattern, object, point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |x, y, z|
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  @c = @pattern.pattern_at_shape(@object, point)
end

When(/^c ← pattern_at_shape\(pattern, shape, point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |x, y, z|
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  @c = @pattern.pattern_at_shape(@shape, point)
end
