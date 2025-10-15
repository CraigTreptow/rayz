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
