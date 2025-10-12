Given("t ← triangle\\({point}, {point}, {point})") do |p1, p2, p3|
  @t = Rayz::Triangle.new(p1: p1, p2: p2, p3: p3)
end

Then("t.p1 = p1") do
  assert_equal(@t.p1, @p1)
end

Then("t.p2 = p2") do
  assert_equal(@t.p2, @p2)
end

Then("t.p3 = p3") do
  assert_equal(@t.p3, @p3)
end

Then("t.e1 = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@t.e1, expected)
end

Then("t.e2 = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@t.e2, expected)
end

Then("t.normal = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@t.normal, expected)
end

When("xs ← local_intersect\\(t, r)") do
  @xs = @t.local_intersect(@r)
end

When(/^(n[123]) ← local_normal_at\(t, (point\(.+\))\)$/) do |var_name, point_str|
  # Parse the point string
  if point_str =~ /point\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
    point = Rayz::Point.new(x: $1.to_f, y: $2.to_f, z: $3.to_f)
    normal = @t.local_normal_at(point)
    instance_variable_set("@#{var_name}", normal)
  end
end

Then("n1 = t.normal") do
  assert_equal(@n1, @t.normal)
end

Then("n2 = t.normal") do
  assert_equal(@n2, @t.normal)
end

Then("n3 = t.normal") do
  assert_equal(@n3, @t.normal)
end
