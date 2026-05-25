require "../src/rayz"

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.2
floor.material.specular = 0.0

backdrop = Rayz::Plane.new
backdrop.transform =
  Rayz::Transformations.translation(0.0, 0.0, 6.0) *
    Rayz::Transformations.rotation_x(Math::PI / 2.0)
backdrop.material.color = Rayz::Color.new(0.8, 0.8, 0.9)
backdrop.material.specular = 0.0

table_top = Rayz::Cube.new
table_top.transform =
  Rayz::Transformations.translation(0.0, 0.85, 0.0) *
    Rayz::Transformations.scaling(2.0, 0.1, 1.2)
table_top.material.color = Rayz::Color.new(0.5, 0.35, 0.15)
table_top.material.diffuse = 0.7
table_top.material.specular = 0.3
table_top.material.reflective = 0.1

candle1 = Rayz::Cylinder.new
candle1.minimum = 0.0
candle1.maximum = 1.0
candle1.closed = true
candle1.transform =
  Rayz::Transformations.translation(-0.8, 0.95, 0.0) *
    Rayz::Transformations.scaling(0.1, 0.8, 0.1)
candle1.material.color = Rayz::Color.new(1.0, 0.9, 0.7)
candle1.material.ambient = 0.2
candle1.material.diffuse = 0.7
candle1.material.specular = 0.3

candle2 = Rayz::Cylinder.new
candle2.minimum = 0.0
candle2.maximum = 1.0
candle2.closed = true
candle2.transform =
  Rayz::Transformations.translation(0.8, 0.95, 0.3) *
    Rayz::Transformations.scaling(0.15, 0.5, 0.15)
candle2.material.color = Rayz::Color.new(0.9, 0.8, 1.0)
candle2.material.ambient = 0.2
candle2.material.diffuse = 0.7
candle2.material.specular = 0.3

vase = Rayz::Cylinder.new
vase.minimum = 0.0
vase.maximum = 1.0
vase.closed = false
vase.transform =
  Rayz::Transformations.translation(0.0, 0.95, -0.3) *
    Rayz::Transformations.scaling(0.25, 0.6, 0.25)
vase.material.color = Rayz::Color.new(0.2, 0.5, 0.8)
vase.material.diffuse = 0.3
vase.material.specular = 1.0
vase.material.shininess = 300.0
vase.material.transparency = 0.6
vase.material.refractive_index = 1.5
vase.material.reflective = 0.5

open_tube = Rayz::Cylinder.new
open_tube.minimum = 0.0
open_tube.maximum = 1.0
open_tube.closed = false
open_tube.transform =
  Rayz::Transformations.translation(0.0, 0.95, 0.5) *
    Rayz::Transformations.rotation_x(Math::PI / 6.0) *
    Rayz::Transformations.scaling(0.08, 0.4, 0.08)
open_tube.material.color = Rayz::Color.new(0.7, 0.7, 0.7)
open_tube.material.diffuse = 0.3
open_tube.material.specular = 1.0
open_tube.material.shininess = 200.0
open_tube.material.reflective = 0.6

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-3.0, 6.0, -4.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << backdrop << table_top
world.objects << candle1 << candle2 << vase << open_tube

camera = Rayz::Camera.new(200, 150, Math::PI / 3.5)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -5.0),
  Rayz::Point.new(0.0, 0.9, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with cylinders..."
image = camera.render(world)
puts "done"

file_name = "examples/chapter12.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
