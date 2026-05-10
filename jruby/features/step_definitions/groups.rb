Given("g ← group\\()") do
  @g = Rayz::Group.new
end

Then("g is empty") do
  assert(@g.empty?)
end

Then("g is not empty") do
  refute(@g.empty?)
end

Then("g includes s") do
  assert(@g.include?(@s))
end

Then("s.parent = g") do
  assert_equal(@g, @s.parent)
end

Then(/^xs\[(\d+)\]\.object = s(\d+)$/) do |index, shape_num|
  shape_var = instance_variable_get("@s#{shape_num}")
  assert_equal(shape_var, @xs[index.to_i].object)
end

When("xs ← intersect\\(g, r)") do
  @xs = @g.intersect(@r)
end

When(/^set_transform\((s\d+|g), translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |var_name, x, y, z|
  var = instance_variable_get("@#{var_name}")
  var.transform = Rayz::Transformations.translation(x: x.to_f, y: y.to_f, z: z.to_f)
end

When(/^set_transform\((s\d+|g), scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |var_name, x, y, z|
  var = instance_variable_get("@#{var_name}")
  var.transform = Rayz::Transformations.scaling(x: x.to_f, y: y.to_f, z: z.to_f)
end

When(/^add_child\(g, (s\d*|s)\)$/) do |var_name|
  shape = instance_variable_get("@#{var_name}")
  @g.add_child(shape)
end

Given(/^(s[2-9]\d*) ← sphere\(\)$/) do |var_name|
  instance_variable_set("@#{var_name}", Rayz::Sphere.new)
end

Then("g.transform = identity_matrix") do
  assert_equal(Matrix.identity(4), @g.transform)
end

When("xs ← local_intersect\\(g, r)") do
  @xs = @g.local_intersect(@r)
end
