require "../src/rayz"

canvas_size = 200
canvas = Rayz::Canvas.new(canvas_size, canvas_size)

sphere = Rayz::Sphere.new
sphere.material.color = Rayz::Color.new(1.0, 0.2, 1.0)

light = Rayz::PointLight.new(
  Rayz::Point.new(-10.0, 10.0, -10.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)

ray_origin = Rayz::Point.new(0.0, 0.0, -5.0)
wall_z = 10.0
wall_size = 7.0
pixel_size = wall_size / canvas_size
half = wall_size / 2.0

print "Rendering shaded sphere..."
(0...canvas_size).each do |y|
  world_y = half - pixel_size * y
  (0...canvas_size).each do |x|
    world_x = -half + pixel_size * x
    target = Rayz::Point.new(world_x, world_y, wall_z)
    dir_t = (target - ray_origin).normalize
    ray = Rayz::Ray.new(ray_origin, Rayz::Vector.new(dir_t.x, dir_t.y, dir_t.z))

    xs = sphere.intersect(ray)
    hit = Rayz.hit(xs)
    next unless hit

    point_t = ray.position(hit.t)
    point = Rayz::Point.new(point_t.x, point_t.y, point_t.z)
    normal = hit.object.normal_at(point)
    eyev = Rayz::Vector.new(-ray.direction.x, -ray.direction.y, -ray.direction.z)

    color = Rayz.lighting(hit.object.material, light, point, eyev, normal)
    canvas.write_pixel(x, y, color)
  end
end
puts "done"

file_name = "examples/chapter6.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
