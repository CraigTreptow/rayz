require "../src/rayz"

canvas_size = 200
canvas = Rayz::Canvas.new(canvas_size, canvas_size)
red = Rayz::Color.new(1.0, 0.0, 0.0)

ray_origin = Rayz::Point.new(0.0, 0.0, -5.0)
wall_z = 10.0
wall_size = 7.0
pixel_size = wall_size / canvas_size
half = wall_size / 2.0

print "Casting rays..."
(0...canvas_size).each do |y|
  world_y = half - pixel_size * y
  (0...canvas_size).each do |x|
    world_x = -half + pixel_size * x
    target = Rayz::Tuple.new(world_x, world_y, wall_z, 1.0)
    dir_t = (target - ray_origin).normalize
    ray = Rayz::Ray.new(ray_origin, Rayz::Vector.new(dir_t.x, dir_t.y, dir_t.z))

    # Unit sphere at origin — manual intersection math
    sphere_to_ray = Rayz::Tuple.new(
      ray.origin.x, ray.origin.y, ray.origin.z, 0.0
    )
    a = ray.direction.dot(ray.direction)
    b = 2.0 * ray.direction.dot(sphere_to_ray)
    c = sphere_to_ray.dot(sphere_to_ray) - 1.0
    discriminant = b * b - 4.0 * a * c

    canvas.write_pixel(x, y, red) if discriminant >= 0.0
  end
end
puts "done"

file_name = "examples/chapter4.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
