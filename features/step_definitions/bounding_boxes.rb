Given(/^box ← bounds\(\)$/) do
  @box = Rayz::Bounds.new
end

Given(/^box ← bounds\(min: point\((.+), (.+), (.+)\), max: point\((.+), (.+), (.+)\)\)$/) do |min_x, min_y, min_z, max_x, max_y, max_z|
  @box = Rayz::Bounds.new(
    min: Rayz::Point.new(x: eval_numeric(min_x), y: eval_numeric(min_y), z: eval_numeric(min_z)),
    max: Rayz::Point.new(x: eval_numeric(max_x), y: eval_numeric(max_y), z: eval_numeric(max_z))
  )
end

Given(/^(box\d+) ← bounds\(min: point\((.+), (.+), (.+)\), max: point\((.+), (.+), (.+)\)\)$/) do |var, min_x, min_y, min_z, max_x, max_y, max_z|
  instance_variable_set(
    "@#{var}",
    Rayz::Bounds.new(
      min: Rayz::Point.new(x: eval_numeric(min_x), y: eval_numeric(min_y), z: eval_numeric(min_z)),
      max: Rayz::Point.new(x: eval_numeric(max_x), y: eval_numeric(max_y), z: eval_numeric(max_z))
    )
  )
end

When(/^box ← bounds_of\(shape\)$/) do
  @box = @shape.bounds
end

When(/^(box\d+) ← transform\(box, matrix\)$/) do |var|
  instance_variable_set("@#{var}", @box.transform(@matrix))
end

When(/^(box\d+) ← merge\((box\d+), (box\d+)\)$/) do |result_var, box1_var, box2_var|
  box1 = instance_variable_get("@#{box1_var}")
  box2 = instance_variable_get("@#{box2_var}")
  instance_variable_set("@#{result_var}", box1.merge(box2))
end

Then(/^box\.min = point\((.+), (.+), (.+)\)$/) do |x, y, z|
  assert_point_equal(eval_numeric(x), eval_numeric(y), eval_numeric(z), @box.min)
end

Then(/^box\.max = point\((.+), (.+), (.+)\)$/) do |x, y, z|
  assert_point_equal(eval_numeric(x), eval_numeric(y), eval_numeric(z), @box.max)
end

Then(/^(box\d+)\.min = point\((.+), (.+), (.+)\)$/) do |var, x, y, z|
  box = instance_variable_get("@#{var}")
  assert_point_equal(eval_numeric(x), eval_numeric(y), eval_numeric(z), box.min)
end

Then(/^(box\d+)\.max = point\((.+), (.+), (.+)\)$/) do |var, x, y, z|
  box = instance_variable_get("@#{var}")
  assert_point_equal(eval_numeric(x), eval_numeric(y), eval_numeric(z), box.max)
end

Then(/^box contains point\((.+), (.+), (.+)\)$/) do |x, y, z|
  point = Rayz::Point.new(x: eval_numeric(x), y: eval_numeric(y), z: eval_numeric(z))
  assert(@box.contains_point?(point), "Expected box to contain point")
end

Then(/^box does not contain point\((.+), (.+), (.+)\)$/) do |x, y, z|
  point = Rayz::Point.new(x: eval_numeric(x), y: eval_numeric(y), z: eval_numeric(z))
  assert(!@box.contains_point?(point), "Expected box to not contain point")
end

Then(/^box contains bounds\(min: point\((.+), (.+), (.+)\), max: point\((.+), (.+), (.+)\)\)$/) do |min_x, min_y, min_z, max_x, max_y, max_z|
  bounds = Rayz::Bounds.new(
    min: Rayz::Point.new(x: eval_numeric(min_x), y: eval_numeric(min_y), z: eval_numeric(min_z)),
    max: Rayz::Point.new(x: eval_numeric(max_x), y: eval_numeric(max_y), z: eval_numeric(max_z))
  )
  assert(@box.contains_bounds?(bounds), "Expected box to contain bounds")
end

Then(/^box does not contain bounds\(min: point\((.+), (.+), (.+)\), max: point\((.+), (.+), (.+)\)\)$/) do |min_x, min_y, min_z, max_x, max_y, max_z|
  bounds = Rayz::Bounds.new(
    min: Rayz::Point.new(x: eval_numeric(min_x), y: eval_numeric(min_y), z: eval_numeric(min_z)),
    max: Rayz::Point.new(x: eval_numeric(max_x), y: eval_numeric(max_y), z: eval_numeric(max_z))
  )
  assert(!@box.contains_bounds?(bounds), "Expected box to not contain bounds")
end

Then(/^intersects\(box, r\) = (true|false)$/) do |result|
  expected = result == "true"
  assert_equal(expected, @box.intersects?(@r))
end

Given(/^direction ← normalize\(<(.+), (.+), (.+)>\)$/) do |x, y, z|
  vec = Rayz::Vector.new(x: eval_numeric(x), y: eval_numeric(y), z: eval_numeric(z))
  @direction = vec.normalize
end

Then(/^child\.saved_ray is nothing$/) do
  assert_nil(@child.saved_ray)
end

Then(/^child\.saved_ray is not nothing$/) do
  refute_nil(@child.saved_ray)
end

Given(/^matrix ← (rotation_[xyz]\([^)]+\) \* rotation_[xyz]\([^)]+\))$/) do |expression|
  @matrix = eval_transformation(expression)
end

Given(/^set_transform\(s, (.+\s*\*\s*.+)\)$/) do |expression|
  @s.transform = eval_transformation(expression)
end

Given(/^set_transform\(c, (.+\s*\*\s*.+)\)$/) do |expression|
  @c.transform = eval_transformation(expression)
end

Given(/^add_child\(shape, (s|c|child)\)$/) do |child_var|
  child = instance_variable_get("@#{child_var}")
  @shape.add_child(child)
end

When(/^xs ← intersect\(shape, r\)$/) do
  @xs = @shape.intersect(@r)
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

# Helper to assert point equality with special handling for infinity
def assert_point_equal(expected_x, expected_y, expected_z, actual_point)
  # Use slightly larger tolerance for bounding box tests that involve
  # transformations, as the expected values are often rounded
  tolerance = Rayz::Util::EPSILON * 2

  if expected_x.infinite?
    assert_equal(expected_x, actual_point.x)
  else
    assert_in_delta(expected_x, actual_point.x, tolerance)
  end

  if expected_y.infinite?
    assert_equal(expected_y, actual_point.y)
  else
    assert_in_delta(expected_y, actual_point.y, tolerance)
  end

  if expected_z.infinite?
    assert_equal(expected_z, actual_point.z)
  else
    assert_in_delta(expected_z, actual_point.z, tolerance)
  end
end

# Helper to evaluate numeric expressions including infinity and π
def eval_numeric(str)
  str = str.strip
  return Float::INFINITY if str == "∞"
  return -Float::INFINITY if str == "-∞"
  return Math::PI if str == "π"
  return -Math::PI if str == "-π"

  # Handle π expressions
  str = str.gsub("π", "Math::PI")

  # rubocop:disable Security/Eval
  eval(str).to_f
  # rubocop:enable Security/Eval
end
