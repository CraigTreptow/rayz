When('i ← intersection\({float}, s)') do |t|
  @i = Rayz::Intersection.new(t: t, object: @s)
end

Then("i.t = {float}") do |t|
  assert_equal(@i.t, t)
end

Then("i.object = s") do
  assert_equal(@i.object, @s)
end

Given(/^i1 ← intersection\((.+), s\)$/) do |t|
  @i1 = Rayz::Intersection.new(t: t.to_f, object: @s)
end

Given(/^i2 ← intersection\((.+), s\)$/) do |t|
  @i2 = Rayz::Intersection.new(t: t.to_f, object: @s)
end

When('xs ← intersections\(i1, i2)') do
  @xs = Rayz.intersections(@i1, @i2)
end

Then("xs[{int}].t = {int}") do |index, value|
  assert_equal(@xs[index].t, value)
end

When('xs ← intersections\(i2, i1)') do
  @xs = Rayz.intersections(@i2, @i1)
end

When('i ← hit\(xs)') do
  @i = Rayz.hit(@xs)
end

Then("i = i1") do
  assert_equal(@i, @i1)
end

Then("i = i2") do
  assert_equal(@i, @i2)
end

Then("i is nothing") do
  assert_equal(@i, nil)
end

Given('i3 ← intersection\({int}, s)') do |t|
  @i3 = Rayz::Intersection.new(t: t, object: @s)
end

Given('i4 ← intersection\({int}, s)') do |t|
  @i4 = Rayz::Intersection.new(t: t, object: @s)
end

When('xs ← intersections\(i1, i2, i3, i4)') do
  @xs = Rayz.intersections(@i1, @i2, @i3, @i4)
end

Then("i = i4") do
  assert_equal(@i, @i4)
end

When("comps ← prepare_computations\\(i, r, xs)") do
  @comps = @i.prepare_computations(@r, @xs)
end

When(/comps ← prepare_computations\(xs\[(\d+)\], r, xs\)/) do |index|
  @comps = @xs[index.to_i].prepare_computations(@r, @xs)
end

Then(/comps\.reflectv = vector\(([^,]+),\s*([^,]+),\s*([^)]+)\)/) do |x, y, z|
  x_val = (x.strip =~ /√(\d+)\/(\d+)/) ? Math.sqrt($1.to_f) / $2.to_f : x.to_f
  y_val = (y.strip =~ /√(\d+)\/(\d+)/) ? Math.sqrt($1.to_f) / $2.to_f : y.to_f
  z_val = (z.strip =~ /√(\d+)\/(\d+)/) ? Math.sqrt($1.to_f) / $2.to_f : z.to_f
  expected = Rayz::Vector.new(x: x_val, y: y_val, z: z_val)
  assert_equal(@comps.reflectv, expected)
end

Then("comps.under_point.z > EPSILON\\/2") do
  assert(@comps.under_point.z > Rayz::Util::EPSILON / 2)
end

Then("comps.point.z < comps.under_point.z") do
  assert(@comps.point.z < @comps.under_point.z)
end

Then("comps.n1 = {float}") do |n1|
  assert_equal(@comps.n1, n1)
end

Then("comps.n2 = {float}") do |n2|
  assert_equal(@comps.n2, n2)
end

When(/^xs ← intersections\((.+:.+)\)$/) do |list|
  # This step only matches when there's a colon (t:object notation)
  intersections = []
  items = list.split(",").map(&:strip)
  items.each do |item|
    if item.include?(":")
      # Handle t:object notation
      parts = item.split(":")
      t_str = parts[0].strip
      obj_name = parts[1].strip
      t = if t_str =~ /√(\d+)\/(\d+)/
        Math.sqrt($1.to_f) / $2.to_f
      else
        (t_str =~ /-?√(\d+)\/(\d+)/) ? -Math.sqrt($1.to_f) / $2.to_f : t_str.to_f
      end
      obj = instance_variable_get("@#{obj_name}")
      intersections << Rayz::Intersection.new(t: t, object: obj)
    elsif item == "i"
      intersections << @i
    else
      # Handle variable names like i1, i2
      intersections << instance_variable_get("@#{item}")
    end
  end
  @xs = Rayz.intersections(*intersections)
end

When('xs ← intersections\(i)') do
  @xs = Rayz.intersections(@i)
end

When("reflectance ← schlick\\(comps)") do
  @reflectance = Rayz.schlick(@comps)
end

Then("reflectance = {float}") do |value|
  assert_equal(@reflectance, value)
end
