Given('a ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Then("a.x = {float}") do |float|
  assert_equal(@a.x, float)
end

Then("a.y = {float}") do |float|
  assert_equal(@a.y, float)
end

Then("a.z = {float}") do |float|
  assert_equal(@a.z, float)
end

Then("a.w = {float}") do |float|
  assert_equal(@a.w, float)
end

Then("a is a point") do
  assert_equal(@a.point?, true)
end

Then("a is not a vector") do
  assert_equal(@a.vector?, false)
end

Then("a is not a point") do
  assert_equal(@a.point?, false)
end

Then("a is a vector") do
  assert_equal(@a.vector?, true)
end

Given('p ← point\({float}, {float}, {float})') do |float, float2, float3|
  @p = Rayz::Lib::Point.new(x: float, y: float2, z: float3)
end

Then('p = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @p == Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('v ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
end

Then('v = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @v == Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('a1 ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a1 = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('a2 ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a2 = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Then('a1 + a2 = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(@a1 + @a2, expected)
end

Given('p1 ← point\({float}, {float}, {float})') do |float, float2, float3|
  @p1 = Rayz::Lib::Point.new(x: float, y: float2, z: float3)
end

Given('p2 ← point\({float}, {float}, {float})') do |float, float2, float3|
  @p2 = Rayz::Lib::Point.new(x: float, y: float2, z: float3)
end

Then('p1 - p2 = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
  assert_equal(@p1 - @p2, expected)
end

Then('p - v = point\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Lib::Point.new(x: float, y: float2, z: float3)
  assert_equal(@p - @v, expected)
end

Given('v1 ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v1 = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
end

Given('v2 ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v2 = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
end

Then('v1 - v2 = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
  assert_equal(@v1 - @v2, expected)
end

Given('zero ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @zero = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
end

Then('zero - v = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Lib::Vector.new(x: float, y: float2, z: float3)
  assert_equal(@zero - @v, expected)
end

Then('-a = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Rayz::Lib::Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(@a.negate, expected)
end

Then('a * {float} = tuple\({float}, {float}, {float}, {float})') do |float, float1, float2, float3, float4|
  expected = Rayz::Lib::Tuple.new(x: float1, y: float2, z: float3, w: float4)
  assert_equal(@a * float, expected)
end

Then('a \/ {float} = tuple\({float}, {float}, {float}, {float})') do |float, float1, float2, float3, float4|
  expected = Rayz::Lib::Tuple.new(x: float1, y: float2, z: float3, w: float4)
  assert_equal(@a / float, expected)
end

Then('magnitude\(v) = {float}') do |float|
  mag = @v.magnitude
  assert_equal(mag, float)
end

Then('magnitude\(v) = √{float}') do |float|
  expected = Math.sqrt(float)
  mag = @v.magnitude
  assert_equal(mag, expected)
end

Then('normalize\(v) = vector\({float}, {float}, {float})') do |float, float1, float2|
  expected = Rayz::Lib::Vector.new(x: float, y: float1, z: float2)
  assert_equal(@v.normalize, expected)
end

Then('normalize\(v) = approximately vector\({float}, {float}, {float})') do |float, float1, float2|
  # vector(1/√14,   2/√14,   3/√14)
  # vector(0.26726, 0.53452, 0.80178)
  expected = Rayz::Lib::Vector.new(x: float, y: float1, z: float2)
  assert_equal(@v.normalize, expected)
end

When('norm ← normalize\(v)') do
  @norm = @v.normalize
end

Then('magnitude\(norm) = {float}') do |float|
  assert_equal(@norm.magnitude, float)
end

Then('dot\(v1, v2) = {float}') do |float|
  assert_equal(@v1.dot(@v2), float)
end

Then('cross\(v1, v2) = vector\({float}, {float}, {float})') do |float, float1, float2|
  expected = Rayz::Lib::Vector.new(x: float, y: float1, z: float2)
  assert_equal(@v1.cross(@v2), expected)
end
