When('i ← intersection\({float}, s)') do |t|
  @i = Rayz::Intersection.new(t, @s)
end

Then('i.t = {float}') do |t|
  assert_equal(@i.t, t)
end

Then('i.object = s') do
  assert_equal(@i.object, @s)
end

Given(/^i1 ← intersection\((.+), s\)$/) do |t|
  @i1 = Rayz::Intersection.new(t.to_f, @s)
end

Given(/^i2 ← intersection\((.+), s\)$/) do |t|
  @i2 = Rayz::Intersection.new(t.to_f, @s)
end

When('xs ← intersections\(i1, i2)') do
  @xs = Rayz.intersections(@i1, @i2)
end

Then('xs[{int}].t = {int}') do |index, value|
  assert_equal(@xs[index].t, value)
end

When('xs ← intersections\(i2, i1)') do
  @xs = Rayz.intersections(@i2, @i1)
end

When('i ← hit\(xs)') do
  @i = Rayz.hit(@xs)
end

Then('i = i1') do
  assert_equal(@i, @i1)
end

Then('i = i2') do
  assert_equal(@i, @i2)
end

Then('i is nothing') do
  assert_equal(@i, nil)
end

Given('i3 ← intersection\({int}, s)') do |t|
  @i3 = Rayz::Intersection.new(t, @s)
end

Given('i4 ← intersection\({int}, s)') do |t|
  @i4 = Rayz::Intersection.new(t, @s)
end

When('xs ← intersections\(i1, i2, i3, i4)') do
  @xs = Rayz.intersections(@i1, @i2, @i3, @i4)
end

Then('i = i4') do
  assert_equal(@i, @i4)
end
