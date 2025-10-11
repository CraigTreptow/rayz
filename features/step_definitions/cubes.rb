Given("c ← cube\\()") do
  @c = Rayz::Cube.new
end

When("xs ← local_intersect\\(c, r)") do
  @xs = @c.local_intersect(@r)
end

When("normal ← local_normal_at\\(c, p)") do
  @normal = @c.local_normal_at(@p)
end

Then("normal = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@normal, expected)
end
