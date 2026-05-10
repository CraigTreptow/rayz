Given('s ← sphere\()') do
  @s = Rayz::Sphere.new
end

When('xs ← intersect\(s, r)') do
  @xs = @s.intersect(@r)
end

Then("xs.count = {int}") do |count|
  assert_equal(@xs.count, count)
end

Then("xs[{int}] = {float}") do |index, value|
  assert_equal(@xs[index].t, value)
end

Then("xs[{int}].object = s") do |index|
  assert_equal(@xs[index].object, @s)
end

Then("s.transform = identity_matrix") do
  assert_equal(@s.transform, Matrix.identity(4))
end

Given('t ← translation\({float}, {float}, {float})') do |x, y, z|
  @t = Rayz::Transformations.translation(x: x, y: y, z: z)
end

When('set_transform\(s, t)') do
  @s.transform = @t
end

Then("s.transform = t") do
  assert_equal(@s.transform, @t)
end

When('set_transform\(s, scaling\({float}, {float}, {float}))') do |x, y, z|
  @s.transform = Rayz::Transformations.scaling(x: x, y: y, z: z)
end

When('set_transform\(s, translation\({float}, {float}, {float}))') do |x, y, z|
  @s.transform = Rayz::Transformations.translation(x: x, y: y, z: z)
end

When("n ← normal_at\\(s, point\\({float}, {float}, {float}))") do |x, y, z|
  point = Rayz::Point.new(x: x, y: y, z: z)
  @n = @s.normal_at(point)
end

When(/n ← normal_at\(s, point\(√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), √(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), √(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)\)/) do |sqrt_num_x, sqrt_den_x, sqrt_num_y, sqrt_den_y, sqrt_num_z, sqrt_den_z|
  point = Rayz::Point.new(
    x: Math.sqrt(sqrt_num_x.to_f) / sqrt_den_x.to_f,
    y: Math.sqrt(sqrt_num_y.to_f) / sqrt_den_y.to_f,
    z: Math.sqrt(sqrt_num_z.to_f) / sqrt_den_z.to_f
  )
  @n = @s.normal_at(point)
end

Then("n = vector\\({float}, {float}, {float})") do |x, y, z|
  expected = Rayz::Vector.new(x: x, y: y, z: z)
  assert_equal(@n, expected)
end

Then(/n = vector\(√(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), √(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?), √(\d+(?:\.\d+)?)\/(\d+(?:\.\d+)?)\)/) do |sqrt_num_x, sqrt_den_x, sqrt_num_y, sqrt_den_y, sqrt_num_z, sqrt_den_z|
  expected = Rayz::Vector.new(
    x: Math.sqrt(sqrt_num_x.to_f) / sqrt_den_x.to_f,
    y: Math.sqrt(sqrt_num_y.to_f) / sqrt_den_y.to_f,
    z: Math.sqrt(sqrt_num_z.to_f) / sqrt_den_z.to_f
  )
  assert_equal(@n, expected)
end

Then("n = normalize\\(n)") do
  assert_equal(@n, @n.normalize)
end

Given(/m ← scaling\((\d+(?:\.\d+)?), (\d+(?:\.\d+)?), (\d+(?:\.\d+)?)\) \* rotation_z\(π\/(\d+(?:\.\d+)?)\)/) do |sx, sy, sz, pi_divisor|
  @m = Rayz::Transformations.scaling(x: sx.to_f, y: sy.to_f, z: sz.to_f) * Rayz::Transformations.rotation_z(radians: Math::PI / pi_divisor.to_f)
end

Given("set_transform\\(s, m)") do
  @s.transform = @m
end

When("m ← s.material") do
  @m = @s.material
end

Then("m = material\\()") do
  expected = Rayz::Material.new
  assert_equal(@m, expected)
end

When("s.material ← m") do
  @s.material = @m
end

Then("s.material = m") do
  assert_equal(@s.material, @m)
end

Given("s ← glass_sphere\\()") do
  @s = Rayz.glass_sphere
end

Given(/([A-Z]) ← glass_sphere\(\) with:/) do |var_name, table|
  sphere = Rayz.glass_sphere
  table.raw.each do |row|
    property = row[0].strip
    value = row[1].strip

    case property
    when "transform"
      if value =~ /scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        sphere.transform = Rayz::Transformations.scaling(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      elsif value =~ /translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        sphere.transform = Rayz::Transformations.translation(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      end
    when "material.refractive_index"
      sphere.material.refractive_index = value.to_f
    when "material.transparency"
      sphere.material.transparency = value.to_f
    end
  end
  instance_variable_set("@#{var_name}", sphere)
end
