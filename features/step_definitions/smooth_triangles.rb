# Step definition for p3 (p1 and p2 are defined in tuple.rb)
Given("p3 ← point\\({float}, {float}, {float})") do |x, y, z|
  @p3 = Rayz::Point.new(x: x, y: y, z: z)
end

# Step definitions for n1, n2, n3 (normal vectors for smooth triangles)
Given("n1 ← vector\\({float}, {float}, {float})") do |x, y, z|
  @n1 = Rayz::Vector.new(x: x, y: y, z: z)
end

Given("n2 ← vector\\({float}, {float}, {float})") do |x, y, z|
  @n2 = Rayz::Vector.new(x: x, y: y, z: z)
end

Given("n3 ← vector\\({float}, {float}, {float})") do |x, y, z|
  @n3 = Rayz::Vector.new(x: x, y: y, z: z)
end

When("tri ← smooth_triangle\\(p1, p2, p3, n1, n2, n3)") do
  # Use @point_p1 and @point_p2 from tuple.rb, @p3 from above
  @tri = Rayz::SmoothTriangle.new(p1: @point_p1, p2: @point_p2, p3: @p3, n1: @n1, n2: @n2, n3: @n3)
  # Also save them with simple names for later comparison
  @p1 = @point_p1
  @p2 = @point_p2
end

Then("tri.p1 = p1") do
  assert_equal(@tri.p1, @p1)
end

Then("tri.p2 = p2") do
  assert_equal(@tri.p2, @p2)
end

Then("tri.p3 = p3") do
  assert_equal(@tri.p3, @p3)
end

Then("tri.n1 = n1") do
  assert_equal(@tri.n1, @n1)
end

Then("tri.n2 = n2") do
  assert_equal(@tri.n2, @n2)
end

Then("tri.n3 = n3") do
  assert_equal(@tri.n3, @n3)
end

Then("xs[{int}].u = {float}") do |index, value|
  assert_in_delta(@xs[index].u, value, Rayz::Util::EPSILON)
end

Then("xs[{int}].v = {float}") do |index, value|
  assert_in_delta(@xs[index].v, value, Rayz::Util::EPSILON)
end

When("i ← intersection_with_uv\\({float}, tri, {float}, {float})") do |t, u, v|
  @i = Rayz::Intersection.new(t: t, object: @tri, u: u, v: v)
end

When("xs ← local_intersect\\(tri, r)") do
  @xs = @tri.local_intersect(@r)
end

When("n ← normal_at\\(tri, point\\({float}, {float}, {float}), i)") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @n = @tri.normal_at(point, @i)
end

Then(/^comps\.normalv = vector\(([^,]+),\s*([^,]+),\s*([^)]+)\)$/) do |x, y, z|
  expected = Rayz::Vector.new(x: x.to_f, y: y.to_f, z: z.to_f)
  assert_equal(@comps.normalv, expected)
end
