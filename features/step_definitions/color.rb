Given('c ← color\({float}, {float}, {float})') do |float, float2, float3|
  @c = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Then("c.red = {float}") do |float|
  assert_equal(@c.red, float)
end

Then("c.green = {float}") do |float|
  assert_equal(@c.green, float)
end

Then("c.blue = {float}") do |float|
  assert_equal(@c.blue, float)
end

Given('color1 ← color\({float}, {float}, {float})') do |float, float2, float3|
  @color1 = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Given('color2 ← color\({float}, {float}, {float})') do |float, float2, float3|
  @color2 = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Given('color3 ← color\({float}, {float}, {float})') do |float, float2, float3|
  @color3 = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Given('c1 ← color\({float}, {float}, {float})') do |float, float2, float3|
  @c1 = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Given('c2 ← color\({float}, {float}, {float})') do |float, float2, float3|
  @c2 = Rayz::Color.new(red: float, green: float2, blue: float3)
end

Then('c1 + c2 = color\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Color.new(red: float, green: float2, blue: float3)
  assert_equal(@c1 + @c2, expected)
end

Then('c1 - c2 = color\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Color.new(red: float, green: float2, blue: float3)
  assert_equal(@c1 - @c2, expected)
end

Then('c1 * c2 = color\({float}, {float}, {float})') do |float, float2, float3|
  expected = Rayz::Color.new(red: float, green: float2, blue: float3)
  assert_equal(@c1 * @c2, expected)
end

Then('c * {float} = color\({float}, {float}, {float})') do |float, float2, float3, float4|
  expected = Rayz::Color.new(red: float2, green: float3, blue: float4)
  assert_equal(@c * float, expected)
end
