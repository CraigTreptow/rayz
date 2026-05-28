require "option_parser"
require "json"
require "../src/rayz"

include Rayz

DEV_SCENES = {
  "tiny"   => {20, 10},
  "small"  => {40, 20},
  "medium" => {60, 30},
  "large"  => {100, 50},
}

PROD_SCENES = {
  "tiny"   => {200, 100},
  "small"  => {400, 200},
  "medium" => {600, 300},
  "large"  => {800, 400},
}

scenes = ENV["DEV_MODE"]? == "true" ? DEV_SCENES : PROD_SCENES

scene_name = ""
output_path = ""

OptionParser.parse do |opts|
  opts.on("--scene SCENE", "Scene to render (tiny/small/medium/large)") { |v| scene_name = v }
  opts.on("--output PATH", "Output PPM file path") { |v| output_path = v }
end

abort "--scene required" if scene_name.empty?
abort "--output required" if output_path.empty?
abort "Unknown scene: #{scene_name}. Valid: #{scenes.keys.join(", ")}" unless scenes.has_key?(scene_name)

width, height = scenes[scene_name]

world = World.new
world.light = PointLight.new(Point.new(-10.0, 10.0, -10.0), Color.new(1.0, 1.0, 1.0))

floor = Plane.new
floor.material.pattern = CheckersPattern.new(
  Color.new(0.15, 0.15, 0.15),
  Color.new(0.85, 0.85, 0.85)
)
floor.material.ambient = 0.2
floor.material.diffuse = 0.8
floor.material.specular = 0.0
floor.material.reflective = 0.3
world.objects << floor

glass_sph = Sphere.new
glass_sph.transform = Transformations.translation(x: -1.5, y: 1.0, z: 0.0)
glass_sph.material.color = Color.new(0.1, 0.1, 0.1)
glass_sph.material.ambient = 0.0
glass_sph.material.diffuse = 0.1
glass_sph.material.specular = 1.0
glass_sph.material.shininess = 300.0
glass_sph.material.transparency = 0.9
glass_sph.material.refractive_index = 1.5
glass_sph.material.reflective = 0.9
world.objects << glass_sph

mirror_sph = Sphere.new
mirror_sph.transform = Transformations.translation(x: 1.5, y: 1.0, z: 0.0)
mirror_sph.material.color = Color.new(0.9, 0.9, 0.9)
mirror_sph.material.specular = 1.0
mirror_sph.material.shininess = 300.0
mirror_sph.material.reflective = 0.8
world.objects << mirror_sph

matte_sph = Sphere.new
matte_sph.transform = Transformations.translation(x: 0.0, y: 1.0, z: 1.0)
matte_sph.material.color = Color.new(0.8, 0.3, 0.3)
world.objects << matte_sph

cyl = Cylinder.new
cyl.minimum = 0.0
cyl.maximum = 2.0
cyl.closed = true
cyl.transform = Transformations.translation(x: 0.0, y: 0.0, z: -1.0) *
                Transformations.scaling(x: 0.3, y: 0.5, z: 0.3)
cyl.material.color = Color.new(0.2, 0.6, 0.2)
cyl.material.specular = 0.3
world.objects << cyl

camera = Camera.new(width, height, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  from: Point.new(0.0, 1.5, -5.0),
  to: Point.new(0.0, 1.0, 0.0),
  up: Vector.new(0.0, 1.0, 0.0)
)

canvas = uninitialized Canvas
elapsed = Time.measure do
  canvas = camera.render(world)
  File.write(output_path, canvas.to_ppm)
end

secs = elapsed.total_seconds
pixels = width * height

puts({
  scene:             scene_name,
  width:             width,
  height:            height,
  elapsed:           secs.round(4),
  pixels_per_second: (pixels / secs).round(0).to_i,
}.to_json)
