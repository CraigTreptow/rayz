require_relative "../../lib/rayz/test_shape"

Given("s ← test_shape\\()") do
  @s = Rayz::TestShape.new
end

Given("shape ← sphere\\()") do
  @shape = Rayz::Sphere.new
end

Given("shape ← plane\\()") do
  @shape = Rayz::Plane.new
end

Given("shape ← cube\\()") do
  @shape = Rayz::Cube.new
end

Given("shape ← cylinder\\()") do
  @shape = Rayz::Cylinder.new
end

Given(/^shape ← triangle\(p1: point\(([^,]+),\s*([^,]+),\s*([^)]+)\), p2: point\(([^,]+),\s*([^,]+),\s*([^)]+)\), p3: point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |p1x, p1y, p1z, p2x, p2y, p2z, p3x, p3y, p3z|
  p1 = Rayz::Point.new(x: p1x.to_f, y: p1y.to_f, z: p1z.to_f)
  p2 = Rayz::Point.new(x: p2x.to_f, y: p2y.to_f, z: p2z.to_f)
  p3 = Rayz::Point.new(x: p3x.to_f, y: p3y.to_f, z: p3z.to_f)
  @shape = Rayz::Triangle.new(p1: p1, p2: p2, p3: p3)
end

Given("shape ← group\\()") do
  @shape = Rayz::Group.new
end

Given("child ← test_shape\\()") do
  @child = Rayz::TestShape.new
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
  assert_nil(@s.parent)
end

# Group creation with numbered variables
Given(/^(g\d+) ← group\(\)$/) do |var_name|
  instance_variable_set("@#{var_name}", Rayz::Group.new)
end

# Set transform for numbered groups only
When(/^set_transform\((g\d+), rotation_y\(([^)]+)\)\)$/) do |var_name, angle|
  var = instance_variable_get("@#{var_name}")
  # Handle π notation
  # rubocop:disable Security/Eval
  angle_value = if angle.include?("π")
    eval(angle.gsub("π", "Math::PI"))
  else
    angle.to_f
  end
  # rubocop:enable Security/Eval
  var.transform = Rayz::Transformations.rotation_y(radians: angle_value)
end

When(/^set_transform\((g\d+), rotation_z\(([^)]+)\)\)$/) do |var_name, angle|
  var = instance_variable_get("@#{var_name}")
  # Handle π notation
  # rubocop:disable Security/Eval
  angle_value = if angle.include?("π")
    eval(angle.gsub("π", "Math::PI"))
  else
    angle.to_f
  end
  # rubocop:enable Security/Eval
  var.transform = Rayz::Transformations.rotation_z(radians: angle_value)
end

When(/^set_transform\((g\d+), scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |var_name, x, y, z|
  var = instance_variable_get("@#{var_name}")
  var.transform = Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
end

When(/^set_transform\((g\d+), translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |var_name, x, y, z|
  var = instance_variable_get("@#{var_name}")
  var.transform = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
end

# Add child to numbered groups
When(/^add_child\((g\d+), (g\d+|s)\)$/) do |parent_var, child_var|
  parent = instance_variable_get("@#{parent_var}")
  child = instance_variable_get("@#{child_var}")
  parent.add_child(child)
end

# World to object conversion
When(/^(p|n) ← world_to_object\((s|g\d+), point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |result_var, obj_var, x, y, z|
  obj = instance_variable_get("@#{obj_var}")
  point = Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f)
  result = obj.world_to_object(point)
  instance_variable_set("@#{result_var}", result)
end

# Normal to world conversion
When(/^(n|p) ← normal_to_world\((s|g\d+), vector\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |result_var, obj_var, x, y, z|
  obj = instance_variable_get("@#{obj_var}")
  # Handle √ notation - convert √3 to Math.sqrt(3)
  # rubocop:disable Security/Eval
  x_val = eval(x.gsub(/√(\d+)/, 'Math.sqrt(\1)'))
  y_val = eval(y.gsub(/√(\d+)/, 'Math.sqrt(\1)'))
  z_val = eval(z.gsub(/√(\d+)/, 'Math.sqrt(\1)'))
  # rubocop:enable Security/Eval
  vector = Rayz::Vector.new(x: x_val, y: y_val, z: z_val)
  result = obj.normal_to_world(vector)
  instance_variable_set("@#{result_var}", result)
end

# Step for normal_at with mixed √ notation (e.g., point(0, √2/2, -√2/2))
When(/^n ← normal_at\(s, point\((\d+(?:\.\d+)?),\s*(-?√\d+\/\d+),\s*(-?√\d+\/\d+)\)\)$/) do |x, y, z|
  # rubocop:disable Security/Eval
  x_val = x.to_f
  y_val = eval(y.gsub(/(-?)√(\d+)\/(\d+)/, '\1Math.sqrt(\2)/\3'))
  z_val = eval(z.gsub(/(-?)√(\d+)\/(\d+)/, '\1Math.sqrt(\2)/\3'))
  # rubocop:enable Security/Eval
  point = Rayz::Point.new(x: x_val, y: y_val, z: z_val)
  @n = @s.normal_at(point)
end

# Assertion for p = point(...)
Then("{transform} = {point}") do |var_name, point|
  actual = instance_variable_get("@#{var_name}")
  assert_equal(point, actual)
end

# Assertion for s.transform = translation(...)
Then(/^s\.transform = translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)$/) do |x, y, z|
  expected = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
  assert_equal(expected, @s.transform)
end
