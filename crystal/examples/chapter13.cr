require "../src/rayz"

def hexagon_corner
  corner = Rayz::Sphere.new
  corner.transform =
    Rayz::Transformations.translation(0.0, 0.0, -1.0) *
      Rayz::Transformations.scaling(0.25, 0.25, 0.25)
  corner
end

def hexagon_edge
  edge = Rayz::Cylinder.new
  edge.minimum = 0.0
  edge.maximum = 1.0
  edge.transform =
    Rayz::Transformations.translation(0.0, 0.0, -1.0) *
      Rayz::Transformations.rotation_y(-Math::PI / 6.0) *
      Rayz::Transformations.rotation_z(-Math::PI / 2.0) *
      Rayz::Transformations.scaling(0.25, 1.0, 0.25)
  edge
end

def hexagon_side(n : Int32)
  side = Rayz::Group.new
  side.transform = Rayz::Transformations.rotation_y(n * Math::PI / 3.0)
  side.add_child(hexagon_corner)
  side.add_child(hexagon_edge)
  side
end

def hexagon
  hex = Rayz::Group.new
  6.times { |n| hex.add_child(hexagon_side(n)) }
  hex
end

hex = hexagon
hex.transform =
  Rayz::Transformations.translation(0.0, 1.0, 0.0) *
    Rayz::Transformations.rotation_x(-Math::PI / 6.0)

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.4, 0.4, 0.4)
floor.material.reflective = 0.2
floor.material.specular = 0.0

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << hex

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -5.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with groups..."
image = camera.render_parallel(world)
puts "done"

file_name = "examples/chapter13.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
