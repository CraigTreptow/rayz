require_relative "../rayz/ray"
require_relative "../rayz/sphere"
require_relative "../rayz/point"
require_relative "../rayz/vector"
require_relative "../rayz/color"
require_relative "../rayz/canvas"
require_relative "../rayz/intersection"
require_relative "../rayz/material"
require_relative "../rayz/point_light"
require_relative "../rayz/lighting"

module Rayz
  class Chapter6
    def self.run
      puts "\n=== Chapter 6: Light and Shading ==="
      puts "Rendering a 3D sphere with Phong shading\n\n"

      render_shaded_sphere
    end

    def self.render_shaded_sphere
      # Set up canvas and sphere
      canvas_pixels = 400
      canvas = Rayz::Canvas.new(width: canvas_pixels, height: canvas_pixels)

      # Create a sphere with a material
      sphere = Rayz::Sphere.new
      sphere.material.color = Rayz::Color.new(red: 1, green: 0.2, blue: 1)

      # Light source - positioned to the left, above, and behind the viewer
      light_position = Rayz::Point.new(x: -10, y: 10, z: -10)
      light_color = Rayz::Color.new(red: 1, green: 1, blue: 1)
      light = Rayz::PointLight.new(light_position, light_color)

      # Ray origin - the eye is at z = -5
      ray_origin = Rayz::Point.new(x: 0, y: 0, z: -5)

      # Wall is at z = 10
      wall_z = 10
      wall_size = 7.0

      # Pixel size in world space
      pixel_size = wall_size / canvas_pixels
      half = wall_size / 2

      puts "Rendering 3D sphere with Phong shading..."
      puts "Canvas size: #{canvas_pixels}x#{canvas_pixels}"
      puts "Sphere material: purple-ish (R:1, G:0.2, B:1)"
      puts "Light position: #{light_position}"
      puts "Progress (each dot = 10 rows):"

      # For each row of pixels in the canvas
      (0...canvas_pixels).each do |y|
        # Compute the world y coordinate (top = +half, bottom = -half)
        # In canvas coordinates, y increases downward, but in world coordinates, y increases upward
        world_y = half - pixel_size * y

        print "." if y % 10 == 0

        # For each pixel in the row
        (0...canvas_pixels).each do |x|
          # Compute the world x coordinate (left = -half, right = +half)
          world_x = -half + pixel_size * x

          # Describe the point on the wall that the ray will target
          position = Rayz::Point.new(x: world_x, y: world_y, z: wall_z)

          # Create a ray from the eye to the point on the wall
          direction = (position - ray_origin).normalize
          r = Rayz::Ray.new(ray_origin, direction)

          # Find intersections
          xs = sphere.intersect(r)

          # Check if we hit the sphere
          hit = Rayz.hit(xs)

          if hit
            # Calculate the point where the ray hit the sphere
            point = r.position(hit.t)

            # Calculate the normal at the hit point
            normal = hit.object.normal_at(point)

            # Calculate the eye vector (pointing back toward the ray origin)
            eye = -r.direction

            # Calculate the color using Phong shading
            color = Rayz.lighting(hit.object.material, light, point, eye, normal)

            # Write the pixel
            canvas.write_pixel(row: y, col: x, color: color)
          end
        end
      end

      puts "\nDone!"

      # Save to PPM file
      puts "Writing to chapter6.ppm..."
      File.write("chapter6.ppm", canvas.to_ppm)
      puts "Complete! Open chapter6.ppm to see the shaded sphere."
    end
  end
end
