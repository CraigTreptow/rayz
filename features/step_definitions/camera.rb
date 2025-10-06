# Step definitions for camera operations

Given("hsize ← {int}") do |value|
  @hsize = value
end

Given("vsize ← {int}") do |value|
  @vsize = value
end

Given(/field_of_view ← π\/(\d+)/) do |divisor|
  @field_of_view = Math::PI / divisor.to_f
end

When("c ← camera\\(hsize, vsize, field_of_view)") do
  @c = Rayz::Camera.new(hsize: @hsize, vsize: @vsize, field_of_view: @field_of_view)
end

Then("c.hsize = {int}") do |value|
  assert_equal(@c.hsize, value)
end

Then("c.vsize = {int}") do |value|
  assert_equal(@c.vsize, value)
end

Then(/c\.field_of_view = π\/(\d+)/) do |divisor|
  expected = Math::PI / divisor.to_f
  assert_equal(@c.field_of_view, expected)
end

Then("c.transform = identity_matrix") do
  assert_equal(@c.transform, Matrix.identity(4))
end

Given(/c ← camera\((\d+), (\d+), π\/(\d+)\)/) do |hsize, vsize, divisor|
  @c = Rayz::Camera.new(hsize: hsize.to_i, vsize: vsize.to_i, field_of_view: Math::PI / divisor.to_f)
end

Then("c.pixel_size = {float}") do |value|
  assert_in_delta(@c.pixel_size, value, Rayz::Util::EPSILON)
end

When("r ← ray_for_pixel\\(c, {int}, {int})") do |x, y|
  @r = @c.ray_for_pixel(x, y)
end

When(/c\.transform ← rotation_y\(π\/(\d+)\) \* translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)/) do |pi_divisor, tx, ty, tz|
  @c.transform = Rayz::Transformations.rotation_y(radians: Math::PI / pi_divisor.to_f) * Rayz::Transformations.translation(x: tx.to_f, y: ty.to_f, z: tz.to_f)
end

Then(/r\.direction = vector\(√(\d+)\/(\d+), (\d+(?:\.\d+)?), -√(\d+)\/(\d+)\)/) do |sqrt_num_x, sqrt_den_x, y, sqrt_num_z, sqrt_den_z|
  expected = Rayz::Vector.new(
    x: Math.sqrt(sqrt_num_x.to_f) / sqrt_den_x.to_f,
    y: y.to_f,
    z: -Math.sqrt(sqrt_num_z.to_f) / sqrt_den_z.to_f
  )
  assert_equal(@r.direction, expected)
end

Given("from ← point\\({float}, {float}, {float})") do |x, y, z|
  @from = Rayz::Point.new(x: x, y: y, z: z)
end

Given("to ← point\\({float}, {float}, {float})") do |x, y, z|
  @to = Rayz::Point.new(x: x, y: y, z: z)
end

Given("up ← vector\\({float}, {float}, {float})") do |x, y, z|
  @up = Rayz::Vector.new(x: x, y: y, z: z)
end

Given("c.transform ← view_transform\\(from, to, up)") do
  @c.transform = Rayz::Transformations.view_transform(from: @from, to: @to, up: @up)
end

When("image ← render\\(c, w)") do
  @image = @c.render(@w)
end

Then("pixel_at\\(image, {int}, {int}) = color\\({float}, {float}, {float})") do |x, y, r, g, b|
  expected = Rayz::Color.new(red: r, green: g, blue: b)
  actual = @image.pixel_at(col: x, row: y)
  assert_equal(actual, expected)
end
