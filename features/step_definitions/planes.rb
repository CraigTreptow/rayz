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
