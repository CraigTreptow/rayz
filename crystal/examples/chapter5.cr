require "../src/rayz"

canvas_size = 200
canvas = Rayz::Canvas.new(canvas_size, canvas_size)
red = Rayz::Color.new(1.0, 0.0, 0.0)

ray_origin = Rayz::Point.new(0.0, 0.0, -5.0)
wall_z = 10.0
wall_size = 7.0
pixel_size = wall_size / canvas_size
half = wall_size / 2.0

sphere = Rayz::Sphere.new

print "Casting rays..."
(0...canvas_size).each do |y|
  world_y = half - pixel_size * y
  (0...canvas_size).each do |x|
    world_x = -half + pixel_size * x
    target = Rayz::Point.new(world_x, world_y, wall_z)
    dir_t = (target - ray_origin).normalize
    ray = Rayz::Ray.new(ray_origin, Rayz::Vector.new(dir_t.x, dir_t.y, dir_t.z))
    canvas.write_pixel(x, canvas_size - 1 - y, red) unless sphere.intersect(ray).empty?
  end
end
puts "done"

file_name = "examples/chapter5.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
