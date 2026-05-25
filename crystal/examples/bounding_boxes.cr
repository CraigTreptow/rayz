require "../src/rayz"

include Rayz

def make_marble : Group
  g = Group.new
  s = Sphere.new
  s.material.color = Color.new(rand, rand, rand)
  s.material.diffuse = 0.7
  s.material.specular = 0.3
  s.transform = Transformations.translation(
    rand(-0.3..0.3),
    rand(-0.3..0.3),
    rand(-0.3..0.3)
  ) * Transformations.scaling(0.15, 0.15, 0.15)
  g.add_child(s)
  g
end

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.8, 0.8, 0.8)
floor.material.specular = 0.0
world.objects << floor

marbles = Group.new
11.times do |x|
  11.times do |z|
    marble = make_marble
    marble.transform = Transformations.translation(x - 5.0, 0.15, z - 5.0)
    marbles.add_child(marble)
  end
end
world.objects << marbles

world.light = PointLight.new(Point.new(-5.0, 10.0, -5.0), Color.new(1.0, 1.0, 1.0))

camera = Camera.new(400, 200, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 3.5, -9.0),
  Point.new(0.0, 0.5, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)
puts canvas.to_ppm
