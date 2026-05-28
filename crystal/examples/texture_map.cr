require "../src/rayz"

include Rayz

# Build a checkerboard PPM image programmatically
def checkerboard(width : Int32, height : Int32, checks : Int32) : PPMImage
  img = PPMImage.new(width, height)
  cell_w = width / checks
  cell_h = height / checks
  white = Color.new(1.0, 1.0, 1.0)
  black = Color.new(0.1, 0.1, 0.1)
  height.times do |y|
    width.times do |x|
      cx = x / cell_w
      cy = y / cell_h
      color = (cx + cy) % 2 == 0 ? white : black
      img.set_pixel(x, y, color)
    end
  end
  img
end

world = World.new

floor = Plane.new
floor.material.color = Color.new(0.6, 0.6, 0.6)
floor.material.specular = 0.0
world.objects << floor

# Sphere with spherical texture mapping
check_img = checkerboard(64, 32, 8)
sphere_tm = TextureMap.new(check_img, TextureMap.spherical_map)

sphere = Sphere.new
sphere.material.pattern = sphere_tm
sphere.material.specular = 0.3
sphere.transform = Transformations.translation(-1.5, 1.0, 0.0)
world.objects << sphere

# Cylinder with cylindrical texture mapping
cyl_img = checkerboard(32, 16, 4)
cyl_tm = TextureMap.new(cyl_img, TextureMap.cylindrical_map)

cyl = Cylinder.new
cyl.minimum = 0.0
cyl.maximum = 2.0
cyl.closed = true
cyl.material.pattern = cyl_tm
cyl.material.specular = 0.2
cyl.transform = Transformations.translation(1.5, 0.0, 0.5)
world.objects << cyl

# Plane on the back wall with planar texture mapping
wall_img = checkerboard(16, 16, 4)
wall_tm = TextureMap.new(wall_img, TextureMap.planar_map)

back_wall = Plane.new
back_wall.transform = Transformations.translation(0.0, 0.0, 4.0) *
                      Transformations.rotation_x(Math::PI / 2.0)
back_wall.material.pattern = wall_tm
back_wall.material.specular = 0.0
world.objects << back_wall

world.light = PointLight.new(Point.new(-5.0, 8.0, -5.0), Color.new(1.0, 1.0, 1.0))

camera = Camera.new(400, 200, Math::PI / 3.0)
camera.transform = Transformations.view_transform(
  Point.new(0.0, 3.0, -6.0),
  Point.new(0.0, 1.0, 0.0),
  Vector.new(0.0, 1.0, 0.0)
)

canvas = camera.render(world)

file_name = "examples/texture_map.ppm"
File.write(file_name, canvas.to_ppm)
puts "done"

puts "\n" + "=" * 60 + "\n"
