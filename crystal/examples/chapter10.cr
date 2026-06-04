require "../src/rayz"

floor = Rayz::Plane.new
floor.material.reflective = 0.5
floor.material.pattern = Rayz::CheckersPattern.new(
  Rayz::Color.new(0.8, 0.8, 0.8),
  Rayz::Color.new(0.2, 0.2, 0.2)
)
floor.material.specular = 0.0

backdrop = Rayz::Plane.new
backdrop.transform =
  Rayz::Transformations.translation(0.0, 0.0, 6.0) *
    Rayz::Transformations.rotation_x(Math::PI / 2.0)
backdrop.material.pattern = Rayz::StripePattern.new(
  Rayz::Color.new(0.6, 0.6, 0.9),
  Rayz::Color.new(0.3, 0.3, 0.6)
)
backdrop.material.specular = 0.0

glass_ball = Rayz.glass_sphere
glass_ball.transform = Rayz::Transformations.translation(0.0, 1.0, 0.0)
glass_ball.material.color = Rayz::Color.new(0.1, 0.1, 0.1)
glass_ball.material.ambient = 0.1
glass_ball.material.diffuse = 0.1
glass_ball.material.specular = 1.0
glass_ball.material.shininess = 300.0
glass_ball.material.reflective = 1.0

mirror_ball = Rayz::Sphere.new
mirror_ball.transform =
  Rayz::Transformations.translation(-1.5, 0.5, -0.5) *
    Rayz::Transformations.scaling(0.5, 0.5, 0.5)
mirror_ball.material.color = Rayz::Color.new(0.9, 0.9, 0.9)
mirror_ball.material.diffuse = 0.1
mirror_ball.material.specular = 1.0
mirror_ball.material.shininess = 300.0
mirror_ball.material.reflective = 0.9

matte = Rayz::Sphere.new
matte.transform =
  Rayz::Transformations.translation(1.8, 0.5, -1.0) *
    Rayz::Transformations.scaling(0.5, 0.5, 0.5)
matte.material.color = Rayz::Color.new(1.0, 0.3, 0.1)
matte.material.diffuse = 0.9
matte.material.specular = 0.1

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-8.0, 8.0, -8.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << backdrop << glass_ball << mirror_ball << matte

camera = Rayz::Camera.new(200, 100, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -6.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with reflection and refraction..."
image = camera.render_parallel(world)
puts "done"

file_name = "examples/chapter10.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
