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
  assert_nil(@i)
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
      t = if t_str =~ /^-?√(\d+)\/(\d+)$/
        # Handle ±√n/d format
        sign = t_str.start_with?("-") ? -1 : 1
        sign * Math.sqrt($1.to_f) / $2.to_f
      elsif t_str =~ /^-?√(\d+)$/
        # Handle ±√n format
        sign = t_str.start_with?("-") ? -1 : 1
        sign * Math.sqrt($1.to_f)
      else
        t_str.to_f
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
  assert_in_delta(@reflectance, value, Rayz::Util::EPSILON)
end

Then("comps.over_point.z < -EPSILON\\/2") do
  assert(@comps.over_point.z < -Rayz::Util::EPSILON / 2)
end

Then("comps.point.z > comps.over_point.z") do
  assert(@comps.point.z > @comps.over_point.z)
end

# Computations assertions using {point} and {vector} parameter types
Then("comps.point = {point}") do |point|
  assert_equal(point, @comps.point)
end

Then("comps.eyev = {vector}") do |vector|
  assert_equal(vector, @comps.eyev)
end

Then("comps.normalv = {vector}") do |vector|
  assert_equal(vector, @comps.normalv)
end

Then("comps.inside = {word}") do |value|
  expected = value == "true"
  assert_equal(expected, @comps.inside)
end

# Glass sphere for 'shape' variable only (not 's' which is in spheres.rb)
Given(/^shape ← glass_sphere\(\)$/) do
  @shape = Rayz.glass_sphere
end

# Glass sphere with properties for 'shape' variable (not 's' which is in spheres.rb)
Given(/^shape ← glass_sphere\(\) with:$/) do |table|
  @shape = Rayz.glass_sphere
  table.raw.each do |row|
    property = row[0].strip
    value = row[1].strip

    case property
    when "transform"
      if value =~ /scaling\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @shape.transform = Rayz::Transformations.scaling(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      elsif value =~ /translation\(([^,]+),\s*([^,]+),\s*([^)]+)\)/
        @shape.transform = Rayz::Transformations.translation(x: $1.to_f, y: $2.to_f, z: $3.to_f)
      end
    when "material.refractive_index"
      @shape.material.refractive_index = value.to_f
    when "material.transparency"
      @shape.material.transparency = value.to_f
    end
  end
end

Given(/^s ← triangle\(point\(([^,]+),\s*([^,]+),\s*([^)]+)\), point\(([^,]+),\s*([^,]+),\s*([^)]+)\), point\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |p1x, p1y, p1z, p2x, p2y, p2z, p3x, p3y, p3z|
  p1 = Rayz::Point.new(x: p1x.to_f, y: p1y.to_f, z: p1z.to_f)
  p2 = Rayz::Point.new(x: p2x.to_f, y: p2y.to_f, z: p2z.to_f)
  p3 = Rayz::Point.new(x: p3x.to_f, y: p3y.to_f, z: p3z.to_f)
  @s = Rayz::Triangle.new(p1: p1, p2: p2, p3: p3)
end

When("i ← intersection_with_uv\\({float}, s, {float}, {float})") do |t, u, v|
  @i = Rayz::Intersection.new(t: t, object: @s, u: u, v: v)
end

Then("i.u = {float}") do |u|
  assert_equal(@i.u, u)
end

Then("i.v = {float}") do |v|
  assert_equal(@i.v, v)
end

# Helper to evaluate transformation expressions
def eval_transformation(expression)
  # Replace π with Math::PI
  expression = expression.gsub("π", "Math::PI")

  # Replace transformation function names with module calls
  expression = expression.gsub(/translation\(([^)]+)\)/) do
    args = $1.split(",").map(&:strip)
    "Rayz::Transformations.translation(x: #{args[0]}, y: #{args[1]}, z: #{args[2]})"
  end

  expression = expression.gsub(/scaling\(([^)]+)\)/) do
    args = $1.split(",").map(&:strip)
    "Rayz::Transformations.scaling(x: #{args[0]}, y: #{args[1]}, z: #{args[2]})"
  end

  expression = expression.gsub(/rotation_x\(([^)]+)\)/) do
    "Rayz::Transformations.rotation_x(radians: #{$1})"
  end

  expression = expression.gsub(/rotation_y\(([^)]+)\)/) do
    "Rayz::Transformations.rotation_y(radians: #{$1})"
  end

  expression = expression.gsub(/rotation_z\(([^)]+)\)/) do
    "Rayz::Transformations.rotation_z(radians: #{$1})"
  end

  # rubocop:disable Security/Eval
  eval(expression)
  # rubocop:enable Security/Eval
end
