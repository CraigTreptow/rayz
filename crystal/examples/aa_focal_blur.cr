require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.9, 0.9, 0.9)
floor.material.specular = 0.0
world.objects << floor

near = Sphere.new
near.material.color = Color.new(1.0, 0.3, 0.3)
near.material.diffuse = 0.7
near.material.specular = 0.3
near.transform = Transformations.translation(-1.0, 0.5, -1.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << near

mid = Sphere.new
mid.material.color = Color.new(0.3, 1.0, 0.3)
mid.material.diffuse = 0.7
mid.material.specular = 0.3
mid.transform = Transformations.translation(0.0, 0.5, 1.5) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << mid

far_sphere = Sphere.new
far_sphere.material.color = Color.new(0.3, 0.3, 1.0)
far_sphere.material.diffuse = 0.7
far_sphere.material.specular = 0.3
far_sphere.transform = Transformations.translation(1.5, 0.5, 4.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << far_sphere

world.light = PointLight.new(Point.new(-5.0, 5.0, -5.0), Color.new(1.0, 1.0, 1.0))

# Focus on the middle sphere; near and far will blur
camera = Camera.new(
  400, 200, Math::PI / 3.0,
  samples_per_pixel: 16,
  aperture_size: 0.04,
  focal_distance: 2.5
)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 2.0, -4.0),
  Point.new(0.0, 0.5, 1.5),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)

file_name = "examples/aa_focal_blur.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
