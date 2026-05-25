require "../src/rayz"

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.3
floor.material.specular = 0.0

ceiling = Rayz::Plane.new
ceiling.transform = Rayz::Transformations.translation(0.0, 5.0, 0.0)
ceiling.material.color = Rayz::Color.new(0.9, 0.9, 0.9)
ceiling.material.specular = 0.0

left_wall = Rayz::Plane.new
left_wall.transform =
  Rayz::Transformations.translation(0.0, 0.0, 6.0) *
    Rayz::Transformations.rotation_x(Math::PI / 2.0)
left_wall.material.color = Rayz::Color.new(0.7, 0.2, 0.2)
left_wall.material.specular = 0.0

right_wall = Rayz::Plane.new
right_wall.transform =
  Rayz::Transformations.translation(5.0, 0.0, 0.0) *
    Rayz::Transformations.rotation_z(Math::PI / 2.0)
right_wall.material.color = Rayz::Color.new(0.2, 0.2, 0.7)
right_wall.material.specular = 0.0

table_top = Rayz::Cube.new
table_top.transform =
  Rayz::Transformations.translation(0.0, 1.0, 0.0) *
    Rayz::Transformations.scaling(1.5, 0.1, 0.8)
table_top.material.color = Rayz::Color.new(0.6, 0.4, 0.2)
table_top.material.diffuse = 0.7
table_top.material.specular = 0.3
table_top.material.shininess = 80.0
table_top.material.reflective = 0.2

leg1 = Rayz::Cube.new
leg1.transform =
  Rayz::Transformations.translation(1.3, 0.5, 0.6) *
    Rayz::Transformations.scaling(0.1, 0.5, 0.1)
leg1.material.color = Rayz::Color.new(0.5, 0.3, 0.1)

leg2 = Rayz::Cube.new
leg2.transform =
  Rayz::Transformations.translation(-1.3, 0.5, 0.6) *
    Rayz::Transformations.scaling(0.1, 0.5, 0.1)
leg2.material.color = Rayz::Color.new(0.5, 0.3, 0.1)

leg3 = Rayz::Cube.new
leg3.transform =
  Rayz::Transformations.translation(1.3, 0.5, -0.6) *
    Rayz::Transformations.scaling(0.1, 0.5, 0.1)
leg3.material.color = Rayz::Color.new(0.5, 0.3, 0.1)

leg4 = Rayz::Cube.new
leg4.transform =
  Rayz::Transformations.translation(-1.3, 0.5, -0.6) *
    Rayz::Transformations.scaling(0.1, 0.5, 0.1)
leg4.material.color = Rayz::Color.new(0.5, 0.3, 0.1)

glass_cube = Rayz::Cube.new
glass_cube.transform =
  Rayz::Transformations.translation(0.0, 1.3, 0.0) *
    Rayz::Transformations.rotation_y(Math::PI / 6.0) *
    Rayz::Transformations.scaling(0.35, 0.35, 0.35)
glass_cube.material.color = Rayz::Color.new(0.1, 0.1, 0.2)
glass_cube.material.ambient = 0.0
glass_cube.material.diffuse = 0.1
glass_cube.material.specular = 1.0
glass_cube.material.shininess = 300.0
glass_cube.material.reflective = 0.9
glass_cube.material.transparency = 0.9
glass_cube.material.refractive_index = 1.5

metal_cube = Rayz::Cube.new
metal_cube.transform =
  Rayz::Transformations.translation(-0.8, 1.2, -0.2) *
    Rayz::Transformations.rotation_y(-Math::PI / 5.0) *
    Rayz::Transformations.scaling(0.2, 0.2, 0.2)
metal_cube.material.color = Rayz::Color.new(0.8, 0.85, 0.9)
metal_cube.material.diffuse = 0.3
metal_cube.material.specular = 1.0
metal_cube.material.shininess = 200.0
metal_cube.material.reflective = 0.7

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-3.0, 5.0, -3.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << ceiling << left_wall << right_wall
world.objects << table_top << leg1 << leg2 << leg3 << leg4
world.objects << glass_cube << metal_cube

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -5.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with cubes..."
image = camera.render(world)
puts "done"

file_name = "examples/chapter11.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
