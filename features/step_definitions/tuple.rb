Given('a ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a = Tuple.new(x: float, y: float2, z: float3, w: float4)
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
  @p = Point.new(x: float, y: float2, z: float3)
end

Then('p = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @p == Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('v ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v = Vector.new(x: float, y: float2, z: float3)
end

Then('v = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @v == Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('a1 ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a1 = Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Given('a2 ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a2 = Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Then('a1 + a2 = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(@a1 + @a2, expected)
end

Given('p1 ← point\({float}, {float}, {float})') do |float, float2, float3|
  @p1 = Point.new(x: float, y: float2, z: float3)
end

Given('p2 ← point\({float}, {float}, {float})') do |float, float2, float3|
  @p2 = Point.new(x: float, y: float2, z: float3)
end

Then('p1 - p2 = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Vector.new(x: float, y: float2, z: float3)
  assert_equal(@p1 - @p2, expected)
end

Then('p - v = point\({float}, {float}, {float})') do |float, float2, float3|
  expected = Point.new(x: float, y: float2, z: float3)
  assert_equal(@p - @v, expected)
end

Given('v1 ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v1 = Vector.new(x: float, y: float2, z: float3)
end

Given('v2 ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v2 = Vector.new(x: float, y: float2, z: float3)
end

Then('v1 - v2 = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Vector.new(x: float, y: float2, z: float3)
  assert_equal(@v1 - @v2, expected)
end

Given('zero ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @zero = Vector.new(x: float, y: float2, z: float3)
end

Then('zero - v = vector\({float}, {float}, {float})') do |float, float2, float3|
  expected = Vector.new(x: float, y: float2, z: float3)
  assert_equal(@zero - @v, expected)
end

Then('-a = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Tuple.new(x: float, y: float2, z: float3, w: float4)
  assert_equal(@a.negate, expected)
end
