# Helper methods for tuple step definitions
module TupleStepHelpers
  # Creates a tuple from four float values
  def create_tuple(x, y, z, w)
    Rayz::Tuple.new(x: x, y: y, z: z, w: w)
  end

  # Creates a point from three float values (w=1.0)
  def create_point(x, y, z)
    Rayz::Point.new(x: x, y: y, z: z)
  end

  # Creates a vector from three float values (w=0.0)
  def create_vector(x, y, z)
    Rayz::Vector.new(x: x, y: y, z: z)
  end
end

World(TupleStepHelpers)

# Primary tuple creation for basic tuple operations
Given('a ← tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  @tuple_a = create_tuple(x, y, z, w)
end

# Secondary tuple creation for matrix-tuple operations
Given('b ← tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  @tuple_b = create_tuple(x, y, z, w)
end

# Tuple component access verification
Then("a.x = {float}") do |expected_x|
  assert_equal(@tuple_a.x, expected_x)
end

Then("a.y = {float}") do |expected_y|
  assert_equal(@tuple_a.y, expected_y)
end

Then("a.z = {float}") do |expected_z|
  assert_equal(@tuple_a.z, expected_z)
end

Then("a.w = {float}") do |expected_w|
  assert_equal(@tuple_a.w, expected_w)
end

# Tuple type verification (point has w=1.0)
Then("a is a point") do
  assert_equal(@tuple_a.point?, true)
end

Then("a is not a vector") do
  assert_equal(@tuple_a.vector?, false)
end

Then("a is not a point") do
  assert_equal(@tuple_a.point?, false)
end

# Tuple type verification (vector has w=0.0)
Then("a is a vector") do
  assert_equal(@tuple_a.vector?, true)
end

# Point creation from three coordinates
Given('p ← point\({float}, {float}, {float})') do |x, y, z|
  @point_p = create_point(x, y, z)
  @p = @point_p  # Alias for world tests
end

# Verify point equals tuple with w=1.0
Then('p = tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@point_p, expected)
end

# Vector creation from three coordinates
Given('v ← vector\({float}, {float}, {float})') do |x, y, z|
  @vector_v = create_vector(x, y, z)
end

# Verify vector equals tuple with w=0.0
Then('v = tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@vector_v, expected)
end

# First tuple for arithmetic operations
Given('a1 ← tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  @tuple_a1 = create_tuple(x, y, z, w)
end

# Second tuple for arithmetic operations
Given('a2 ← tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  @tuple_a2 = create_tuple(x, y, z, w)
end

# Tuple addition verification
Then('a1 + a2 = tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@tuple_a1 + @tuple_a2, expected)
end

# First point for point arithmetic operations
Given('p1 ← point\({float}, {float}, {float})') do |x, y, z|
  @point_p1 = create_point(x, y, z)
end

# Second point for point arithmetic operations
Given('p2 ← point\({float}, {float}, {float})') do |x, y, z|
  @point_p2 = create_point(x, y, z)
end

# Point subtraction results in vector
Then('p1 - p2 = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@point_p1 - @point_p2, expected)
end

# Point minus vector results in point
Then('p - v = point\({float}, {float}, {float})') do |x, y, z|
  expected = create_point(x, y, z)
  assert_equal(@point_p - @vector_v, expected)
end

# First vector for vector arithmetic operations
Given('v1 ← vector\({float}, {float}, {float})') do |x, y, z|
  @vector_v1 = create_vector(x, y, z)
end

# Second vector for vector arithmetic operations
Given('v2 ← vector\({float}, {float}, {float})') do |x, y, z|
  @vector_v2 = create_vector(x, y, z)
end

# Vector subtraction results in vector
Then('v1 - v2 = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_v1 - @vector_v2, expected)
end

# Zero vector for negation operations
Given('zero ← vector\({float}, {float}, {float})') do |x, y, z|
  @vector_zero = create_vector(x, y, z)
end

# Zero vector minus vector (vector negation)
Then('zero - v = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_zero - @vector_v, expected)
end

# Tuple negation verification
Then('-a = tuple\({float}, {float}, {float}, {float})') do |x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@tuple_a.negate, expected)
end

# Tuple scalar multiplication verification
Then('a * {float} = tuple\({float}, {float}, {float}, {float})') do |scalar, x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@tuple_a * scalar, expected)
end

# Tuple scalar division verification
Then('a \/ {float} = tuple\({float}, {float}, {float}, {float})') do |divisor, x, y, z, w|
  expected = create_tuple(x, y, z, w)
  assert_equal(@tuple_a / divisor, expected)
end

# Vector magnitude calculation verification
Then('magnitude\(v) = {float}') do |expected_magnitude|
  assert_equal(@vector_v.magnitude, expected_magnitude)
end

# Vector magnitude with square root calculation
Then('magnitude\(v) = √{float}') do |value_under_sqrt|
  expected = Math.sqrt(value_under_sqrt)
  assert_equal(@vector_v.magnitude, expected)
end

# Vector normalization verification
Then('normalize\(v) = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_v.normalize, expected)
end

# Vector normalization with floating-point approximation
# Example: vector(1/√14, 2/√14, 3/√14) ≈ vector(0.26726, 0.53452, 0.80178)
Then('normalize\(v) = approximately vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_v.normalize, expected)
end

# Store normalized vector for magnitude verification
When('norm ← normalize\(v)') do
  @vector_norm = @vector_v.normalize
end

# Verify normalized vector has magnitude of 1
Then('magnitude\(norm) = {float}') do |expected_magnitude|
  assert_equal(@vector_norm.magnitude, expected_magnitude)
end

# Vector dot product calculation
Then('dot\(v1, v2) = {float}') do |expected_dot_product|
  assert_equal(@vector_v1.dot(@vector_v2), expected_dot_product)
end

# Vector cross product calculation
Then('cross\(v1, v2) = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_v1.cross(@vector_v2), expected)
end

Then('cross\(v2, v1) = vector\({float}, {float}, {float})') do |x, y, z|
  expected = create_vector(x, y, z)
  assert_equal(@vector_v2.cross(@vector_v1), expected)
end
