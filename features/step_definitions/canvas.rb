Given('canvas ← canvas\({int}, {int})') do |int, int2|
  @canvas = Rayz::Canvas.new(width: int, height: int2)
end

Then("canvas.width = {int}") do |int|
  assert_equal(@canvas.width, int)
end

Then("canvas.height = {int}") do |int|
  assert_equal(@canvas.height, int)
end

Then('every pixel of canvas is color\({float}, {float}, {float})') do |float, float2, float3|
  expected_color = Rayz::Color.new(red: float, green: float2, blue: float3)

  (0..@canvas.height - 1).to_a.reverse_each do |r|
    (0..@canvas.width - 1).each do |c|
      assert_equal(@canvas.pixels[r][c], expected_color)
    end
  end
end

Given('red ← color\({float}, {float}, {float})') do |float, float2, float3|
  @red = Rayz::Color.new(red: float, green: float2, blue: float3)
end

When('write_pixel\(canvas, {int}, {int}, red)') do |int, int2|
  @canvas.write_pixel(col: int, row: int2, color: @red)
end

When('write_pixel\(canvas, {int}, {int}, color1)') do |int, int2|
  @canvas.write_pixel(col: int, row: int2, color: @color1)
end

When('write_pixel\(canvas, {int}, {int}, color2)') do |int, int2|
  @canvas.write_pixel(col: int, row: int2, color: @color2)
end

When('write_pixel\(canvas, {int}, {int}, color3)') do |int, int2|
  @canvas.write_pixel(col: int, row: int2, color: @color3)
end

Then('pixel_at\(canvas, {int}, {int}) = red') do |int, int2|
  color = @canvas.pixel_at(row: int, col: int2)
  assert_equal(color, @red)
end

When('ppm ← canvas_to_ppm\(canvas)') do
  @ppm = @canvas.to_ppm
end

Then("lines 1-3 of ppm are") do |doc_string|
  ppm_lines = @ppm.split("\n")[0..2]
  doc_lines = doc_string.split("\n")
  (0..ppm_lines.length - 1).each do |idx|
    assert_equal(ppm_lines[idx], doc_lines[idx])
  end
end

Then("lines 4-6 of ppm are") do |doc_string|
  low = 3
  ppm_lines = @ppm.split("\n")[low..]
  doc_lines = doc_string.split("\n")
  (0..ppm_lines.length - 1).each do |idx|
    assert_equal(ppm_lines[idx], doc_lines[idx])
  end
end

Then("ppm ends with a newline character") do
  assert_equal(@ppm.end_with?("\n"), true)
end
