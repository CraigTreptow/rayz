require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.8, 0.8, 0.8)
floor.material.specular = 0.0
world.objects << floor

gold_torus = Torus.new(major_radius: 1.0, minor_radius: 0.3)
gold_torus.material.color = Color.new(0.8, 0.6, 0.1)
gold_torus.material.diffuse = 0.6
gold_torus.material.specular = 0.8
gold_torus.material.shininess = 300.0
gold_torus.material.reflective = 0.3
# Stand upright in XZ plane (rotate around X so ring faces camera)
gold_torus.transform = Transformations.translation(0.0, 1.0, 0.0) *
                       Transformations.rotation_x(Math::PI / 2.0)
world.objects << gold_torus

glass_torus = Torus.new(major_radius: 0.5, minor_radius: 0.15)
glass_torus.material.color = Color.new(0.3, 0.5, 0.8)
glass_torus.material.diffuse = 0.1
glass_torus.material.specular = 0.9
glass_torus.material.shininess = 400.0
glass_torus.material.reflective = 0.5
glass_torus.material.transparency = 0.6
glass_torus.material.refractive_index = 1.5
glass_torus.transform = Transformations.translation(2.5, 0.6, 1.0) *
                        Transformations.rotation_x(Math::PI / 3.0) *
                        Transformations.rotation_y(Math::PI / 6.0)
world.objects << glass_torus

world.light = PointLight.new(Point.new(-5.0, 8.0, -5.0), Color.new(1.0, 1.0, 1.0))

camera = Camera.new(400, 200, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 3.5, -6.0),
  Point.new(0.0, 1.0, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render_parallel(world)

file_name = "examples/torus.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
