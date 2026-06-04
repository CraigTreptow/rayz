require "../src/rayz"

def pyramid(color : Rayz::Color) : Rayz::Group
  apex = Rayz::Point.new(0.0, 1.0, 0.0)
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
    Rayz::Triangle.new(lf, rb, rf),
    Rayz::Triangle.new(lf, lb, rb),
  ].each do |tri|
    tri.material.color = color
    tri.material.diffuse = 0.8
    tri.material.specular = 0.3
    g.add_child(tri)
  end
  g
end

def octahedron(color : Rayz::Color) : Rayz::Group
  top = Rayz::Point.new(0.0, 1.0, 0.0)
  bot = Rayz::Point.new(0.0, -1.0, 0.0)
  rf = Rayz::Point.new(1.0, 0.0, 0.0)
  lf = Rayz::Point.new(-1.0, 0.0, 0.0)
  bk = Rayz::Point.new(0.0, 0.0, 1.0)
  fr = Rayz::Point.new(0.0, 0.0, -1.0)

  g = Rayz::Group.new
  [
    Rayz::Triangle.new(top, rf, fr),
    Rayz::Triangle.new(top, fr, lf),
    Rayz::Triangle.new(top, lf, bk),
    Rayz::Triangle.new(top, bk, rf),
    Rayz::Triangle.new(bot, fr, rf),
    Rayz::Triangle.new(bot, lf, fr),
    Rayz::Triangle.new(bot, bk, lf),
    Rayz::Triangle.new(bot, rf, bk),
  ].each do |tri|
    tri.material.color = color
    tri.material.diffuse = 0.8
    tri.material.specular = 0.3
    g.add_child(tri)
  end
  g
end

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(0.5, 0.5, 0.5)
floor.material.reflective = 0.1
floor.material.specular = 0.0

pyr = pyramid(Rayz::Color.new(0.8, 0.3, 0.1))
pyr.transform =
  Rayz::Transformations.translation(-1.8, 0.0, 0.0) *
    Rayz::Transformations.rotation_y(Math::PI / 6.0)

oct = octahedron(Rayz::Color.new(0.2, 0.5, 0.9))
oct.transform =
  Rayz::Transformations.translation(1.5, 1.0, 0.5) *
    Rayz::Transformations.rotation_y(-Math::PI / 5.0) *
    Rayz::Transformations.scaling(0.8, 0.8, 0.8)

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-5.0, 8.0, -5.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)
world.objects << floor << pyr << oct

camera = Rayz::Camera.new(200, 150, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 2.5, -5.0),
  Rayz::Point.new(0.0, 0.5, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

print "Rendering scene with triangles..."
image = camera.render_parallel(world)
puts "done"

file_name = "examples/chapter15.ppm"
print "Writing PPM to #{file_name}..."
File.write(file_name, image.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
