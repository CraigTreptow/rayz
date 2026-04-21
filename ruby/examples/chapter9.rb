require_relative "../lib/rayz/world"
require_relative "../lib/rayz/camera"
require_relative "../lib/rayz/point_light"
require_relative "../lib/rayz/point"
require_relative "../lib/rayz/color"
require_relative "../lib/rayz/sphere"
require_relative "../lib/rayz/plane"
require_relative "../lib/rayz/transformations"
require_relative "../lib/rayz/material"

module Rayz
  class Chapter9
    def self.run
      puts "Chapter 9: Planes"

      # Create a world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Create floor plane
      floor = Plane.new
      floor.material.color = Color.new(red: 1, green: 0.9, blue: 0.9)
      floor.material.specular = 0
      world.objects << floor

      # Create left wall plane
      left_wall = Plane.new
      left_wall.transform = Transformations.translation(x: 0, y: 0, z: 5) *
        Transformations.rotation_y(radians: -Math::PI / 4) *
        Transformations.rotation_x(radians: Math::PI / 2)
      left_wall.material.color = Color.new(red: 1, green: 0.9, blue: 0.9)
      left_wall.material.specular = 0
      world.objects << left_wall

      # Create right wall plane
      right_wall = Plane.new
      right_wall.transform = Transformations.translation(x: 0, y: 0, z: 5) *
        Transformations.rotation_y(radians: Math::PI / 4) *
        Transformations.rotation_x(radians: Math::PI / 2)
      right_wall.material.color = Color.new(red: 1, green: 0.9, blue: 0.9)
      right_wall.material.specular = 0
      world.objects << right_wall

      # Create middle sphere
      middle = Sphere.new
      middle.transform = Transformations.translation(x: -0.5, y: 1, z: 0.5)
      middle.material.color = Color.new(red: 0.1, green: 1, blue: 0.5)
      middle.material.diffuse = 0.7
      middle.material.specular = 0.3
      world.objects << middle

      # Create right sphere
      right = Sphere.new
      right.transform = Transformations.translation(x: 1.5, y: 0.5, z: -0.5) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      right.material.color = Color.new(red: 0.5, green: 1, blue: 0.1)
      right.material.diffuse = 0.7
      right.material.specular = 0.3
      world.objects << right

      # Create left sphere
      left = Sphere.new
      left.transform = Transformations.translation(x: -1.5, y: 0.33, z: -0.75) *
        Transformations.scaling(x: 0.33, y: 0.33, z: 0.33)
      left.material.color = Color.new(red: 1, green: 0.8, blue: 0.1)
      left.material.diffuse = 0.7
      left.material.specular = 0.3
      world.objects << left

      # Set up camera
      camera = Camera.new(hsize: 400, vsize: 200, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 1.5, z: -5),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      puts "Rendering scene with planes (400x200 pixels)..."
      puts "Features:"
      puts "  - Floor: Infinite plane at y=0"
      puts "  - Left wall: Plane rotated and positioned"
      puts "  - Right wall: Plane rotated and positioned"
      puts "  - Three spheres with different materials"
      puts "This may take a minute..."

      # Render the scene
      canvas = camera.render(world)

      # Write to file
      File.write("examples/chapter9.ppm", canvas.to_ppm)
      puts "Scene rendered to chapter9.ppm"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
