require "../src/rayz"

canvas = Rayz::Canvas.new(400, 400)
white = Rayz::Color.new(1.0, 1.0, 1.0)

center_x = 200
center_y = 200
radius = 150.0

print "Placing clock hour marks..."
12.times do |hour|
  angle = hour * Math::PI / 6.0
  twelve = Rayz::Tuple.new(0.0, 0.0, radius, 1.0)
  rotated = Rayz::Transformations.rotation_y(angle) * twelve

  x = center_x + rotated.x.round.to_i
  y = center_y + rotated.z.round.to_i

  (-2..2).each do |dx|
    (-2..2).each do |dy|
      px = x + dx
      py = y + dy
      canvas.write_pixel(px, py, white) if px >= 0 && px < canvas.width && py >= 0 && py < canvas.height
    end
  end
end
puts "done"

file_name = "examples/chapter3.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
