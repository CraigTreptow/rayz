require "../src/rayz"

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.1
floor.material.specular = 0.0

traffic_cone = Rayz::Group.new
traffic_cone.transform = Rayz::Transformations.translation(-2.0, 0.0, 0.5)

cone_body = Rayz::Cone.new
cone_body.minimum = -1.0
cone_body.maximum = 0.0
cone_body.closed = false
cone_body.transform =
  Rayz::Transformations.translation(0.0, 1.0, 0.0) *
    Rayz::Transformations.scaling(0.4, 1.0, 0.4)
cone_body.material.color = Rayz::Color.new(1.0, 0.4, 0.0)
cone_body.material.diffuse = 0.9
cone_body.material.specular = 0.3

cone_base = Rayz::Cylinder.new
cone_base.minimum = 0.0
cone_base.maximum = 0.12
cone_base.closed = true
cone_base.transform = Rayz::Transformations.scaling(0.5, 1.0, 0.5)
cone_base.material.color = Rayz::Color.new(0.8, 0.3, 0.0)

traffic_cone.add_child(cone_body)
traffic_cone.add_child(cone_base)

glass_cone = Rayz::Cone.new
glass_cone.minimum = 0.0
glass_cone.maximum = 1.0
glass_cone.closed = true
glass_cone.transform =
  Rayz::Transformations.translation(0.3, 0.0, 0.5) *
    Rayz::Transformations.scaling(0.5, 1.2, 0.5)
glass_cone.material.color = Rayz::Color.new(0.1, 0.2, 0.4)
glass_cone.material.ambient = 0.05
glass_cone.material.diffuse = 0.1
glass_cone.material.specular = 1.0
glass_cone.material.shininess = 300.0
glass_cone.material.reflective = 0.8
glass_cone.material.transparency = 0.7
glass_cone.material.refractive_index = 1.5

metal_cone = Rayz::Cone.new
metal_cone.minimum = -1.5
metal_cone.maximum = 0.0
metal_cone.closed = false
metal_cone.transform =
  Rayz::Transformations.translation(2.2, 0.0, 0.3) *
    Rayz::Transformations.rotation_x(Math::PI) *
    Rayz::Transformations.scaling(0.6, 1.0, 0.6)
metal_cone.material.color = Rayz::Color.new(0.8, 0.8, 0.9)
metal_cone.material.diffuse = 0.3
metal_cone.material.specular = 1.0
metal_cone.material.shininess = 200.0
metal_cone.material.reflective = 0.8

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << traffic_cone << glass_cone << metal_cone

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 3.0, -6.0),
  Rayz::Point.new(0.0, 0.5, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with cones..."
image = camera.render(world)
puts "done"

file_name = "examples/chapter14.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
