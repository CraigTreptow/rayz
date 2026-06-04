#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"
require "benchmark"
require_relative "../lib/rayz"

DEV_SCENES = {
  "small" => {width: 40, height: 20},
  "medium" => {width: 60, height: 30},
  "large" => {width: 100, height: 50}
}.freeze

PROD_SCENES = {
  "small" => {width: 400, height: 200},
  "medium" => {width: 600, height: 300},
  "large" => {width: 800, height: 400}
}.freeze

SCENES = (ENV["DEV_MODE"] == "true") ? DEV_SCENES : PROD_SCENES

options = {parallel: false}
OptionParser.new do |opts|
  opts.on("--scene SCENE") { |v| options[:scene] = v }
  opts.on("--output PATH") { |v| options[:output] = v }
  opts.on("--parallel VALUE") do |v|
    options[:parallel] = (v == "true")
  end
end.parse!

scene_name = options[:scene] || abort("--scene required")
output_path = options[:output] || abort("--output required")
parallel = options[:parallel]

abort "Unknown scene: #{scene_name}. Valid: #{SCENES.keys.join(", ")}" unless SCENES.key?(scene_name)

dims = SCENES[scene_name]

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  position: Rayz::Point.new(x: -10, y: 10, z: -10),
  intensity: Rayz::Color.new(red: 1, green: 1, blue: 1)
)

floor = Rayz::Plane.new
floor.material.pattern = Rayz::CheckersPattern.new(
  a: Rayz::Color.new(red: 0.15, green: 0.15, blue: 0.15),
  b: Rayz::Color.new(red: 0.85, green: 0.85, blue: 0.85)
)
floor.material.ambient = 0.2
floor.material.diffuse = 0.8
floor.material.specular = 0
floor.material.reflective = 0.3
world.objects << floor

glass_sph = Rayz::Sphere.new
glass_sph.transform = Rayz::Transformations.translation(x: -1.5, y: 1, z: 0)
glass_sph.material.color = Rayz::Color.new(red: 0.1, green: 0.1, blue: 0.1)
glass_sph.material.ambient = 0
glass_sph.material.diffuse = 0.1
glass_sph.material.specular = 1.0
glass_sph.material.shininess = 300
glass_sph.material.transparency = 0.9
glass_sph.material.refractive_index = 1.5
glass_sph.material.reflective = 0.9
world.objects << glass_sph

mirror_sph = Rayz::Sphere.new
mirror_sph.transform = Rayz::Transformations.translation(x: 1.5, y: 1, z: 0)
mirror_sph.material.color = Rayz::Color.new(red: 0.9, green: 0.9, blue: 0.9)
mirror_sph.material.specular = 1.0
mirror_sph.material.shininess = 300
mirror_sph.material.reflective = 0.8
world.objects << mirror_sph

matte_sph = Rayz::Sphere.new
matte_sph.transform = Rayz::Transformations.translation(x: 0, y: 1, z: 1)
matte_sph.material.color = Rayz::Color.new(red: 0.8, green: 0.3, blue: 0.3)
world.objects << matte_sph

cyl = Rayz::Cylinder.new
cyl.minimum = 0
cyl.maximum = 2
cyl.closed = true
cyl.transform = Rayz::Transformations.translation(x: 0, y: 0, z: -1) *
  Rayz::Transformations.scaling(x: 0.3, y: 0.5, z: 0.3)
cyl.material.color = Rayz::Color.new(red: 0.2, green: 0.6, blue: 0.2)
cyl.material.specular = 0.3
world.objects << cyl

camera = Rayz::Camera.new(hsize: dims[:width], vsize: dims[:height], field_of_view: Math::PI / 3)
camera.transform = Rayz::Transformations.view_transform(
  from: Rayz::Point.new(x: 0, y: 1.5, z: -5),
  to: Rayz::Point.new(x: 0, y: 1, z: 0),
  up: Rayz::Vector.new(x: 0, y: 1, z: 0)
)

canvas = nil
elapsed = Benchmark.realtime do
  $stdout = $stderr
  begin
    canvas = camera.render(world, parallel: parallel)
  ensure
    $stdout = STDOUT
  end
  File.write(output_path, canvas.to_ppm)
end

puts JSON.generate(
  scene: scene_name,
  width: dims[:width],
  height: dims[:height],
  elapsed: elapsed.round(4),
  pixels_per_second: (dims[:width] * dims[:height] / elapsed).round(0)
)
