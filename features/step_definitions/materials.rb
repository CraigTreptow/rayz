# Step definitions for material and lighting operations

Given("m ← material\\()") do
  @m = Rayz::Material.new
end

Then("m.color = color\\({float}, {float}, {float})") do |r, g, b|
  expected = Rayz::Color.new(red: r, green: g, blue: b)
  assert_equal(@m.color, expected)
end

Then("m.ambient = {float}") do |value|
  assert_equal(@m.ambient, value)
end

Then("m.diffuse = {float}") do |value|
  assert_equal(@m.diffuse, value)
end

Then("m.specular = {float}") do |value|
  assert_equal(@m.specular, value)
end

Then("m.shininess = {float}") do |value|
  assert_equal(@m.shininess, value)
end

Then("m.reflective = {float}") do |value|
  assert_equal(@m.reflective, value)
end

Then("m.transparency = {float}") do |value|
  assert_equal(@m.transparency, value)
end

Then("m.refractive_index = {float}") do |value|
  assert_equal(@m.refractive_index, value)
end

# Lighting step definitions
Given("eyev ← vector\\({float}, {float}, {float})") do |x, y, z|
  @eyev = Rayz::Vector.new(x: x, y: y, z: z)
end

Given(/eyev ← vector\((\d+(?:\.\d+)?), √(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), -√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)/) do |x, sqrt_num_y, sqrt_den_y, sqrt_num_z, sqrt_den_z|
  @eyev = Rayz::Vector.new(
    x: x.to_f,
    y: Math.sqrt(sqrt_num_y.to_f) / sqrt_den_y.to_f,
    z: -Math.sqrt(sqrt_num_z.to_f) / sqrt_den_z.to_f
  )
end

Given(/eyev ← vector\((\d+(?:\.\d+)?), -√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), -√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)/) do |x, sqrt_num_y, sqrt_den_y, sqrt_num_z, sqrt_den_z|
  @eyev = Rayz::Vector.new(
    x: x.to_f,
    y: -Math.sqrt(sqrt_num_y.to_f) / sqrt_den_y.to_f,
    z: -Math.sqrt(sqrt_num_z.to_f) / sqrt_den_z.to_f
  )
end

Given("normalv ← vector\\({float}, {float}, {float})") do |x, y, z|
  @normalv = Rayz::Vector.new(x: x, y: y, z: z)
end

Given("light ← point_light\\(point\\({float}, {float}, {float}), color\\({float}, {float}, {float}))") do |px, py, pz, cr, cg, cb|
  position = Rayz::Point.new(x: px, y: py, z: pz)
  intensity = Rayz::Color.new(red: cr, green: cg, blue: cb)
  @light = Rayz::PointLight.new(position: position, intensity: intensity)
end

Given("in_shadow ← true") do
  @in_shadow = true
end

When("result ← lighting\\(m, light, position, eyev, normalv)") do
  @result = Rayz.lighting(@m, @light, @position, @eyev, @normalv)
end

When("result ← lighting\\(m, light, position, eyev, normalv, in_shadow)") do
  # Convert boolean to intensity (true = 0.0 fully shadowed, false = 1.0 fully lit)
  intensity = @in_shadow ? 0.0 : 1.0
  @result = Rayz.lighting(@m, @light, @position, @eyev, @normalv, intensity)
end

Then("result = color\\({float}, {float}, {float})") do |r, g, b|
  expected = Rayz::Color.new(red: r, green: g, blue: b)
  assert_equal(@result, expected)
end

# Pattern-related steps (skipping for now)
Given("m.pattern ← stripe_pattern\\(color\\({float}, {float}, {float}), color\\({float}, {float}, {float}))") do |r1, g1, b1, r2, g2, b2|
  skip("Patterns not implemented yet")
end

Given("m.ambient ← {float}") do |value|
  @m.ambient = value
end

Given("m.diffuse ← {float}") do |value|
  @m.diffuse = value
end

Given("m.specular ← {float}") do |value|
  @m.specular = value
end

When("c1 ← lighting\\(m, light, point\\({float}, {float}, {float}), eyev, normalv, false)") do |x, y, z|
  skip("Patterns not implemented yet")
end

When("c2 ← lighting\\(m, light, point\\({float}, {float}, {float}), eyev, normalv, false)") do |x, y, z|
  skip("Patterns not implemented yet")
end

Then("c1 = color\\({float}, {float}, {float})") do |r, g, b|
  skip("Patterns not implemented yet")
end

Then("c2 = color\\({float}, {float}, {float})") do |r, g, b|
  skip("Patterns not implemented yet")
end
