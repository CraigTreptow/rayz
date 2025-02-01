Given('a ← tuple\({float}, {float}, {float}, {float})') do |float, float2, float3, float4|
  @a = Tuple.new(x: float, y: float2, z: float3, w: float4)
end

Then("a.x = {float}") do |float|
  expect(@a.x).to eql(float)
end

Then("a.y = {float}") do |float|
  expect(@a.y).to eql(float)
end

Then("a.z = {float}") do |float|
  expect(@a.z).to eql(float)
end

Then("a.w = {float}") do |float|
  expect(@a.w).to eql(float)
end

Then("a is a point") do
  expect(@a.point?).to be true
end

Then("a is not a vector") do
  expect(@a.vector?).to be false
end

Then("a is not a point") do
  expect(@a.point?).to be false
end

Then("a is a vector") do
  expect(@a.vector?).to be true
end

When("I do an action") do
  :no_op
end

Then("some results should be there") do
  expect(@this_will_pass).to be true
end
