require_relative "world"
require_relative "camera"
require_relative "point_light"
require_relative "point"
require_relative "color"
require_relative "sphere"
require_relative "transformations"
require_relative "material"

module Rayz
  class Chapter7
    def self.run
      puts "Chapter 7: Making a Scene"

      # Create a world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        Point.new(x: -10, y: 10, z: -10),
        Color.new(red: 1, green: 1, blue: 1)
      )

      # Create floor sphere (scaled and flattened)
      floor = Sphere.new
      floor.transform = Transformations.scaling(10, 0.01, 10)
      floor.material.color = Color.new(red: 1, green: 0.9, blue: 0.9)
      floor.material.specular = 0
      world.objects << floor

      # Create left wall
      left_wall = Sphere.new
      left_wall.transform = Transformations.translation(0, 0, 5) *
        Transformations.rotation_y(-Math::PI / 4) *
        Transformations.rotation_x(Math::PI / 2) *
        Transformations.scaling(10, 0.01, 10)
      left_wall.material = floor.material
      world.objects << left_wall

      # Create right wall
      right_wall = Sphere.new
      right_wall.transform = Transformations.translation(0, 0, 5) *
        Transformations.rotation_y(Math::PI / 4) *
        Transformations.rotation_x(Math::PI / 2) *
        Transformations.scaling(10, 0.01, 10)
      right_wall.material = floor.material
      world.objects << right_wall

      # Create middle sphere
      middle = Sphere.new
      middle.transform = Transformations.translation(-0.5, 1, 0.5)
      middle.material.color = Color.new(red: 0.1, green: 1, blue: 0.5)
      middle.material.diffuse = 0.7
      middle.material.specular = 0.3
      world.objects << middle

      # Create right sphere
      right = Sphere.new
      right.transform = Transformations.translation(1.5, 0.5, -0.5) *
        Transformations.scaling(0.5, 0.5, 0.5)
      right.material.color = Color.new(red: 0.5, green: 1, blue: 0.1)
      right.material.diffuse = 0.7
      right.material.specular = 0.3
      world.objects << right

      # Create left sphere
      left = Sphere.new
      left.transform = Transformations.translation(-1.5, 0.33, -0.75) *
        Transformations.scaling(0.33, 0.33, 0.33)
      left.material.color = Color.new(red: 1, green: 0.8, blue: 0.1)
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

      puts "Rendering scene (400x200 pixels)..."
      puts "This may take a minute..."

      # Render the scene
      canvas = camera.render(world)

      # Write to file
      File.write("chapter7.ppm", canvas.to_ppm)
      puts "Scene rendered to chapter7.ppm"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
