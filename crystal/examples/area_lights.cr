require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(1.0, 1.0, 1.0)
floor.material.ambient = 0.025
floor.material.diffuse = 0.67
floor.material.specular = 0.0
world.objects << floor

back_wall = Plane.new
back_wall.transform = Transformations.rotation_x(Math::PI / 2.0) * Transformations.translation(0.0, 0.0, -5.0)
back_wall.material = floor.material
world.objects << back_wall

red_sphere = Sphere.new
red_sphere.material.color = Color.new(1.0, 0.0, 0.0)
red_sphere.material.ambient = 0.1
red_sphere.material.diffuse = 0.6
red_sphere.material.specular = 0.0
red_sphere.transform = Transformations.translation(-1.0, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << red_sphere

blue_sphere = Sphere.new
blue_sphere.material.color = Color.new(0.0, 0.0, 1.0)
blue_sphere.material.ambient = 0.1
blue_sphere.material.diffuse = 0.6
blue_sphere.material.specular = 0.0
blue_sphere.transform = Transformations.translation(1.0, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << blue_sphere

# Area light for soft shadows
world.light = AreaLight.new(
  Point.new(-1.0, 2.0, -1.0),
  Vector.new(2.0, 0.0, 0.0),
  Vector.new(0.0, 0.0, 2.0),
  10, 10,
  Color.new(1.5, 1.5, 1.5),
  -> { rand - 0.5 }
)

camera = Camera.new(400, 200, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 2.0, -5.0),
  Point.new(0.0, 0.5, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)

file_name = "examples/area_lights.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
