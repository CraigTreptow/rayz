require "async"
require_relative "../lib/rayz/world"
require_relative "../lib/rayz/camera"
require_relative "../lib/rayz/transformations"
require_relative "../lib/rayz/point_light"
require_relative "../lib/rayz/cylinder"
require_relative "../lib/rayz/plane"

module Rayz
  module Chapter12
    def self.run
      puts "Chapter 12: Cylinders"
      puts "Rendering scene with cylinders (800x600 pixels)..."
      puts "Features:"
      puts "  - Infinite cylinders (table legs)"
      puts "  - Truncated cylinders (various heights)"
      puts "  - Closed cylinders with end caps"
      puts "  - Open cylinders (hollow)"
      puts "This may take a few minutes..."
      puts ""

      start_time = Time.now

      # Create world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        position: Point.new(x: 10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Floor
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.5, green: 0.5, blue: 0.5),
        b: Color.new(red: 0.75, green: 0.75, blue: 0.75)
      )
      floor.material.reflective = 0.1
      world.objects << floor

      # Table legs (truncated cylinders)
      leg_positions = [
        [-2, 1.5],
        [2, 1.5],
        [-2, -1.5],
        [2, -1.5]
      ]

      leg_positions.each do |x, z|
        leg = Cylinder.new
        leg.minimum = 0
        leg.maximum = 3
        leg.closed = true
        leg.transform = Transformations.translation(x: x, y: 0, z: z) *
          Transformations.scaling(x: 0.15, y: 1, z: 0.15)
        leg.material.color = Color.new(red: 0.6, green: 0.4, blue: 0.2)
        leg.material.diffuse = 0.8
        leg.material.specular = 0.3
        world.objects << leg
      end

      # Table top (flattened cylinder)
      table_top = Cylinder.new
      table_top.minimum = 0
      table_top.maximum = 0.2
      table_top.closed = true
      table_top.transform = Transformations.translation(x: 0, y: 3, z: 0) *
        Transformations.scaling(x: 2.5, y: 1, z: 2)
      table_top.material.color = Color.new(red: 0.7, green: 0.45, blue: 0.25)
      table_top.material.ambient = 0.1
      table_top.material.diffuse = 0.7
      table_top.material.specular = 0.4
      table_top.material.shininess = 50
      world.objects << table_top

      # Glass cylinder on table (open, truncated)
      glass = Cylinder.new
      glass.minimum = 0
      glass.maximum = 1.5
      glass.closed = false  # Open cylinder (hollow)
      glass.transform = Transformations.translation(x: -1, y: 3.2, z: 0) *
        Transformations.scaling(x: 0.4, y: 1, z: 0.4)
      glass.material.color = Color.new(red: 0.8, green: 0.9, blue: 1.0)
      glass.material.ambient = 0.0
      glass.material.diffuse = 0.1
      glass.material.specular = 1.0
      glass.material.shininess = 300
      glass.material.reflective = 0.9
      glass.material.transparency = 0.9
      glass.material.refractive_index = 1.5
      world.objects << glass

      # Metal cylinder (closed, short)
      metal = Cylinder.new
      metal.minimum = 0
      metal.maximum = 0.8
      metal.closed = true
      metal.transform = Transformations.translation(x: 1, y: 3.2, z: 0.5) *
        Transformations.rotation_y(radians: Math::PI / 6) *
        Transformations.scaling(x: 0.3, y: 1, z: 0.3)
      metal.material.color = Color.new(red: 0.7, green: 0.7, blue: 0.7)
      metal.material.ambient = 0.1
      metal.material.diffuse = 0.6
      metal.material.specular = 0.9
      metal.material.shininess = 200
      metal.material.reflective = 0.8
      world.objects << metal

      # Colored cylinder (closed, tall and thin)
      colored = Cylinder.new
      colored.minimum = 0
      colored.maximum = 2
      colored.closed = true
      colored.transform = Transformations.translation(x: 0.5, y: 3.2, z: -0.8) *
        Transformations.rotation_z(radians: Math::PI / 8) *
        Transformations.scaling(x: 0.15, y: 1, z: 0.15)
      colored.material.color = Color.new(red: 0.8, green: 0.2, blue: 0.3)
      colored.material.ambient = 0.2
      colored.material.diffuse = 0.8
      colored.material.specular = 0.3
      world.objects << colored

      # Floor candle - cylinder with flame effect
      candle = Cylinder.new
      candle.minimum = 0
      candle.maximum = 1.2
      candle.closed = true
      candle.transform = Transformations.translation(x: -4, y: 0, z: -3) *
        Transformations.scaling(x: 0.2, y: 1, z: 0.2)
      candle.material.color = Color.new(red: 0.9, green: 0.9, blue: 0.8)
      candle.material.ambient = 0.3
      candle.material.diffuse = 0.6
      world.objects << candle

      # Camera
      camera = Camera.new(hsize: 800, vsize: 600, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 8, y: 6, z: -8),
        to: Point.new(x: 0, y: 3, z: 0),
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
      puts "Writing to chapter12.ppm..."
      File.write("examples/chapter12.ppm", image.to_ppm)
      puts "Scene rendered to chapter12.ppm"
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
