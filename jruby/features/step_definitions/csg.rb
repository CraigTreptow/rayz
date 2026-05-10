When(/^c ← csg\("([^"]+)", ([^,]+), ([^)]+)\)$/) do |operation, left, right|
  left_shape = instance_variable_get("@#{left}")
  right_shape = instance_variable_get("@#{right}")
  @c = Rayz.csg(operation, left_shape, right_shape)
end

Then("c.operation = {string}") do |operation|
  assert_equal(operation, @c.operation)
end

Then("c.left = s1") do
  assert_equal(@s1, @c.left)
end

Then("c.right = s2") do
  assert_equal(@s2, @c.right)
end

Then("s1.parent = c") do
  assert_equal(@c, @s1.parent)
end

Then("s2.parent = c") do
  assert_equal(@c, @s2.parent)
end

When(/^result ← intersection_allowed\("([^"]+)", (true|false), (true|false), (true|false)\)$/) do |op, lhit, inl, inr|
  @result = Rayz.intersection_allowed(
    op,
    lhit == "true",
    inl == "true",
    inr == "true"
  )
end

Then(/^result = (true|false)$/) do |expected|
  assert_equal(expected == "true", @result)
end

When("result ← filter_intersections\\(c, xs)") do
  @result = Rayz.filter_intersections(@c, @xs)
end

Then("result.count = {int}") do |count|
  assert_equal(count, @result.length)
end

Then(/^result\[(\d+)\] = xs\[(\d+)\]$/) do |result_index, xs_index|
  assert_equal(@xs[xs_index.to_i], @result[result_index.to_i])
end

Given("s2 ← cube\\()") do
  @s2 = Rayz::Cube.new
end

When(/^c ← csg\("([^"]+)", (sphere|cube|plane)\(\), (sphere|cube|plane)\(\)\)$/) do |operation, left_type, right_type|
  left_shape = case left_type
  when "sphere"
    Rayz::Sphere.new
  when "cube"
    Rayz::Cube.new
  when "plane"
    Rayz::Plane.new
  end

  right_shape = case right_type
  when "sphere"
    Rayz::Sphere.new
  when "cube"
    Rayz::Cube.new
  when "plane"
    Rayz::Plane.new
  end

  @c = Rayz.csg(operation, left_shape, right_shape)
end
