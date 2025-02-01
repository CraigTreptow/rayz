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
# Given('p ← point\({int}, {int}, {float})') do |int, int2, float|
# Given('p ← point\({int}, {float}, {int})') do |int, float, int2|
# Given('p ← point\({int}, {float}, {float})') do |int, float, float2|
# Given('p ← point\({float}, {int}, {int})') do |float, int, int2|
# Given('p ← point\({float}, {int}, {float})') do |float, int, float2|
# Given('p ← point\({float}, {float}, {int})') do |float, float2, int|
# Given('p ← point\({float}, {float}, {float})') do |float, float2, float3|
end

Then('p = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @p == Tuple.new(x: float, y: float2, z: float3, w: float4)
# Then('p = tuple\({int}, {int}, {int}, {float})') do |int, int2, int3, float|
# Then('p = tuple\({int}, {int}, {float}, {int})') do |int, int2, float, int3|
# Then('p = tuple\({int}, {int}, {float}, {float})') do |int, int2, float, float2|
# Then('p = tuple\({int}, {float}, {int}, {int})') do |int, float, int2, int3|
# Then('p = tuple\({int}, {float}, {int}, {float})') do |int, float, int2, float2|
# Then('p = tuple\({int}, {float}, {float}, {int})') do |int, float, float2, int2|
# Then('p = tuple\({int}, {float}, {float}, {float})') do |int, float, float2, float3|
# Then('p = tuple\({float}, {int}, {int}, {int})') do |float, int, int2, int3|
# Then('p = tuple\({float}, {int}, {int}, {float})') do |float, int, int2, float2|
# Then('p = tuple\({float}, {int}, {float}, {int})') do |float, int, float2, int2|
# Then('p = tuple\({float}, {int}, {float}, {float})') do |float, int, float2, float3|
# Then('p = tuple\({float}, {float}, {int}, {int})') do |float, float2, int, int2|
# Then('p = tuple\({float}, {float}, {int}, {float})') do |float, float2, int, float3|
# Then('p = tuple\({float}, {float}, {float}, {int})') do |float, float2, float3, int|
# Then('p = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
end

Given('v ← vector\({float}, {float}, {float})') do |float, float2, float3|
  @v = Vector.new(x: float, y: float2, z: float3)
# Given('v ← vector\({int}, {int}, {float})') do |int, int2, float|
# Given('v ← vector\({int}, {float}, {int})') do |int, float, int2|
# Given('v ← vector\({int}, {float}, {float})') do |int, float, float2|
# Given('v ← vector\({float}, {int}, {int})') do |float, int, int2|
# Given('v ← vector\({float}, {int}, {float})') do |float, int, float2|
# Given('v ← vector\({float}, {float}, {int})') do |float, float2, int|
# Given('v ← vector\({float}, {float}, {float})') do |float, float2, float3|
end

Then('v = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @v == Tuple.new(x: float, y: float2, z: float3, w: float4)
# Then('v = tuple\({int}, {int}, {int}, {float})') do |int, int2, int3, float|
# Then('v = tuple\({int}, {int}, {float}, {int})') do |int, int2, float, int3|
# Then('v = tuple\({int}, {int}, {float}, {float})') do |int, int2, float, float2|
# Then('v = tuple\({int}, {float}, {int}, {int})') do |int, float, int2, int3|
# Then('v = tuple\({int}, {float}, {int}, {float})') do |int, float, int2, float2|
# Then('v = tuple\({int}, {float}, {float}, {int})') do |int, float, float2, int2|
# Then('v = tuple\({int}, {float}, {float}, {float})') do |int, float, float2, float3|
# Then('v = tuple\({float}, {int}, {int}, {int})') do |float, int, int2, int3|
# Then('v = tuple\({float}, {int}, {int}, {float})') do |float, int, int2, float2|
# Then('v = tuple\({float}, {int}, {float}, {int})') do |float, int, float2, int2|
# Then('v = tuple\({float}, {int}, {float}, {float})') do |float, int, float2, float3|
# Then('v = tuple\({float}, {float}, {int}, {int})') do |float, float2, int, int2|
# Then('v = tuple\({float}, {float}, {int}, {float})') do |float, float2, int, float3|
# Then('v = tuple\({float}, {float}, {float}, {int})') do |float, float2, float3, int|
# Then('v = tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
end
