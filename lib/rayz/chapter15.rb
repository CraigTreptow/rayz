require "async"
require_relative "world"
require_relative "camera"
require_relative "transformations"
require_relative "point_light"
require_relative "triangle"
require_relative "plane"
require_relative "sphere"

module Rayz
  module Chapter15
    def self.run
      puts "Chapter 15: Triangles"
      puts "Rendering scene with triangles (800x600 pixels)..."
      puts "Features:"
      puts "  - Triangle primitive with Möller-Trumbore intersection"
      puts "  - Creating complex shapes from triangles"
      puts "  - Flat shading with constant normals"
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

      # Create a pyramid from 4 triangles
      pyramid_height = 2.0
      base_size = 1.5

      # Base vertices
      p1 = Point.new(x: -base_size, y: 0, z: -base_size)
      p2 = Point.new(x: base_size, y: 0, z: -base_size)
      p3 = Point.new(x: base_size, y: 0, z: base_size)
      p4 = Point.new(x: -base_size, y: 0, z: base_size)
      # Apex
      apex = Point.new(x: 0, y: pyramid_height, z: 0)

      # Create 4 triangular faces
      face1 = Triangle.new(p1: p1, p2: p2, p3: apex)
      face1.transform = Transformations.translation(x: -3, y: 0, z: 0)
      face1.material.color = Color.new(red: 1, green: 0.3, blue: 0.3)
      face1.material.ambient = 0.2
      face1.material.diffuse = 0.7
      face1.material.specular = 0.3
      world.objects << face1

      face2 = Triangle.new(p1: p2, p2: p3, p3: apex)
      face2.transform = Transformations.translation(x: -3, y: 0, z: 0)
      face2.material.color = Color.new(red: 0.3, green: 1, blue: 0.3)
      face2.material.ambient = 0.2
      face2.material.diffuse = 0.7
      face2.material.specular = 0.3
      world.objects << face2

      face3 = Triangle.new(p1: p3, p2: p4, p3: apex)
      face3.transform = Transformations.translation(x: -3, y: 0, z: 0)
      face3.material.color = Color.new(red: 0.3, green: 0.3, blue: 1)
      face3.material.ambient = 0.2
      face3.material.diffuse = 0.7
      face3.material.specular = 0.3
      world.objects << face3

      face4 = Triangle.new(p1: p4, p2: p1, p3: apex)
      face4.transform = Transformations.translation(x: -3, y: 0, z: 0)
      face4.material.color = Color.new(red: 1, green: 1, blue: 0.3)
      face4.material.ambient = 0.2
      face4.material.diffuse = 0.7
      face4.material.specular = 0.3
      world.objects << face4

      # Create an octahedron (8 triangles) at center
      size = 1.2
      top = Point.new(x: 0, y: size, z: 0)
      bottom = Point.new(x: 0, y: -size, z: 0)
      front = Point.new(x: 0, y: 0, z: size)
      back = Point.new(x: 0, y: 0, z: -size)
      left = Point.new(x: -size, y: 0, z: 0)
      right = Point.new(x: size, y: 0, z: 0)

      octahedron_transform = Transformations.translation(x: 0, y: 1.5, z: 0) *
        Transformations.rotation_y(radians: Math::PI / 4)

      # Top 4 faces
      oct1 = Triangle.new(p1: top, p2: front, p3: right)
      oct1.transform = octahedron_transform
      oct1.material.color = Color.new(red: 0.8, green: 0.2, blue: 0.8)
      oct1.material.ambient = 0.1
      oct1.material.diffuse = 0.7
      oct1.material.specular = 0.5
      oct1.material.shininess = 50
      world.objects << oct1

      oct2 = Triangle.new(p1: top, p2: right, p3: back)
      oct2.transform = octahedron_transform
      oct2.material.color = Color.new(red: 0.6, green: 0.2, blue: 0.8)
      oct2.material.ambient = 0.1
      oct2.material.diffuse = 0.7
      oct2.material.specular = 0.5
      oct2.material.shininess = 50
      world.objects << oct2

      oct3 = Triangle.new(p1: top, p2: back, p3: left)
      oct3.transform = octahedron_transform
      oct3.material.color = Color.new(red: 0.4, green: 0.2, blue: 0.8)
      oct3.material.ambient = 0.1
      oct3.material.diffuse = 0.7
      oct3.material.specular = 0.5
      oct3.material.shininess = 50
      world.objects << oct3

      oct4 = Triangle.new(p1: top, p2: left, p3: front)
      oct4.transform = octahedron_transform
      oct4.material.color = Color.new(red: 0.2, green: 0.2, blue: 0.8)
      oct4.material.ambient = 0.1
      oct4.material.diffuse = 0.7
      oct4.material.specular = 0.5
      oct4.material.shininess = 50
      world.objects << oct4

      # Bottom 4 faces
      oct5 = Triangle.new(p1: bottom, p2: right, p3: front)
      oct5.transform = octahedron_transform
      oct5.material.color = Color.new(red: 0.8, green: 0.4, blue: 0.6)
      oct5.material.ambient = 0.1
      oct5.material.diffuse = 0.7
      oct5.material.specular = 0.5
      oct5.material.shininess = 50
      world.objects << oct5

      oct6 = Triangle.new(p1: bottom, p2: back, p3: right)
      oct6.transform = octahedron_transform
      oct6.material.color = Color.new(red: 0.6, green: 0.4, blue: 0.6)
      oct6.material.ambient = 0.1
      oct6.material.diffuse = 0.7
      oct6.material.specular = 0.5
      oct6.material.shininess = 50
      world.objects << oct6

      oct7 = Triangle.new(p1: bottom, p2: left, p3: back)
      oct7.transform = octahedron_transform
      oct7.material.color = Color.new(red: 0.4, green: 0.4, blue: 0.6)
      oct7.material.ambient = 0.1
      oct7.material.diffuse = 0.7
      oct7.material.specular = 0.5
      oct7.material.shininess = 50
      world.objects << oct7

      oct8 = Triangle.new(p1: bottom, p2: front, p3: left)
      oct8.transform = octahedron_transform
      oct8.material.color = Color.new(red: 0.2, green: 0.4, blue: 0.6)
      oct8.material.ambient = 0.1
      oct8.material.diffuse = 0.7
      oct8.material.specular = 0.5
      oct8.material.shininess = 50
      world.objects << oct8

      # Create a tetrahedron (4 triangles) on the right
      tet_size = 1.3
      tet_p1 = Point.new(x: 0, y: 0, z: -tet_size)
      tet_p2 = Point.new(x: -tet_size, y: 0, z: tet_size)
      tet_p3 = Point.new(x: tet_size, y: 0, z: tet_size)
      tet_apex = Point.new(x: 0, y: tet_size * Math.sqrt(3), z: 0)

      tet_transform = Transformations.translation(x: 3, y: 0, z: 0)

      tet1 = Triangle.new(p1: tet_p1, p2: tet_p2, p3: tet_p3)
      tet1.transform = tet_transform
      tet1.material.color = Color.new(red: 0.9, green: 0.9, blue: 0.2)
      tet1.material.ambient = 0.2
      tet1.material.diffuse = 0.7
      tet1.material.specular = 0.3
      world.objects << tet1

      tet2 = Triangle.new(p1: tet_p1, p2: tet_p3, p3: tet_apex)
      tet2.transform = tet_transform
      tet2.material.color = Color.new(red: 0.2, green: 0.9, blue: 0.9)
      tet2.material.ambient = 0.2
      tet2.material.diffuse = 0.7
      tet2.material.specular = 0.3
      world.objects << tet2

      tet3 = Triangle.new(p1: tet_p2, p2: tet_p1, p3: tet_apex)
      tet3.transform = tet_transform
      tet3.material.color = Color.new(red: 0.9, green: 0.2, blue: 0.9)
      tet3.material.ambient = 0.2
      tet3.material.diffuse = 0.7
      tet3.material.specular = 0.3
      world.objects << tet3

      tet4 = Triangle.new(p1: tet_p3, p2: tet_p2, p3: tet_apex)
      tet4.transform = tet_transform
      tet4.material.color = Color.new(red: 0.9, green: 0.9, blue: 0.9)
      tet4.material.ambient = 0.2
      tet4.material.diffuse = 0.7
      tet4.material.specular = 0.3
      world.objects << tet4

      # Add a comparison sphere
      sphere = Sphere.new
      sphere.transform = Transformations.translation(x: 0, y: 1, z: -3) *
        Transformations.scaling(x: 0.8, y: 0.8, z: 0.8)
      sphere.material.color = Color.new(red: 0.7, green: 0.7, blue: 0.7)
      sphere.material.reflective = 0.3
      world.objects << sphere

      # Camera
      camera = Camera.new(hsize: 800, vsize: 600, field_of_view: Math::PI / 3)
      camera.transform = Transformations.view_transform(
        from: Point.new(x: 8, y: 5, z: -8),
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
      puts "Writing to chapter15.ppm..."
      File.write("chapter15.ppm", image.to_ppm)
      puts "Scene rendered to chapter15.ppm"
    end
  end
end
