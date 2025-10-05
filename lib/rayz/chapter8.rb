require_relative "world"
require_relative "camera"
require_relative "point_light"
require_relative "point"
require_relative "color"
require_relative "sphere"
require_relative "plane"
require_relative "transformations"
require_relative "material"
require_relative "stripe_pattern"
require_relative "checkers_pattern"
require_relative "gradient_pattern"
require_relative "ring_pattern"

module Rayz
  class Chapter8
    def self.run
      puts "Chapter 8: Shadows (Patterns and Planes)"

      # Create a world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        Point.new(x: -10, y: 10, z: -10),
        Color.new(red: 1, green: 1, blue: 1)
      )

      # Create floor plane with checkers pattern
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        Color.new(red: 1, green: 1, blue: 1),
        Color.new(red: 0.2, green: 0.2, blue: 0.2)
      )
      floor.material.specular = 0
      world.objects << floor

      # Create back wall plane with gradient pattern
      back_wall = Plane.new
      back_wall.transform = Transformations.rotation_x(Math::PI / 2) *
        Transformations.translation(0, 0, 5)
      back_wall.material.pattern = GradientPattern.new(
        Color.new(red: 0.5, green: 0.7, blue: 1),
        Color.new(red: 0.1, green: 0.1, blue: 0.3)
      )
      back_wall.material.pattern.transform = Transformations.rotation_z(Math::PI / 2) *
        Transformations.scaling(2, 2, 2)
      back_wall.material.specular = 0
      world.objects << back_wall

      # Create middle sphere with ring pattern
      middle = Sphere.new
      middle.transform = Transformations.translation(-0.5, 1, 0.5)
      middle.material.pattern = RingPattern.new(
        Color.new(red: 0.1, green: 1, blue: 0.5),
        Color.new(red: 0.9, green: 0.1, blue: 0.9)
      )
      middle.material.pattern.transform = Transformations.scaling(0.2, 0.2, 0.2)
      middle.material.diffuse = 0.7
      middle.material.specular = 0.3
      world.objects << middle

      # Create right sphere with stripe pattern
      right = Sphere.new
      right.transform = Transformations.translation(1.5, 0.5, -0.5) *
        Transformations.scaling(0.5, 0.5, 0.5)
      right.material.pattern = StripePattern.new(
        Color.new(red: 1, green: 0.2, blue: 0.2),
        Color.new(red: 1, green: 1, blue: 0.2)
      )
      right.material.pattern.transform = Transformations.scaling(0.2, 0.2, 0.2) *
        Transformations.rotation_z(Math::PI / 4)
      right.material.diffuse = 0.7
      right.material.specular = 0.3
      world.objects << right

      # Create left sphere with gradient pattern
      left = Sphere.new
      left.transform = Transformations.translation(-1.5, 0.33, -0.75) *
        Transformations.scaling(0.33, 0.33, 0.33)
      left.material.pattern = GradientPattern.new(
        Color.new(red: 1, green: 0.8, blue: 0.1),
        Color.new(red: 0.1, green: 0.2, blue: 1)
      )
      left.material.pattern.transform = Transformations.translation(-1, 0, 0) *
        Transformations.scaling(2, 2, 2)
      left.material.diffuse = 0.7
      left.material.specular = 0.3
      world.objects << left

      # Set up camera
      camera = Camera.new(400, 200, Math::PI / 3)
      camera.transform = Transformations.view_transform(
        Point.new(x: 0, y: 1.5, z: -5),
        Point.new(x: 0, y: 1, z: 0),
        Vector.new(x: 0, y: 1, z: 0)
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
      File.write("chapter8.ppm", canvas.to_ppm)
      puts "Scene rendered to chapter8.ppm"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
