require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.8, 0.8, 0.8)
floor.material.specular = 0.0
world.objects << floor

# Static sphere for reference
static = Sphere.new
static.material.color = Color.new(0.3, 0.8, 0.3)
static.material.specular = 0.4
static.transform = Transformations.translation(-2.0, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
world.objects << static

# Moving sphere: sweeps from x=-0.5 to x=1.5 over the exposure
moving = Sphere.new
moving.material.color = Color.new(0.8, 0.3, 0.3)
moving.material.specular = 0.4
moving.transform = Transformations.scaling(0.5, 0.5, 0.5)
moving.motion_transform = ->(t : Float64) {
  Transformations.translation(-0.5 + t * 2.0, 0.5, 0.0)
}
world.objects << moving

# Fast-spinning sphere
spinning = Sphere.new
spinning.material.color = Color.new(0.3, 0.3, 0.9)
spinning.material.specular = 0.4
spinning.transform = Transformations.translation(2.5, 0.5, 0.0) * Transformations.scaling(0.5, 0.5, 0.5)
spinning.motion_transform = ->(t : Float64) {
  Transformations.rotation_y(t * Math::PI * 4.0)
}
world.objects << spinning

world.light = PointLight.new(Point.new(-5.0, 8.0, -5.0), Color.new(1.0, 1.0, 1.0))

camera = Camera.new(
  400, 200, Math::PI / 3.0,
  samples_per_pixel: 16,
  motion_blur: true
)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 3.0, -6.0),
  Point.new(0.0, 0.5, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render_parallel(world)

file_name = "examples/motion_blur.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
