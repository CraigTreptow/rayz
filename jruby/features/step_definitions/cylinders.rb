Given("cyl ← cylinder\\()") do
  @cyl = Rayz::Cylinder.new
end

Given("c ← cylinder\\()") do
  @c = Rayz::Cylinder.new
end

Given("direction ← normalize\\({vector})") do |direction|
  @direction = direction.normalize
end

Given("r ← ray\\({point}, direction)") do |origin|
  @r = Rayz::Ray.new(origin: origin, direction: @direction)
end

Given("cyl.minimum ← {float}") do |value|
  @cyl.minimum = value
end

Given("cyl.maximum ← {float}") do |value|
  @cyl.maximum = value
end

Given("c.minimum ← {float}") do |value|
  @c.minimum = value
end

Given("c.maximum ← {float}") do |value|
  @c.maximum = value
end

Given("cyl.closed ← true") do
  @cyl.closed = true
end

When("xs ← local_intersect\\(cyl, r)") do
  @xs = @cyl.local_intersect(@r)
end

When("n ← local_normal_at\\(cyl, {point})") do |point|
  @n = @cyl.local_normal_at(point)
end

Then("cyl.minimum = -infinity") do
  assert_equal(-Float::INFINITY, @cyl.minimum)
end

Then("cyl.maximum = infinity") do
  assert_equal(Float::INFINITY, @cyl.maximum)
end

Then("cyl.closed = false") do
  assert_equal(false, @cyl.closed)
end

Then(/^xs\[(\d+)\]\.t = (\d+\.\d+)$/) do |index, value|
  actual = @xs[index.to_i].t
  expected = value.to_f
  assert((actual - expected).abs < Rayz::Util::EPSILON, "Expected #{expected} but got #{actual}")
end
