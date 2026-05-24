require "../src/rayz"

floor = Rayz::Sphere.new
floor.transform = Rayz::Transformations.scaling(10.0, 0.01, 10.0)
floor.material.color = Rayz::Color.new(1.0, 0.9, 0.9)
floor.material.specular = 0.0

left_wall = Rayz::Sphere.new
left_wall.transform =
  Rayz::Transformations.translation(0.0, 0.0, 5.0) *
  Rayz::Transformations.rotation_y(-Math::PI / 4.0) *
  Rayz::Transformations.rotation_x(Math::PI / 2.0) *
  Rayz::Transformations.scaling(10.0, 0.01, 10.0)
left_wall.material = floor.material

right_wall = Rayz::Sphere.new
right_wall.transform =
  Rayz::Transformations.translation(0.0, 0.0, 5.0) *
  Rayz::Transformations.rotation_y(Math::PI / 4.0) *
  Rayz::Transformations.rotation_x(Math::PI / 2.0) *
  Rayz::Transformations.scaling(10.0, 0.01, 10.0)
right_wall.material = floor.material

middle = Rayz::Sphere.new
middle.transform = Rayz::Transformations.translation(-0.5, 1.0, 0.5)
middle.material.color = Rayz::Color.new(0.1, 1.0, 0.5)
middle.material.diffuse = 0.7
middle.material.specular = 0.3

right = Rayz::Sphere.new
right.transform =
  Rayz::Transformations.translation(1.5, 0.5, -0.5) *
  Rayz::Transformations.scaling(0.5, 0.5, 0.5)
right.material.color = Rayz::Color.new(0.5, 1.0, 0.1)
right.material.diffuse = 0.7
right.material.specular = 0.3

left = Rayz::Sphere.new
left.transform =
  Rayz::Transformations.translation(-1.5, 0.33, -0.75) *
  Rayz::Transformations.scaling(0.33, 0.33, 0.33)
left.material.color = Rayz::Color.new(1.0, 0.8, 0.1)
left.material.diffuse = 0.7
left.material.specular = 0.3

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-10.0, 10.0, -10.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << left_wall << right_wall << middle << right << left

camera = Rayz::Camera.new(200, 100, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 1.5, -5.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with world and camera..."
image = camera.render(world)
puts "done"

file_name = "examples/chapter7.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
