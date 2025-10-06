require_relative "../../lib/rayz/plane"

Given("p ← plane\\()") do
  @p = Rayz::Plane.new
end

When("n1 ← local_normal_at\\(p, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @n1 = @p.local_normal_at(point)
end

When("n2 ← local_normal_at\\(p, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @n2 = @p.local_normal_at(point)
end

When("n3 ← local_normal_at\\(p, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @n3 = @p.local_normal_at(point)
end

When("xs ← local_intersect\\(p, r)") do
  @xs = @p.local_intersect(@r)
end

Then("xs is empty") do
  assert_empty(@xs)
end

Then("xs[{int}].object = p") do |index|
  assert_equal(@xs[index].object, @p)
end

Then("n1 = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@n1, expected)
end

Then("n2 = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@n2, expected)
end

Then("n3 = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@n3, expected)
end
