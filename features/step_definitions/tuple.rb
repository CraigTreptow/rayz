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
