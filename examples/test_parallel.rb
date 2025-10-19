#!/usr/bin/env ruby
require_relative "../lib/rayz"

puts "Testing Ractor-based parallel rendering..."
puts "=" * 60

# Create a tiny test scene
camera = Rayz::Camera.new(hsize: 50, vsize: 25, field_of_view: Math::PI / 3)
camera.transform = Rayz::Transformations.view_transform(
  from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
  to: Rayz::Point.new(x: 0, y: 1, z: 0),
  up: Rayz::Vector.new(x: 0, y: 1, z: 0)
)

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  position: Rayz::Point.new(x: -10, y: 10, z: -10),
  intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
)

floor = Rayz::Plane.new
floor.material.color = Rayz::Color.new(red: 1, green: 0.9, blue: 0.9)

sphere = Rayz::Sphere.new
sphere.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 0)
sphere.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)

world.objects << floor << sphere

puts "\n1. Testing SEQUENTIAL rendering:"
start = Time.now
image1 = camera.render(world, parallel: false)
sequential_time = Time.now - start
puts "Sequential: #{sequential_time.round(2)}s"

puts "\n2. Testing PARALLEL rendering (Ractor):"
start = Time.now
image2 = camera.render(world, parallel: true)
parallel_time = Time.now - start
puts "Parallel: #{parallel_time.round(2)}s"

speedup = sequential_time / parallel_time
puts "\n" + "=" * 60
puts "RESULTS:"
puts "  Sequential: #{sequential_time.round(2)}s"
puts "  Parallel:   #{parallel_time.round(2)}s"
puts "  Speedup:    #{speedup.round(2)}x"
puts "=" * 60

if speedup > 1.0
  puts "✅ Parallel rendering is #{((speedup - 1) * 100).round(0)}% faster!"
else
  puts "⚠️  Parallel rendering is slower (overhead too high for tiny scene)"
end
