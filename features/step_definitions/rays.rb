Given('origin ← point\({float}, {float}, {float})') do |x, y, z|
  @origin = Rayz::Point.new(x: x, y: y, z: z)
end

Given('direction ← vector\({float}, {float}, {float})') do |x, y, z|
  @direction = Rayz::Vector.new(x: x, y: y, z: z)
end

When('r ← ray\(origin, direction)') do
  @r = Rayz::Ray.new(origin: @origin, direction: @direction)
end

Then("r.origin = origin") do
  assert_equal(@r.origin, @origin)
end

Then("r.direction = direction") do
  assert_equal(@r.direction, @direction)
end

# Ray creation supporting both regular numbers and √ notation
Given(/^r ← ray\(point\(([^,]+),\s*([^,]+),\s*([^)]+)\), vector\(([^,]+),\s*([^,]+),\s*([^)]+)\)\)$/) do |px, py, pz, vx, vy, vz|
  # Helper to parse value (handles both regular numbers and √ notation)
  parse_val = lambda do |val|
    if val.include?("√")
      # rubocop:disable Security/Eval
      result = eval(val.gsub(/(-?)√(\d+)\/(\d+)/, '\1Math.sqrt(\2)/\3'))
      # rubocop:enable Security/Eval
      result
    else
      val.to_f
    end
  end

  @r = Rayz::Ray.new(
    origin: Rayz::Point.new(x: parse_val.call(px), y: parse_val.call(py), z: parse_val.call(pz)),
    direction: Rayz::Vector.new(x: parse_val.call(vx), y: parse_val.call(vy), z: parse_val.call(vz))
  )
end

Then(/^position\(r, (.+)\) = point\((.+), (.+), (.+)\)$/) do |t, x, y, z|
  assert_equal(@r.position(t.to_f), Rayz::Point.new(x: x.to_f, y: y.to_f, z: z.to_f))
end

Given('m ← translation\({float}, {float}, {float})') do |x, y, z|
  @m = Rayz::Transformations.translation(x: x, y: y, z: z)
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
  @m = Rayz::Transformations.scaling(x: x, y: y, z: z)
end
