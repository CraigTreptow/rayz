Given("shape ← cone\\()") do
  @shape = Rayz::Cone.new
end

Given("shape.minimum ← {float}") do |value|
  @shape.minimum = value
end

Given("shape.maximum ← {float}") do |value|
  @shape.maximum = value
end

Given("shape.closed ← true") do
  @shape.closed = true
end

When("xs ← local_intersect\\(shape, r)") do
  @xs = @shape.local_intersect(@r)
end

When("n ← local_normal_at\\(shape, {point})") do |point|
  @n = @shape.local_normal_at(point)
end

# Handle vector comparisons with -√ notation (negative square root)
# This specifically matches patterns like vector(1, -√2, 1) where only one component has -√
Then(/^n = vector\(([^,]+), (-√\d+), ([^)]+)\)$/) do |x_str, y_str, z_str|
  x = parse_math_expression(x_str.strip)
  y = parse_math_expression(y_str.strip)
  z = parse_math_expression(z_str.strip)

  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@n, expected)
end

# Helper method to parse mathematical expressions
def parse_math_expression(expr)
  # Handle -√n notation
  if expr =~ /^-√(\d+(?:\.\d+)?)$/
    -Math.sqrt($1.to_f)
  # Handle √n notation
  elsif expr =~ /^√(\d+(?:\.\d+)?)$/
    Math.sqrt($1.to_f)
  # Handle √n/m notation
  elsif expr =~ /^√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)$/
    Math.sqrt($1.to_f) / $2.to_f
  # Handle -√n/m notation
  elsif expr =~ /^-√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)$/
    -Math.sqrt($1.to_f) / $2.to_f
  # Regular number
  else
    expr.to_f
  end
end
