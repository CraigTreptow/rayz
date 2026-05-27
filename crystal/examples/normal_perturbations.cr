require "../src/rayz"

include Rayz

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.8, 0.8, 0.8)
floor.material.specular = 0.0
world.objects << floor

sine = Sphere.new
sine.material.color = Color.new(0.8, 0.3, 0.3)
sine.material.specular = 0.3
sine.material.normal_perturbation = NormalPerturbations.sine_wave(frequency: 12.0, amplitude: 0.15)
sine.transform = Transformations.translation(-2.5, 1.0, 0.0)
world.objects << sine

quilted = Sphere.new
quilted.material.color = Color.new(0.3, 0.7, 0.3)
quilted.material.specular = 0.3
quilted.material.normal_perturbation = NormalPerturbations.quilted(frequency: 6.0, amplitude: 0.2)
quilted.transform = Transformations.translation(0.0, 1.0, 0.0)
world.objects << quilted

noisy = Sphere.new
noisy.material.color = Color.new(0.3, 0.3, 0.9)
noisy.material.specular = 0.3
noisy.material.normal_perturbation = NormalPerturbations.noise(frequency: 8.0, amplitude: 0.15)
noisy.transform = Transformations.translation(2.5, 1.0, 0.0)
world.objects << noisy

rippled = Sphere.new
rippled.material.color = Color.new(0.8, 0.7, 0.2)
rippled.material.specular = 0.3
rippled.material.normal_perturbation = NormalPerturbations.ripples(frequency: 14.0, amplitude: 0.12)
rippled.transform = Transformations.translation(0.0, 1.0, 3.0)
world.objects << rippled

world.light = PointLight.new(Point.new(-5.0, 8.0, -5.0), Color.new(1.0, 1.0, 1.0))

camera = Camera.new(500, 250, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 4.0, -8.0),
  Point.new(0.0, 1.0, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)

file_name = "examples/normal_perturbations.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
