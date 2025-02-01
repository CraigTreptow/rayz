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

When("I do an action") do
  :no_op
end

Then("some results should be there") do
  expect(@this_will_pass).to be true
end
