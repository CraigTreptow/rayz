require_relative "../../lib/rayz/transformations"

# Transformation matrix creation steps
Given('transform ← translation\({int}, {int}, {int})') do |x, y, z|
  @transform = Rayz::Transformations.translation(x, y, z)
end

Given('transform ← scaling\({int}, {int}, {int})') do |x, y, z|
  @transform = Rayz::Transformations.scaling(x, y, z)
end

Given('transform ← shearing\({int}, {int}, {int}, {int}, {int}, {int})') do |xy, xz, yx, yz, zx, zy|
  @transform = Rayz::Transformations.shearing(xy, xz, yx, yz, zx, zy)
end

# Rotation transformations with π support
Given('half_quarter ← rotation_x\(π \/ {int})') do |divisor|
  @half_quarter = Rayz::Transformations.rotation_x(Math::PI / divisor)
end

Given('full_quarter ← rotation_x\(π \/ {int})') do |divisor|
  @full_quarter = Rayz::Transformations.rotation_x(Math::PI / divisor)
end

Given('half_quarter ← rotation_y\(π \/ {int})') do |divisor|
  @half_quarter = Rayz::Transformations.rotation_y(Math::PI / divisor)
end

Given('full_quarter ← rotation_y\(π \/ {int})') do |divisor|
  @full_quarter = Rayz::Transformations.rotation_y(Math::PI / divisor)
end

Given('half_quarter ← rotation_z\(π \/ {int})') do |divisor|
  @half_quarter = Rayz::Transformations.rotation_z(Math::PI / divisor)
end

Given('full_quarter ← rotation_z\(π \/ {int})') do |divisor|
  @full_quarter = Rayz::Transformations.rotation_z(Math::PI / divisor)
end

# Named transformation matrices for chaining
Given('A ← rotation_x\(π \/ {int})') do |divisor|
  @matrix_a = Rayz::Transformations.rotation_x(Math::PI / divisor)
end

Given('B ← scaling\({int}, {int}, {int})') do |x, y, z|
  @matrix_b = Rayz::Transformations.scaling(x, y, z)
end

Given('C ← translation\({int}, {int}, {int})') do |x, y, z|
  @matrix_c = Rayz::Transformations.translation(x, y, z)
end

# Inverse calculation
Given('inv ← inverse\(transform)') do
  @inv = @transform.inverse
end

Given('inv ← inverse\(half_quarter)') do
  @inv = @half_quarter.inverse
end

# Matrix-tuple multiplication assertions with transform
Then('transform * p = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@transform, @point_p)
  assert_equal(result, expected)
end

Then("transform * v = v") do
  result = Rayz::Util.matrix_multiplied_by_tuple(@transform, @vector_v)
  assert_equal(result, @vector_v)
end

Then('inv * p = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@inv, @point_p)
  assert_equal(result, expected)
end

Then('inv * v = vector\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@inv, @vector_v)
  assert_equal(result, expected)
end

Then('transform * v = vector\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@transform, @vector_v)
  assert_equal(result, expected)
end

# Matrix-tuple multiplication with named matrices (half_quarter, full_quarter)
# Support for √2/2 notation
Then('half_quarter * p = point\({int}, √{int}\/{int}, √{int}\/{int})') do |x, sqrt1, div1, sqrt2, div2|
  expected = Rayz::Point.new(x: x, y: Math.sqrt(sqrt1) / div1, z: Math.sqrt(sqrt2) / div2)
  result = Rayz::Util.matrix_multiplied_by_tuple(@half_quarter, @point_p)
  assert_equal(result, expected)
end

Then('half_quarter * p = point\(√{int}\/{int}, {int}, √{int}\/{int})') do |sqrt1, div1, y, sqrt2, div2|
  expected = Rayz::Point.new(x: Math.sqrt(sqrt1) / div1, y: y, z: Math.sqrt(sqrt2) / div2)
  result = Rayz::Util.matrix_multiplied_by_tuple(@half_quarter, @point_p)
  assert_equal(result, expected)
end

Then('half_quarter * p = point\(-√{int}\/{int}, √{int}\/{int}, {int})') do |sqrt1, div1, sqrt2, div2, z|
  expected = Rayz::Point.new(x: -Math.sqrt(sqrt1) / div1, y: Math.sqrt(sqrt2) / div2, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@half_quarter, @point_p)
  assert_equal(result, expected)
end

Then('inv * p = point\({int}, √{int}\/{int}, -√{int}\/{int})') do |x, sqrt1, div1, sqrt2, div2|
  expected = Rayz::Point.new(x: x, y: Math.sqrt(sqrt1) / div1, z: -Math.sqrt(sqrt2) / div2)
  result = Rayz::Util.matrix_multiplied_by_tuple(@inv, @point_p)
  assert_equal(result, expected)
end

# Regular point assertions for half_quarter and full_quarter
Then('half_quarter * p = point\({float}, {float}, {float})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@half_quarter, @point_p)
  assert_equal(result, expected)
end

Then('full_quarter * p = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@full_quarter, @point_p)
  assert_equal(result, expected)
end

# Sequential transformation steps
When("p2 ← A * p") do
  @point_p2 = Rayz::Util.matrix_multiplied_by_tuple(@matrix_a, @point_p)
end

Then('p2 = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  assert_equal(@point_p2, expected)
end

When("p3 ← B * p2") do
  @point_p3 = Rayz::Util.matrix_multiplied_by_tuple(@matrix_b, @point_p2)
end

Then('p3 = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  assert_equal(@point_p3, expected)
end

When("p4 ← C * p3") do
  @point_p4 = Rayz::Util.matrix_multiplied_by_tuple(@matrix_c, @point_p3)
end

Then('p4 = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  assert_equal(@point_p4, expected)
end

# Chained transformations
When("T ← C * B * A") do
  @matrix_t = @matrix_c * @matrix_b * @matrix_a
end

Then('T * p = point\({int}, {int}, {int})') do |x, y, z|
  expected = Rayz::Point.new(x: x, y: y, z: z)
  result = Rayz::Util.matrix_multiplied_by_tuple(@matrix_t, @point_p)
  assert_equal(result, expected)
end
