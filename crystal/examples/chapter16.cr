require "../src/rayz"

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.1
floor.material.specular = 0.0

# Sphere with a cube carved out (difference)
carved = Rayz::CSG.new("difference",
  Rayz::Sphere.new,
  begin
    c = Rayz::Cube.new
    c.transform = Rayz::Transformations.scaling(0.7, 0.7, 0.7)
    c
  end
)
carved.transform = Rayz::Transformations.translation(-2.5, 1.0, 0.5)
carved.left.material.color = Rayz::Color.new(0.8, 0.2, 0.2)
carved.left.material.specular = 0.5
carved.right.material.color = Rayz::Color.new(0.2, 0.2, 0.8)

# Lens: intersection of two offset spheres
s_left = Rayz::Sphere.new
s_left.transform = Rayz::Transformations.translation(-0.3, 0.0, 0.0)
s_right = Rayz::Sphere.new
s_right.transform = Rayz::Transformations.translation(0.3, 0.0, 0.0)
lens = Rayz::CSG.new("intersection", s_left, s_right)
lens.transform = Rayz::Transformations.translation(0.0, 1.0, 0.0)
lens.left.material.color = Rayz::Color.new(0.9, 0.9, 0.2)
lens.left.material.reflective = 0.3
lens.right.material.color = Rayz::Color.new(0.9, 0.9, 0.2)
lens.right.material.reflective = 0.3

# Hollow sphere: sphere minus a slightly smaller sphere (union outer/inner surfaces)
outer = Rayz::Sphere.new
outer.material.color = Rayz::Color.new(0.2, 0.8, 0.4)
outer.material.transparency = 0.8
outer.material.refractive_index = 1.5
outer.material.reflective = 0.2
inner = Rayz::Sphere.new
inner.transform = Rayz::Transformations.scaling(0.8, 0.8, 0.8)
inner.material.color = Rayz::Color.new(0.2, 0.8, 0.4)
hollow = Rayz::CSG.new("difference", outer, inner)
hollow.transform = Rayz::Transformations.translation(2.5, 1.0, 0.5)

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << carved << lens << hollow

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 3.0, -6.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with CSG..."
image = camera.render(world)
puts "done"

file_name = "examples/chapter16.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
