module Rayz
  class Chapter13
    def self.run
      puts "\n=== Chapter 13: Groups ==="
      puts "Demonstrating hierarchical scene composition with groups..."

      # Create camera
      camera = Camera.new(
        hsize: 800,
        vsize: 600,
        field_of_view: Math::PI / 3
      )
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 3, z: -8),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # Create light source
      light = PointLight.new(
        position: Point.new(x: -5, y: 10, z: -10),
        intensity: Color.new(r: 1, g: 1, b: 1)
      )

      # Create floor
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        Color.new(r: 0.9, g: 0.9, b: 0.9),
        Color.new(r: 0.1, g: 0.1, b: 0.1)
      )
      floor.material.reflective = 0.1

      # Create a simple "tree" using groups
      # Trunk group (cylinder)
      trunk = Cylinder.new
      trunk.minimum = 0
      trunk.maximum = 1.5
      trunk.closed = true
      trunk.material.color = Color.new(r: 0.4, g: 0.2, b: 0.1)
      trunk.material.specular = 0.1

      # Foliage group (multiple spheres)
      foliage_group = Group.new

      # Center foliage
      foliage1 = Sphere.new
      foliage1.transform = Transformations.translation(x: 0, y: 2, z: 0) *
        Transformations.scaling(x: 0.8, y: 0.8, z: 0.8)
      foliage1.material.color = Color.new(r: 0.1, g: 0.6, b: 0.1)
      foliage1.material.specular = 0.3

      # Left foliage
      foliage2 = Sphere.new
      foliage2.transform = Transformations.translation(x: -0.5, y: 1.7, z: 0) *
        Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)
      foliage2.material.color = Color.new(r: 0.1, g: 0.7, b: 0.1)
      foliage2.material.specular = 0.3

      # Right foliage
      foliage3 = Sphere.new
      foliage3.transform = Transformations.translation(x: 0.5, y: 1.7, z: 0.2) *
        Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)
      foliage3.material.color = Color.new(r: 0.1, g: 0.8, b: 0.1)
      foliage3.material.specular = 0.3

      # Top foliage
      foliage4 = Sphere.new
      foliage4.transform = Transformations.translation(x: 0, y: 2.5, z: 0) *
        Transformations.scaling(x: 0.5, y: 0.5, z: 0.5)
      foliage4.material.color = Color.new(r: 0.1, g: 0.5, b: 0.1)
      foliage4.material.specular = 0.3

      foliage_group.add_child(foliage1)
      foliage_group.add_child(foliage2)
      foliage_group.add_child(foliage3)
      foliage_group.add_child(foliage4)

      # Tree group (trunk + foliage)
      tree = Group.new
      tree.add_child(trunk)
      tree.add_child(foliage_group)
      tree.transform = Transformations.translation(x: -2, y: 0, z: 1)

      # Create a "snowman" using groups
      # Bottom sphere
      snowman_bottom = Sphere.new
      snowman_bottom.transform = Transformations.translation(x: 0, y: 0.6, z: 0) *
        Transformations.scaling(x: 0.6, y: 0.6, z: 0.6)
      snowman_bottom.material.color = Color.new(r: 1, g: 1, b: 1)
      snowman_bottom.material.specular = 0.9
      snowman_bottom.material.shininess = 300

      # Middle sphere
      snowman_middle = Sphere.new
      snowman_middle.transform = Transformations.translation(x: 0, y: 1.5, z: 0) *
        Transformations.scaling(x: 0.45, y: 0.45, z: 0.45)
      snowman_middle.material.color = Color.new(r: 1, g: 1, b: 1)
      snowman_middle.material.specular = 0.9
      snowman_middle.material.shininess = 300

      # Head sphere
      snowman_head = Sphere.new
      snowman_head.transform = Transformations.translation(x: 0, y: 2.2, z: 0) *
        Transformations.scaling(x: 0.3, y: 0.3, z: 0.3)
      snowman_head.material.color = Color.new(r: 1, g: 1, b: 1)
      snowman_head.material.specular = 0.9
      snowman_head.material.shininess = 300

      # Nose (carrot)
      nose = Cylinder.new
      nose.minimum = 0
      nose.maximum = 0.3
      nose.closed = true
      nose.transform = Transformations.translation(x: 0, y: 2.2, z: 0.3) *
        Transformations.rotation_x(radians: Math::PI / 2) *
        Transformations.scaling(x: 0.08, y: 1, z: 0.08)
      nose.material.color = Color.new(r: 1, g: 0.5, b: 0)
      nose.material.specular = 0.1

      # Snowman group
      snowman = Group.new
      snowman.add_child(snowman_bottom)
      snowman.add_child(snowman_middle)
      snowman.add_child(snowman_head)
      snowman.add_child(nose)
      snowman.transform = Transformations.translation(x: 2, y: 0, z: -1)

      # Create a hexagon group (6 spheres in a ring)
      hexagon = Group.new
      6.times do |i|
        sphere = Sphere.new
        angle = i * Math::PI / 3
        sphere.transform = Transformations.translation(x: Math.cos(angle), y: 0.3, z: Math.sin(angle)) *
          Transformations.scaling(x: 0.3, y: 0.3, z: 0.3)

        # Color based on position
        hue = i / 6.0
        sphere.material.color = Color.new(
          r: (Math.sin(hue * Math::PI * 2) + 1) / 2,
          g: (Math.sin((hue + 0.33) * Math::PI * 2) + 1) / 2,
          b: (Math.sin((hue + 0.67) * Math::PI * 2) + 1) / 2
        )
        sphere.material.specular = 0.6
        sphere.material.reflective = 0.2

        hexagon.add_child(sphere)
      end
      hexagon.transform = Transformations.translation(x: 0, y: 0, z: 3)

      # Create world and add all objects
      world = World.new
      world.light = light
      world.objects << floor
      world.objects << tree
      world.objects << snowman
      world.objects << hexagon

      # Render the scene
      puts "Rendering 800x600 scene (this will take a few minutes)..."
      start_time = Time.now
      canvas = camera.render(world)
      end_time = Time.now
      elapsed = end_time - start_time

      puts "Rendering completed in #{elapsed.round(2)} seconds"
      puts "Writing to chapter13.ppm..."

      File.write("chapter13.ppm", canvas.to_ppm)
      puts "Done! Output saved to chapter13.ppm"
      puts "Scene demonstrates:"
      puts "  - Hierarchical groups (tree with trunk and foliage groups)"
      puts "  - Compound objects (snowman made from spheres and cylinder)"
      puts "  - Group transformations cascading to children"
      puts "  - Multiple grouped objects in a single scene"
    end
  end
end
