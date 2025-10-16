require_relative "../lib/rayz/world"
require_relative "../lib/rayz/camera"
require_relative "../lib/rayz/point_light"
require_relative "../lib/rayz/point"
require_relative "../lib/rayz/color"
require_relative "../lib/rayz/sphere"
require_relative "../lib/rayz/plane"
require_relative "../lib/rayz/transformations"
require_relative "../lib/rayz/material"
require_relative "../lib/rayz/stripe_pattern"
require_relative "../lib/rayz/checkers_pattern"
require_relative "../lib/rayz/gradient_pattern"
require_relative "../lib/rayz/ring_pattern"

module Rayz
  class Chapter8
    def self.run
      puts "Chapter 8: Shadows (Patterns and Planes)"

      # Create a world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Create floor plane with checkers pattern
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 1, green: 1, blue: 1),
        b: Color.new(red: 0.2, green: 0.2, blue: 0.2)
      )
      floor.material.specular = 0
      world.objects << floor

      # Create back wall plane with gradient pattern
      back_wall = Plane.new
      back_wall.transform = Transformations.rotation_x(radians: Math::PI / 2) *
        Transformations.translation(x: 0, y: 0, z: 5)
      back_wall.material.pattern = GradientPattern.new(
        Color.new(red: 0.5, green: 0.7, blue: 1),
        Color.new(red: 0.1, green: 0.1, blue: 0.3)
      )
      back_wall.material.pattern.transform = Transformations.rotation_z(radians: Math::PI / 2) *
        Transformations.scaling(x: 2, y: 2, z: 2)
      back_wall.material.specular = 0
      world.objects << back_wall

      # Create middle sphere with ring pattern
      middle = Sphere.new
      middle.transform = Transformations.translation(x: -0.5, y: 1, z: 0.5)
      middle.material.pattern = RingPattern.new(
        Color.new(red: 0.1, green: 1, blue: 0.5),
        Color.new(red: 0.9, green: 0.1, blue: 0.9)
      )
      middle.material.pattern.transform = Transformations.scaling(x: 0.2, y: 0.2, z: 0.2)
      middle.material.diffuse = 0.7
      middle.material.specular = 0.3
      world.objects << middle

      # Create right sphere with stripe pattern
      right = Sphere.new
      right.transform = Transformations.translation(x: 1.5, y: 0.5, z: -0.5) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      right.material.pattern = StripePattern.new(
        Color.new(red: 1, green: 0.2, blue: 0.2),
        Color.new(red: 1, green: 1, blue: 0.2)
      )
      right.material.pattern.transform = Transformations.scaling(x: 0.2, y: 0.2, z: 0.2) *
        Transformations.rotation_z(radians: Math::PI / 4)
      right.material.diffuse = 0.7
      right.material.specular = 0.3
      world.objects << right

      # Create left sphere with gradient pattern
      left = Sphere.new
      left.transform = Transformations.translation(x: -1.5, y: 0.33, z: -0.75) *
        Transformations.scaling(x: 0.33, y: 0.33, z: 0.33)
      left.material.pattern = GradientPattern.new(
        Color.new(red: 1, green: 0.8, blue: 0.1),
        Color.new(red: 0.1, green: 0.2, blue: 1)
      )
      left.material.pattern.transform = Transformations.translation(x: -1, y: 0, z: 0) *
        Transformations.scaling(x: 2, y: 2, z: 2)
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

      puts "Rendering scene with patterns and planes (400x200 pixels)..."
      puts "Features:"
      puts "  - Floor: Checkers pattern on an infinite plane"
      puts "  - Back wall: Gradient pattern"
      puts "  - Middle sphere: Ring pattern"
      puts "  - Right sphere: Stripe pattern (rotated)"
      puts "  - Left sphere: Gradient pattern"
      puts "This may take a minute..."

      # Render the scene
      canvas = camera.render(world)

      # Write to file
      File.write("examples/chapter8.ppm", canvas.to_ppm)
      puts "Scene rendered to chapter8.ppm"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
