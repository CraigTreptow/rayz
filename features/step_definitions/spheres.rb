Given('s ← sphere\()') do
  @s = Rayz::Sphere.new
end

When('xs ← intersect\(s, r)') do
  @xs = @s.intersect(@r)
end

Then('xs.count = {int}') do |count|
  assert_equal(@xs.count, count)
end

Then('xs[{int}] = {float}') do |index, value|
  assert_equal(@xs[index].t, value)
end

Then('xs[{int}].object = s') do |index|
  assert_equal(@xs[index].object, @s)
end

Then('s.transform = identity_matrix') do
  assert_equal(@s.transform, Matrix.identity(4))
end

Given('t ← translation\({float}, {float}, {float})') do |x, y, z|
  @t = Rayz::Transformations.translation(x, y, z)
end

When('set_transform\(s, t)') do
  @s.transform = @t
end

Then('s.transform = t') do
  assert_equal(@s.transform, @t)
end

When('set_transform\(s, scaling\({float}, {float}, {float}))') do |x, y, z|
  @s.transform = Rayz::Transformations.scaling(x, y, z)
end

When('set_transform\(s, translation\({float}, {float}, {float}))') do |x, y, z|
  @s.transform = Rayz::Transformations.translation(x, y, z)
end
