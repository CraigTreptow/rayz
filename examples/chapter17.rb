#!/usr/bin/env ruby

require_relative "../lib/rayz"

module Rayz
  module Chapter17
    def self.run
      puts "Chapter 17: Smooth Triangles - Smooth shading with normal interpolation"
      puts "=" * 80

      # Create world with light source
      world = World.new
      world.light = PointLight.new(
        position: Point.new(x: -10, y: 10, z: -10),
        intensity: Color.new(red: 1, green: 1, blue: 1)
      )

      # Create a reflective checkerboard floor
      floor = Plane.new
      floor.material.pattern = CheckersPattern.new(
        a: Color.new(red: 0.9, green: 0.9, blue: 0.9),
        b: Color.new(red: 0.1, green: 0.1, blue: 0.1)
      )
      floor.material.ambient = 0.1
      floor.material.diffuse = 0.7
      floor.material.specular = 0.3
      floor.material.reflective = 0.1
      world.objects << floor

      # Left side: Flat shaded triangular pyramid (4 flat triangles)
      # Red face (front)
      t1 = Triangle.new(
        p1: Point.new(x: -3, y: 0, z: -1),
        p2: Point.new(x: -4, y: 0, z: 1),
        p3: Point.new(x: -3.5, y: 2, z: 0)
      )
      t1.material.color = Color.new(red: 1, green: 0, blue: 0)
      t1.material.ambient = 0.2
      t1.material.diffuse = 0.8
      t1.material.specular = 0.4
      t1.material.shininess = 50
      world.objects << t1

      # Green face (right)
      t2 = Triangle.new(
        p1: Point.new(x: -3, y: 0, z: -1),
        p2: Point.new(x: -3.5, y: 2, z: 0),
        p3: Point.new(x: -2, y: 0, z: -1)
      )
      t2.material.color = Color.new(red: 0, green: 1, blue: 0)
      t2.material.ambient = 0.2
      t2.material.diffuse = 0.8
      t2.material.specular = 0.4
      t2.material.shininess = 50
      world.objects << t2

      # Blue face (back)
      t3 = Triangle.new(
        p1: Point.new(x: -2, y: 0, z: -1),
        p2: Point.new(x: -3.5, y: 2, z: 0),
        p3: Point.new(x: -4, y: 0, z: 1)
      )
      t3.material.color = Color.new(red: 0, green: 0, blue: 1)
      t3.material.ambient = 0.2
      t3.material.diffuse = 0.8
      t3.material.specular = 0.4
      t3.material.shininess = 50
      world.objects << t3

      # Yellow face (left)
      t4 = Triangle.new(
        p1: Point.new(x: -4, y: 0, z: 1),
        p2: Point.new(x: -2, y: 0, z: -1),
        p3: Point.new(x: -3.5, y: 2, z: 0)
      )
      t4.material.color = Color.new(red: 1, green: 1, blue: 0)
      t4.material.ambient = 0.2
      t4.material.diffuse = 0.8
      t4.material.specular = 0.4
      t4.material.shininess = 50
      world.objects << t4

      # Right side: Smooth shaded triangular pyramid (4 smooth triangles)
      # Define normals that point outward and are interpolated at vertices
      apex_normal = Vector.new(x: 0, y: 1, z: 0) # Top vertex points up

      # Red face (front) - smooth shaded
      st1 = SmoothTriangle.new(
        p1: Point.new(x: 3, y: 0, z: -1),
        p2: Point.new(x: 2, y: 0, z: 1),
        p3: Point.new(x: 2.5, y: 2, z: 0),
        n1: Vector.new(x: 0.5, y: 0, z: -1).normalize,
        n2: Vector.new(x: -0.5, y: 0, z: 1).normalize,
        n3: apex_normal
      )
      st1.material.color = Color.new(red: 1, green: 0, blue: 0)
      st1.material.ambient = 0.2
      st1.material.diffuse = 0.8
      st1.material.specular = 0.9
      st1.material.shininess = 200
      world.objects << st1

      # Green face (right) - smooth shaded
      st2 = SmoothTriangle.new(
        p1: Point.new(x: 3, y: 0, z: -1),
        p2: Point.new(x: 2.5, y: 2, z: 0),
        p3: Point.new(x: 4, y: 0, z: -1),
        n1: Vector.new(x: 0.5, y: 0, z: -1).normalize,
        n2: apex_normal,
        n3: Vector.new(x: 1, y: 0, z: 0).normalize
      )
      st2.material.color = Color.new(red: 0, green: 1, blue: 0)
      st2.material.ambient = 0.2
      st2.material.diffuse = 0.8
      st2.material.specular = 0.9
      st2.material.shininess = 200
      world.objects << st2

      # Blue face (back) - smooth shaded
      st3 = SmoothTriangle.new(
        p1: Point.new(x: 4, y: 0, z: -1),
        p2: Point.new(x: 2.5, y: 2, z: 0),
        p3: Point.new(x: 2, y: 0, z: 1),
        n1: Vector.new(x: 1, y: 0, z: 0).normalize,
        n2: apex_normal,
        n3: Vector.new(x: -0.5, y: 0, z: 1).normalize
      )
      st3.material.color = Color.new(red: 0, green: 0, blue: 1)
      st3.material.ambient = 0.2
      st3.material.diffuse = 0.8
      st3.material.specular = 0.9
      st3.material.shininess = 200
      world.objects << st3

      # Yellow face (left) - smooth shaded
      st4 = SmoothTriangle.new(
        p1: Point.new(x: 2, y: 0, z: 1),
        p2: Point.new(x: 4, y: 0, z: -1),
        p3: Point.new(x: 2.5, y: 2, z: 0),
        n1: Vector.new(x: -0.5, y: 0, z: 1).normalize,
        n2: Vector.new(x: 1, y: 0, z: 0).normalize,
        n3: apex_normal
      )
      st4.material.color = Color.new(red: 1, green: 1, blue: 0)
      st4.material.ambient = 0.2
      st4.material.diffuse = 0.8
      st4.material.specular = 0.9
      st4.material.shininess = 200
      world.objects << st4

      # Setup camera
      camera = Camera.new(
        hsize: 800,
        vsize: 400,
        field_of_view: Math::PI / 3
      )
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 0, y: 3, z: -8),
        to: Point.new(x: 0, y: 1, z: 0),
        up: Vector.new(x: 0, y: 1, z: 0)
      )

      # Render the scene
      puts "Rendering 800x400 scene..."
      puts "Left: Flat shaded pyramid (regular triangles)"
      puts "Right: Smooth shaded pyramid (smooth triangles)"
      puts "Notice the smooth gradient on the right pyramid vs sharp edges on the left"
      puts

      canvas = camera.render(world)

      # Write to file
      filename = File.join(__dir__, "chapter17.ppm")
      File.write(filename, canvas.to_ppm)

      puts "Complete! Output written to: #{filename}"
      puts "Open the file in an image viewer to see the difference between"
      puts "flat shading (left) and smooth shading (right)."
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end

# Run if executed directly
Rayz::Chapter17.run if __FILE__ == $PROGRAM_NAME
