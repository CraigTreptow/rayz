require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.8, 0.8, 0.8)
floor.material.specular = 0.0
floor.material.ambient = 0.05
world.objects << floor

back_wall = Plane.new
back_wall.transform = Transformations.rotation_x(Math::PI / 2.0) * Transformations.translation(0.0, 0.0, 5.0)
back_wall.material = floor.material
world.objects << back_wall

red = Sphere.new
red.material.color = Color.new(1.0, 0.2, 0.2)
red.material.ambient = 0.05
red.transform = Transformations.translation(-1.5, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << red

white_sphere = Sphere.new
white_sphere.material.color = Color.new(1.0, 1.0, 1.0)
white_sphere.material.ambient = 0.05
white_sphere.transform = Transformations.translation(0.0, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << white_sphere

blue = Sphere.new
blue.material.color = Color.new(0.2, 0.2, 1.0)
blue.material.ambient = 0.05
blue.transform = Transformations.translation(1.5, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << blue

# Spotlight aimed at the center sphere with a soft fade edge
world.light = Spotlight.new(
  Point.new(0.0, 6.0, -3.0),
  Color.new(1.5, 1.5, 1.5),
  Vector.new(0.0, -1.0, 0.5),
  Math::PI / 8.0, # outer cone: 22.5°
  Math::PI / 16.0 # inner cone: 11.25°
)

camera = Camera.new(400, 200, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 3.0, -5.0),
  Point.new(0.0, 0.5, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)

file_name = "examples/spotlight.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
