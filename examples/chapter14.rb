require "async"
require_relative "../lib/rayz/world"
require_relative "../lib/rayz/camera"
require_relative "../lib/rayz/transformations"
require_relative "../lib/rayz/point_light"
require_relative "../lib/rayz/cone"
require_relative "../lib/rayz/plane"
require_relative "../lib/rayz/sphere"
require_relative "../lib/rayz/cylinder"

module Rayz
  module Chapter14
    def self.run
      puts "Chapter 14: Cones"
      puts "Rendering scene with cones (800x600 pixels)..."
      puts "Features:"
      puts "  - Infinite cones (traffic cone)"
      puts "  - Truncated cones (various heights)"
      puts "  - Closed cones with end caps"
      puts "  - Open cones (ice cream cone)"
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
        Color.new(red: 0.5, green: 0.5, blue: 0.5),
        Color.new(red: 0.75, green: 0.75, blue: 0.75)
      )
      floor.material.reflective = 0.1
      world.objects << floor

      # Traffic cone (truncated cone with stripes)
      traffic_cone = Cone.new
      traffic_cone.minimum = 0
      traffic_cone.maximum = 2
      traffic_cone.closed = true
      traffic_cone.transform = Transformations.translation(x: -3, y: 0, z: -2) *
        Transformations.scaling(x: 1, y: 1, z: 1)
      traffic_cone.material.color = Color.new(red: 1, green: 0.5, blue: 0)
      traffic_cone.material.ambient = 0.2
      traffic_cone.material.diffuse = 0.8
      traffic_cone.material.specular = 0.3
      world.objects << traffic_cone

      # Glass cone (transparent, closed)
      glass_cone = Cone.new
      glass_cone.minimum = -1
      glass_cone.maximum = 1
      glass_cone.closed = true
      glass_cone.transform = Transformations.translation(x: 0, y: 1, z: 0) *
        Transformations.scaling(x: 1, y: 1, z: 1)
      glass_cone.material.color = Color.new(red: 0.8, green: 0.9, blue: 1.0)
      glass_cone.material.ambient = 0.0
      glass_cone.material.diffuse = 0.1
      glass_cone.material.specular = 1.0
      glass_cone.material.shininess = 300
      glass_cone.material.reflective = 0.9
      glass_cone.material.transparency = 0.9
      glass_cone.material.refractive_index = 1.5
      world.objects << glass_cone

      # Metal cone (reflective)
      metal_cone = Cone.new
      metal_cone.minimum = 0
      metal_cone.maximum = 1.5
      metal_cone.closed = true
      metal_cone.transform = Transformations.translation(x: 3, y: 0, z: -1) *
        Transformations.rotation_z(radians: Math::PI) *
        Transformations.scaling(x: 0.8, y: 1, z: 0.8)
      metal_cone.material.color = Color.new(red: 0.7, green: 0.7, blue: 0.7)
      metal_cone.material.ambient = 0.1
      metal_cone.material.diffuse = 0.6
      metal_cone.material.specular = 0.9
      metal_cone.material.shininess = 200
      metal_cone.material.reflective = 0.8
      world.objects << metal_cone

      # Ice cream cone (open cone with sphere on top)
      ice_cream_cone = Cone.new
      ice_cream_cone.minimum = 0
      ice_cream_cone.maximum = 2
      ice_cream_cone.closed = false  # Open cone
      ice_cream_cone.transform = Transformations.translation(x: -1.5, y: 0, z: 2) *
        Transformations.rotation_z(radians: Math::PI) *
        Transformations.scaling(x: 0.6, y: 1, z: 0.6)
      ice_cream_cone.material.color = Color.new(red: 0.9, green: 0.7, blue: 0.4)
      ice_cream_cone.material.ambient = 0.2
      ice_cream_cone.material.diffuse = 0.8
      ice_cream_cone.material.specular = 0.1
      world.objects << ice_cream_cone

      # Ice cream scoop (sphere on top of cone)
      ice_cream_scoop = Sphere.new
      ice_cream_scoop.transform = Transformations.translation(x: -1.5, y: 2, z: 2) *
        Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)
      ice_cream_scoop.material.color = Color.new(red: 1, green: 0.7, blue: 0.8)
      ice_cream_scoop.material.ambient = 0.2
      ice_cream_scoop.material.diffuse = 0.7
      ice_cream_scoop.material.specular = 0.3
      world.objects << ice_cream_scoop

      # Party hat (tall thin cone)
      party_hat = Cone.new
      party_hat.minimum = 0
      party_hat.maximum = 3
      party_hat.closed = true
      party_hat.transform = Transformations.translation(x: 1.5, y: 0, z: 2.5) *
        Transformations.rotation_z(radians: Math::PI) *
        Transformations.scaling(x: 0.4, y: 1, z: 0.4)
      party_hat.material.color = Color.new(red: 0.8, green: 0.2, blue: 0.8)
      party_hat.material.ambient = 0.3
      party_hat.material.diffuse = 0.7
      party_hat.material.specular = 0.4
      world.objects << party_hat

      # Double cone (hourglass shape) - top cone
      double_cone_top = Cone.new
      double_cone_top.minimum = 0
      double_cone_top.maximum = 1
      double_cone_top.closed = false
      double_cone_top.transform = Transformations.translation(x: 4, y: 1, z: 2) *
        Transformations.rotation_z(radians: Math::PI) *
        Transformations.scaling(x: 0.7, y: 1, z: 0.7)
      double_cone_top.material.color = Color.new(red: 0.2, green: 0.6, blue: 0.8)
      double_cone_top.material.ambient = 0.2
      double_cone_top.material.diffuse = 0.7
      double_cone_top.material.specular = 0.5
      world.objects << double_cone_top

      # Double cone (hourglass shape) - bottom cone
      double_cone_bottom = Cone.new
      double_cone_bottom.minimum = 0
      double_cone_bottom.maximum = 1
      double_cone_bottom.closed = false
      double_cone_bottom.transform = Transformations.translation(x: 4, y: 1, z: 2) *
        Transformations.scaling(x: 0.7, y: 1, z: 0.7)
      double_cone_bottom.material.color = Color.new(red: 0.2, green: 0.6, blue: 0.8)
      double_cone_bottom.material.ambient = 0.2
      double_cone_bottom.material.diffuse = 0.7
      double_cone_bottom.material.specular = 0.5
      world.objects << double_cone_bottom

      # Camera
      camera = Camera.new(hsize: 800, vsize: 600, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 8, y: 5, z: -8),
        to: Point.new(x: 0, y: 1.5, z: 0),
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
      puts "Writing to chapter14.ppm..."
      File.write("examples/chapter14.ppm", image.to_ppm)
      puts "Scene rendered to chapter14.ppm"
    end
  end
end
