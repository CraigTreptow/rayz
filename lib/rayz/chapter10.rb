require "async"
require_relative "world"
require_relative "camera"
require_relative "transformations"
require_relative "point_light"
require_relative "sphere"
require_relative "plane"

module Rayz
  module Chapter10
    def self.run
      puts "Chapter 10: Reflection and Refraction"
      puts "Rendering scene with mirrors and glass (800x400 pixels)..."
      puts "Features:"
      puts "  - Floor: Reflective checkerboard pattern"
      puts "  - Back wall: Reflective surface"
      puts "  - Middle sphere: Transparent glass ball"
      puts "  - Right sphere: Reflective chrome sphere"
      puts "  - Left sphere: Glass with color"
      puts "This may take a few minutes..."
      puts ""

      start_time = Time.now

      # Create world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Floor with reflective checkerboard
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        Color.new(red: 0.15, green: 0.15, blue: 0.15),
        Color.new(red: 0.85, green: 0.85, blue: 0.85)
      )
      floor.material.ambient = 0.2
      floor.material.diffuse = 0.8
      floor.material.specular = 0
      floor.material.reflective = 0.4
      world.objects << floor

      # Back wall - reflective
      back_wall = Plane.new
      back_wall.transform = Transformations.rotation_x(radians: Math::PI / 2) *
        Transformations.translation(x: 0, y: 0, z: 5)
      back_wall.material.color = Color.new(red: 0.15, green: 0.15, blue: 0.25)
      back_wall.material.ambient = 0.2
      back_wall.material.diffuse = 0.7
      back_wall.material.specular = 0.3
      back_wall.material.shininess = 200
      back_wall.material.reflective = 0.5
      world.objects << back_wall

      # Middle sphere - transparent glass
      middle = glass_sphere
      middle.transform = Transformations.translation(x: -0.5, y: 1, z: 0.5)
      middle.material.color = Color.new(red: 0.1, green: 0.1, blue: 0.1)
      middle.material.diffuse = 0.1
      middle.material.ambient = 0
      middle.material.specular = 1.0
      middle.material.shininess = 300
      middle.material.reflective = 1.0
      middle.material.transparency = 1.0
      middle.material.refractive_index = 1.5
      world.objects << middle

      # Right sphere - chrome (highly reflective)
      right = Sphere.new
      right.transform = Transformations.translation(x: 1.5, y: 0.5, z: -0.5) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      right.material.color = Color.new(red: 0.3, green: 0.3, blue: 0.3)
      right.material.diffuse = 0.1
      right.material.ambient = 0
      right.material.specular = 1.0
      right.material.shininess = 300
      right.material.reflective = 0.9
      world.objects << right

      # Left sphere - colored glass
      left = glass_sphere
      left.transform = Transformations.translation(x: -1.5, y: 0.33, z: -0.75) *
        Transformations.scaling(x: 0.33, y: 0.33, z: 0.33)
      left.material.color = Color.new(red: 0.1, green: 0.2, blue: 0.1)
      left.material.diffuse = 0.1
      left.material.ambient = 0
      left.material.specular = 1.0
      left.material.shininess = 300
      left.material.reflective = 0.9
      left.material.transparency = 0.9
      left.material.refractive_index = 1.5
      world.objects << left

      # Small glass sphere inside the middle one
      inner = glass_sphere
      inner.transform = Transformations.translation(x: -0.5, y: 1, z: 0.5) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      inner.material.refractive_index = 1.0000034 # Air
      world.objects << inner

      # Camera
      camera = Camera.new(hsize: 800, vsize: 400, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 1.5, z: -5),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # Render
      image = camera.render(world)

      end_time = Time.now
      duration = end_time - start_time

      puts "Done!"
      puts "Rendering took #{duration.round(2)} seconds"
      puts "Time per row: #{(duration / camera.vsize * 1000).round(1)} ms"

      # Save to file
      puts "Writing to chapter10.ppm..."
      File.write("chapter10.ppm", image.to_ppm)
      puts "Scene rendered to chapter10.ppm"
    end
  end
end
