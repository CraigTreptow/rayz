Given('origin ← point\({float}, {float}, {float})') do |x, y, z|
  @origin = Rayz::Point.new(x: x, y: y, z: z)
end

Given('direction ← vector\({float}, {float}, {float})') do |x, y, z|
  @direction = Rayz::Vector.new(x: x, y: y, z: z)
end

When('r ← ray\(origin, direction)') do
  @r = Rayz::Ray.new(@origin, @direction)
end

Then('r.origin = origin') do
  assert_equal(@r.origin, @origin)
end

Then('r.direction = direction') do
  assert_equal(@r.direction, @direction)
end

Given('r ← ray\(point\({float}, {float}, {float}), vector\({float}, {float}, {float}))') do |x1, y1, z1, x2, y2, z2|
  @r = Rayz::Ray.new(Rayz::Point.new(x: x1, y: y1, z: z1), Rayz::Vector.new(x: x2, y: y2, z: z2))
end

Then(/^position\(r, (.+)\) = point\((.+), (.+), (.+)\)$/) do |t, x, y, z|
  assert_equal(@r.position(t.to_f), Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f))
end

Given('m ← translation\({float}, {float}, {float})') do |x, y, z|
  @m = Rayz::Transformations.translation(x, y, z)
end

When('r2 ← transform\(r, m)') do
  @r2 = @r.transform(@m)
end

Then('r2.origin = point\({float}, {float}, {float})') do |x, y, z|
  assert_equal(@r2.origin, Rayz::Point.new(x: x, y: y, z: z))
end

Then('r2.direction = vector\({float}, {float}, {float})') do |x, y, z|
  assert_equal(@r2.direction, Rayz::Vector.new(x: x, y: y, z: z))
end

Given('m ← scaling\({float}, {float}, {float})') do |x, y, z|
  @m = Rayz::Transformations.scaling(x, y, z)
end
