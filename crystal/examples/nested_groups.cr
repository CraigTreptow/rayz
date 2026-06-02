require "../src/rayz"

puts "Nested Groups Demo: Hierarchical Transformations"
puts "Demonstrating nested group transformations with world_to_object and normal_to_world"
puts "=" * 80

world = Rayz::World.new
world.light = Rayz::PointLight.new(
  Rayz::Point.new(-10.0, 10.0, -10.0),
  Rayz::Color.new(1.0, 1.0, 1.0)
)

floor = Rayz::Plane.new
floor.material.pattern = Rayz::CheckersPattern.new(
  Rayz::Color.new(0.9, 0.9, 0.9),
  Rayz::Color.new(0.1, 0.1, 0.1)
)
floor.material.reflective = 0.2
world.objects << floor

# Sun at the center
sun = Rayz::Sphere.new
sun.material.color = Rayz::Color.new(1.0, 0.9, 0.1)
sun.material.ambient = 0.8
sun.material.diffuse = 0.9
sun.transform = Rayz::Transformations.scaling(1.5, 1.5, 1.5)

# Earth orbit (level 1)
earth_orbit = Rayz::Group.new
earth_orbit.transform = Rayz::Transformations.rotation_y(Math::PI / 4.0)

# Earth position (level 2)
earth_position = Rayz::Group.new
earth_position.transform = Rayz::Transformations.translation(5.0, 0.0, 0.0)

# Earth rotation (level 3)
earth_rotation = Rayz::Group.new
earth_rotation.transform = Rayz::Transformations.rotation_y(Math::PI / 3.0)

# Earth sphere (level 4)
earth = Rayz::Sphere.new
earth.material.color = Rayz::Color.new(0.1, 0.3, 0.8)
earth.material.diffuse = 0.7
earth.material.specular = 0.3
earth.transform = Rayz::Transformations.scaling(0.8, 0.8, 0.8)

# Moon orbit (level 4)
moon_orbit = Rayz::Group.new
moon_orbit.transform = Rayz::Transformations.rotation_y(-Math::PI / 6.0)

# Moon position (level 5)
moon_position = Rayz::Group.new
moon_position.transform = Rayz::Transformations.translation(1.5, 0.3, 0.0)

# Moon sphere (level 6)
moon = Rayz::Sphere.new
moon.material.color = Rayz::Color.new(0.7, 0.7, 0.7)
moon.material.diffuse = 0.6
moon.transform = Rayz::Transformations.scaling(0.3, 0.3, 0.3)

moon_position.add_child(moon)
moon_orbit.add_child(moon_position)
earth_rotation.add_child(earth)
earth_rotation.add_child(moon_orbit)
earth_position.add_child(earth_rotation)
earth_orbit.add_child(earth_position)

world.objects << sun
world.objects << earth_orbit

# Mars system
mars_orbit = Rayz::Group.new
mars_orbit.transform = Rayz::Transformations.rotation_y(-Math::PI / 3.0)

mars_position = Rayz::Group.new
mars_position.transform = Rayz::Transformations.translation(-7.0, 0.0, 2.0)

mars = Rayz::Sphere.new
mars.material.color = Rayz::Color.new(0.9, 0.3, 0.1)
mars.material.diffuse = 0.7
mars.transform = Rayz::Transformations.scaling(0.6, 0.6, 0.6)

phobos_orbit = Rayz::Group.new
phobos_orbit.transform = Rayz::Transformations.rotation_y(Math::PI / 2.0)

phobos_position = Rayz::Group.new
phobos_position.transform = Rayz::Transformations.translation(1.2, 0.2, 0.0)

phobos = Rayz::Sphere.new
phobos.material.color = Rayz::Color.new(0.5, 0.5, 0.4)
phobos.transform = Rayz::Transformations.scaling(0.2, 0.2, 0.2)

phobos_position.add_child(phobos)
phobos_orbit.add_child(phobos_position)
mars_position.add_child(mars)
mars_position.add_child(phobos_orbit)
mars_orbit.add_child(mars_position)

world.objects << mars_orbit

# Space station with 4 arms
station = Rayz::Group.new
station.transform =
  Rayz::Transformations.translation(0.0, 3.0, -8.0) *
    Rayz::Transformations.rotation_y(Math::PI / 6.0)

hub = Rayz::Sphere.new
hub.material.color = Rayz::Color.new(0.8, 0.8, 0.9)
hub.material.reflective = 0.6
hub.material.specular = 0.9
hub.material.shininess = 300.0
hub.transform = Rayz::Transformations.scaling(0.5, 0.5, 0.5)
station.add_child(hub)

4.times do |i|
  angle = (Math::PI / 2.0) * i
  arm_group = Rayz::Group.new
  arm_group.transform = Rayz::Transformations.rotation_y(angle)

  arm_position = Rayz::Group.new
  arm_position.transform = Rayz::Transformations.translation(1.0, 0.0, 0.0)

  arm = Rayz::Cylinder.new
  arm.minimum = 0.0
  arm.maximum = 1.5
  arm.closed = true
  arm.material.color = Rayz::Color.new(0.6, 0.6, 0.7)
  arm.material.specular = 0.5
  arm.transform =
    Rayz::Transformations.scaling(0.1, 1.0, 0.1) *
      Rayz::Transformations.rotation_z(Math::PI / 2.0)

  end_sphere = Rayz::Sphere.new
  end_sphere.material.color = Rayz::Color.new(0.3, 0.6, 0.9)
  end_sphere.material.reflective = 0.3
  end_sphere.transform =
    Rayz::Transformations.translation(1.5, 0.0, 0.0) *
      Rayz::Transformations.scaling(0.3, 0.3, 0.3)

  arm_position.add_child(arm)
  arm_position.add_child(end_sphere)
  arm_group.add_child(arm_position)
  station.add_child(arm_group)
end

world.objects << station

camera = Rayz::Camera.new(800, 600, Math::PI / 3.0)
camera.transform = Rayz::Transformations.view_transform(
  Rayz::Point.new(0.0, 8.0, -15.0),
  Rayz::Point.new(0.0, 1.0, 0.0),
  Rayz::Vector.new(0.0, 1.0, 0.0)
)

puts "\nRendering scene (800x600 pixels)..."
puts "Demonstrates hierarchical transformations:"
puts "  - Solar system: sun, earth, moon (6 levels deep)"
puts "  - Mars system with satellite (5 levels deep)"
puts "  - Space station with 4 rotating arms (3 levels deep)"

canvas = camera.render(world)

output_path = File.join(File.dirname(__FILE__), "nested_groups.ppm")
File.write(output_path, canvas.to_ppm)

puts "Scene rendered to #{output_path}"

puts "\n" + "=" * 60 + "\n"
