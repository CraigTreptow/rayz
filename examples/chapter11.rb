require "async"
require_relative "../lib/rayz/world"
require_relative "../lib/rayz/camera"
require_relative "../lib/rayz/transformations"
require_relative "../lib/rayz/point_light"
require_relative "../lib/rayz/cube"
require_relative "../lib/rayz/plane"

module Rayz
  module Chapter11
    def self.run
      puts "Chapter 11: Cubes"
      puts "Rendering scene with cubes (800x600 pixels)..."
      puts "Features:"
      puts "  - Room made from a large cube"
      puts "  - Table with 4 legs and a surface"
      puts "  - Boxes on the table and floor"
      puts "This may take a few minutes..."
      puts ""

      start_time = Time.now

      # Create world
      world = World.new

      # Add light source
      world.light = PointLight.new(
        position: Point.new(x: 2, y: 10, z: -5),
        intensity: Color.new(red: 0.9, green: 0.9, blue: 0.9)
      )

      # Room - large cube
      room = Cube.new
      room.transform = Transformations.scaling(x: 15, y: 15, z: 15)
      room.material.pattern = CheckersPattern.new(
        Color.new(red: 0.15, green: 0.15, blue: 0.15),
        Color.new(red: 0.25, green: 0.25, blue: 0.25)
      )
      room.material.ambient = 0.3
      room.material.diffuse = 0.7
      room.material.specular = 0.0
      room.material.reflective = 0.1
      world.objects << room

      # Table surface
      table_top = Cube.new
      table_top.transform = Transformations.translation(x: 0, y: 3.1, z: 0) *
        Transformations.scaling(x: 3, y: 0.1, z: 2)
      table_top.material.color = Color.new(red: 0.6, green: 0.3, blue: 0.1)
      table_top.material.ambient = 0.2
      table_top.material.diffuse = 0.7
      table_top.material.specular = 0.3
      table_top.material.shininess = 20
      world.objects << table_top

      # Table leg 1 (front-left)
      leg1 = Cube.new
      leg1.transform = Transformations.translation(x: -2.7, y: 1.5, z: -1.7) *
        Transformations.scaling(x: 0.1, y: 1.5, z: 0.1)
      leg1.material.color = Color.new(red: 0.5, green: 0.25, blue: 0.1)
      leg1.material.ambient = 0.2
      leg1.material.diffuse = 0.7
      world.objects << leg1

      # Table leg 2 (front-right)
      leg2 = Cube.new
      leg2.transform = Transformations.translation(x: 2.7, y: 1.5, z: -1.7) *
        Transformations.scaling(x: 0.1, y: 1.5, z: 0.1)
      leg2.material.color = Color.new(red: 0.5, green: 0.25, blue: 0.1)
      leg2.material.ambient = 0.2
      leg2.material.diffuse = 0.7
      world.objects << leg2

      # Table leg 3 (back-left)
      leg3 = Cube.new
      leg3.transform = Transformations.translation(x: -2.7, y: 1.5, z: 1.7) *
        Transformations.scaling(x: 0.1, y: 1.5, z: 0.1)
      leg3.material.color = Color.new(red: 0.5, green: 0.25, blue: 0.1)
      leg3.material.ambient = 0.2
      leg3.material.diffuse = 0.7
      world.objects << leg3

      # Table leg 4 (back-right)
      leg4 = Cube.new
      leg4.transform = Transformations.translation(x: 2.7, y: 1.5, z: 1.7) *
        Transformations.scaling(x: 0.1, y: 1.5, z: 0.1)
      leg4.material.color = Color.new(red: 0.5, green: 0.25, blue: 0.1)
      leg4.material.ambient = 0.2
      leg4.material.diffuse = 0.7
      world.objects << leg4

      # Glass cube on table
      glass_cube = Cube.new
      glass_cube.transform = Transformations.translation(x: 0, y: 3.8, z: 0) *
        Transformations.rotation_y(radians: Math::PI / 6) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      glass_cube.material.color = Color.new(red: 0.1, green: 0.1, blue: 0.1)
      glass_cube.material.ambient = 0.0
      glass_cube.material.diffuse = 0.1
      glass_cube.material.specular = 1.0
      glass_cube.material.shininess = 300
      glass_cube.material.reflective = 0.9
      glass_cube.material.transparency = 0.9
      glass_cube.material.refractive_index = 1.5
      world.objects << glass_cube

      # Metal cube on table
      metal_cube = Cube.new
      metal_cube.transform = Transformations.translation(x: 1.5, y: 4.0, z: 1.0) *
        Transformations.rotation_y(radians: Math::PI / 4) *
        Transformations.scaling(x: 0.7, y: 0.7, z: 0.7)
      metal_cube.material.color = Color.new(red: 0.3, green: 0.3, blue: 0.3)
      metal_cube.material.ambient = 0.1
      metal_cube.material.diffuse = 0.3
      metal_cube.material.specular = 0.9
      metal_cube.material.shininess = 200
      metal_cube.material.reflective = 0.8
      world.objects << metal_cube

      # Small colored cube on table
      small_cube = Cube.new
      small_cube.transform = Transformations.translation(x: -1.8, y: 3.6, z: -0.5) *
        Transformations.rotation_y(radians: Math::PI / 8) *
        Transformations.scaling(x: 0.4, y: 0.4, z: 0.4)
      small_cube.material.color = Color.new(red: 0.8, green: 0.2, blue: 0.2)
      small_cube.material.ambient = 0.2
      small_cube.material.diffuse = 0.8
      small_cube.material.specular = 0.3
      world.objects << small_cube

      # Box on floor
      floor_box = Cube.new
      floor_box.transform = Transformations.translation(x: 4, y: 0.6, z: 3) *
        Transformations.rotation_y(radians: Math::PI / 5) *
        Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)
      floor_box.material.color = Color.new(red: 0.2, green: 0.4, blue: 0.8)
      floor_box.material.ambient = 0.2
      floor_box.material.diffuse = 0.8
      floor_box.material.specular = 0.2
      world.objects << floor_box

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
      puts "Writing to chapter11.ppm..."
      File.write("examples/chapter11.ppm", image.to_ppm)
      puts "Scene rendered to chapter11.ppm"
    end
  end
end
