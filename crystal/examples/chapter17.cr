require "../src/rayz"

def flat_pyramid(color : Rayz::Color) : Rayz::Group
  apex = Rayz::Point.new(0.0, 1.5, 0.0)
  lf = Rayz::Point.new(-1.0, 0.0, -1.0)
  rf = Rayz::Point.new(1.0, 0.0, -1.0)
  rb = Rayz::Point.new(1.0, 0.0, 1.0)
  lb = Rayz::Point.new(-1.0, 0.0, 1.0)

  g = Rayz::Group.new
  [
    Rayz::Triangle.new(apex, lf, rf),
    Rayz::Triangle.new(apex, rf, rb),
    Rayz::Triangle.new(apex, rb, lb),
    Rayz::Triangle.new(apex, lb, lf),
  ].each do |tri|
    tri.material.color = color
    tri.material.diffuse = 0.9
    tri.material.specular = 0.1
    g.add_child(tri)
  end
  g
end

def smooth_pyramid(color : Rayz::Color) : Rayz::Group
  apex = Rayz::Point.new(0.0, 1.5, 0.0)
  lf = Rayz::Point.new(-1.0, 0.0, -1.0)
  rf = Rayz::Point.new(1.0, 0.0, -1.0)
  rb = Rayz::Point.new(1.0, 0.0, 1.0)
  lb = Rayz::Point.new(-1.0, 0.0, 1.0)

  n_apex = Rayz::Vector.new(0.0, 1.0, 0.0)
  n_lf = Rayz::Vector.new(-0.7071, -0.5, -0.5)
  n_rf = Rayz::Vector.new(0.7071, -0.5, -0.5)
  n_rb = Rayz::Vector.new(0.7071, -0.5, 0.5)
  n_lb = Rayz::Vector.new(-0.7071, -0.5, 0.5)

  g = Rayz::Group.new
  [
    Rayz::SmoothTriangle.new(apex, lf, rf, n_apex, n_lf, n_rf),
    Rayz::SmoothTriangle.new(apex, rf, rb, n_apex, n_rf, n_rb),
    Rayz::SmoothTriangle.new(apex, rb, lb, n_apex, n_rb, n_lb),
    Rayz::SmoothTriangle.new(apex, lb, lf, n_apex, n_lb, n_lf),
  ].each do |tri|
    tri.material.color = color
    tri.material.diffuse = 0.9
    tri.material.specular = 0.1
    g.add_child(tri)
  end
  g
end

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.specular = 0.0

flat = flat_pyramid(Rayz::Color.new(0.8, 0.3, 0.1))
flat.transform = Rayz::Transformations.translation(-2.2, 0.0, 0.0)

smooth = smooth_pyramid(Rayz::Color.new(0.1, 0.4, 0.8))
smooth.transform = Rayz::Transformations.translation(2.2, 0.0, 0.0)

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << flat << smooth

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 3.0, -6.0),
  Rayz::Point.new(0.0, 0.75, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with smooth triangles..."
image = camera.render_parallel(world)
puts "done"

file_name = "examples/chapter17.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
