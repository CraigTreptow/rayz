require "../src/rayz"

obj_content = File.read("examples/tetrahedron.obj")
parser = Rayz.parse_obj_file(obj_content)
model = Rayz.obj_to_group(parser)
model.transform =
  Rayz::Transformations.translation(0.0, 0.5, 0.0) *
    Rayz::Transformations.rotation_y(Math::PI / 6.0) *
    Rayz::Transformations.scaling(1.2, 1.2, 1.2)

model.children.each do |child|
  child.material.color = Rayz::Color.new(0.3, 0.6, 0.9)
  child.material.diffuse = 0.8
  child.material.specular = 0.4
  child.material.shininess = 50.0
end

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.1
floor.material.specular = 0.0

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << model

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -5.0),
  Rayz::Point.new(0.0, 0.5, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering OBJ parser demo..."
image = camera.render_parallel(world)
puts "done"

file_name = "examples/obj_parser.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
