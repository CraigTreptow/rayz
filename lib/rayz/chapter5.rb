require_relative "../rayz/ray"
require_relative "../rayz/sphere"
require_relative "../rayz/point"
require_relative "../rayz/vector"
require_relative "../rayz/color"
require_relative "../rayz/canvas"
require_relative "../rayz/intersection"
require "matrix"

module Rayz
  class Chapter5
    def self.run
      puts "\n=== Chapter 5: Ray-Sphere Intersections ==="
      puts "Demonstrating ray casting and sphere intersection\n\n"

      # Demo 1: Basic ray-sphere intersection
      demo_basic_intersection

      # Demo 2: Ray transformations
      demo_ray_transformations

      # Demo 3: Render a sphere silhouette
      demo_sphere_silhouette
    end

    def self.demo_basic_intersection
      puts "1. Basic Ray-Sphere Intersection"
      puts "-" * 40

      # Ray from the origin pointing forward
      ray = Rayz::Ray.new(
        Rayz::Point.new(x: 0, y: 0, z: -5),
        Rayz::Vector.new(x: 0, y: 0, z: 1)
      )

      # Unit sphere at the origin
      sphere = Rayz::Sphere.new

      # Find intersections
      xs = sphere.intersect(ray)

      puts "Ray origin: (0, 0, -5)"
      puts "Ray direction: (0, 0, 1)"
      puts "Sphere: Unit sphere at origin"
      puts "Intersections: #{xs.count}"
      xs.each_with_index do |i, idx|
        puts "  [#{idx}] t = #{i.t}"
      end
      puts ""
    end

    def self.demo_ray_transformations
      puts "\n2. Ray Transformations"
      puts "-" * 40

      ray = Rayz::Ray.new(
        Rayz::Point.new(x: 1, y: 2, z: 3),
        Rayz::Vector.new(x: 0, y: 1, z: 0)
      )

      # Translate the ray
      translation = Rayz::Transformations.translation(3, 4, 5)
      ray2 = ray.transform(translation)

      puts "Original ray:"
      puts "  Origin: (#{ray.origin.x}, #{ray.origin.y}, #{ray.origin.z})"
      puts "  Direction: (#{ray.direction.x}, #{ray.direction.y}, #{ray.direction.z})"
      puts "\nAfter translation(3, 4, 5):"
      puts "  Origin: (#{ray2.origin.x}, #{ray2.origin.y}, #{ray2.origin.z})"
      puts "  Direction: (#{ray2.direction.x}, #{ray2.direction.y}, #{ray2.direction.z})"

      # Scale the ray
      scaling = Rayz::Transformations.scaling(2, 3, 4)
      ray3 = ray.transform(scaling)

      puts "\nAfter scaling(2, 3, 4):"
      puts "  Origin: (#{ray3.origin.x}, #{ray3.origin.y}, #{ray3.origin.z})"
      puts "  Direction: (#{ray3.direction.x}, #{ray3.direction.y}, #{ray3.direction.z})"
      puts ""
    end

    def self.demo_sphere_silhouette
      puts "\n3. Sphere Silhouette Rendering"
      puts "-" * 40
      puts "Rendering a sphere using ray casting..."

      # Canvas setup
      canvas_pixels = 200
      canvas = Rayz::Canvas.new(width: canvas_pixels, height: canvas_pixels)

      # Sphere at origin
      sphere = Rayz::Sphere.new

      # Apply scaling to make it slightly elongated
      sphere.transform = Rayz::Transformations.scaling(1, 0.5, 1)

      # Ray origin - camera position
      ray_origin = Rayz::Point.new(x: 0, y: 0, z: -5)

      # Wall setup
      wall_z = 10.0
      wall_size = 7.0
      pixel_size = wall_size / canvas_pixels
      half = wall_size / 2.0

      # Color
      red = Rayz::Color.new(red: 1.0, green: 0.0, blue: 0.0)

      # For each pixel on the canvas
      canvas_pixels.times do |y|
        # Convert canvas y to world y
        world_y = half - pixel_size * y

        canvas_pixels.times do |x|
          # Convert canvas x to world x
          world_x = -half + pixel_size * x

          # Point on the wall that the ray will target
          position = Rayz::Point.new(x: world_x, y: world_y, z: wall_z)

          # Ray from camera to wall point
          direction = (position - ray_origin).normalize
          ray = Rayz::Ray.new(ray_origin, direction)

          # Check for intersections
          xs = sphere.intersect(ray)

          # If we hit the sphere, color the pixel
          unless xs.empty?
            hit = Rayz.hit(xs)
            canvas.write_pixel(row: y, col: x, color: red) if hit
          end
        end
      end

      file_name = "chapter5_sphere.ppm"
      print "Writing sphere silhouette to #{file_name}..."
      File.write(file_name, canvas.to_ppm)
      puts " Done!"
      puts "A red sphere silhouette has been rendered using ray casting."
      puts "The sphere is scaled to be flattened (y = 0.5) to demonstrate transformations."
      puts "\n" + ("=" * 60) + "\n"
    end
  end
end
