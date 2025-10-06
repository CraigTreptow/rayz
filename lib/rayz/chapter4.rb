require_relative "../rayz/point"
require_relative "../rayz/vector"
require_relative "../rayz/color"
require_relative "../rayz/canvas"
require_relative "../rayz/transformations"
require "matrix"

module Rayz
  class Chapter4
    def self.run
      puts "\n=== Chapter 4: Matrix Transformations ==="
      puts "Demonstrating translation, scaling, rotation, and shearing\n\n"

      # Demo 1: Translation
      demo_translation

      # Demo 2: Scaling and reflection
      demo_scaling

      # Demo 3: Rotation
      demo_rotation

      # Demo 4: Shearing
      demo_shearing

      # Demo 5: Chaining transformations
      demo_chaining

      # Demo 6: Visual demonstration - analog clock with transformed markers
      demo_analog_clock
    end

    def self.demo_translation
      puts "1. Translation"
      puts "-" * 40

      transform = Rayz::Transformations.translation(x: 5, y: -3, z: 2)
      p = Rayz::Point.new(x: -3, y: 4, z: 5)

      result = Rayz::Util.matrix_multiplied_by_tuple(transform, p)
      puts "Point: #{p}"
      puts "Translation(5, -3, 2)"
      puts "Result: #{result}"

      # Translation doesn't affect vectors
      v = Rayz::Vector.new(x: -3, y: 4, z: 5)
      v_result = Rayz::Util.matrix_multiplied_by_tuple(transform, v)
      puts "\nVector: #{v}"
      puts "Translation(5, -3, 2)"
      puts "Result: #{v_result} (unchanged - vectors are not affected by translation)"
      puts ""
    end

    def self.demo_scaling
      puts "\n2. Scaling and Reflection"
      puts "-" * 40

      # Scaling
      transform = Rayz::Transformations.scaling(x: 2, y: 3, z: 4)
      p = Rayz::Point.new(x: -4, y: 6, z: 8)
      result = Rayz::Util.matrix_multiplied_by_tuple(transform, p)

      puts "Point: #{p}"
      puts "Scaling(2, 3, 4)"
      puts "Result: #{result}"

      # Reflection (negative scaling)
      reflect = Rayz::Transformations.scaling(x: -1, y: 1, z: 1)
      p2 = Rayz::Point.new(x: 2, y: 3, z: 4)
      result2 = Rayz::Util.matrix_multiplied_by_tuple(reflect, p2)

      puts "\nPoint: #{p2}"
      puts "Scaling(-1, 1, 1) - reflection across YZ plane"
      puts "Result: #{result2}"
      puts ""
    end

    def self.demo_rotation
      puts "\n3. Rotation"
      puts "-" * 40

      # Rotation around X axis
      p = Rayz::Point.new(x: 0, y: 1, z: 0)
      rotation = Rayz::Transformations.rotation_x(radians: Math::PI / 4)
      result = Rayz::Util.matrix_multiplied_by_tuple(rotation, p)

      puts "Point: #{p}"
      puts "Rotation around X axis (π/4 radians = 45 degrees)"
      puts "Result: (#{result.x.round(5)}, #{result.y.round(5)}, #{result.z.round(5)})"

      # Full quarter rotation
      rotation_90 = Rayz::Transformations.rotation_x(radians: Math::PI / 2)
      result_90 = Rayz::Util.matrix_multiplied_by_tuple(rotation_90, p)
      puts "\nRotation around X axis (π/2 radians = 90 degrees)"
      puts "Result: (#{result_90.x.round(5)}, #{result_90.y.round(5)}, #{result_90.z.round(5)})"
      puts ""
    end

    def self.demo_shearing
      puts "\n4. Shearing"
      puts "-" * 40

      p = Rayz::Point.new(x: 2, y: 3, z: 4)

      # Shear x in proportion to y
      transform = Rayz::Transformations.shearing(xy: 1, xz: 0, yx: 0, yz: 0, zx: 0, zy: 0)
      result = Rayz::Util.matrix_multiplied_by_tuple(transform, p)

      puts "Point: #{p}"
      puts "Shearing(1, 0, 0, 0, 0, 0) - x moves in proportion to y"
      puts "Result: #{result} (x became #{p.x} + #{p.y} = #{result.x})"

      # Shear y in proportion to z
      transform2 = Rayz::Transformations.shearing(xy: 0, xz: 0, yx: 0, yz: 1, zx: 0, zy: 0)
      result2 = Rayz::Util.matrix_multiplied_by_tuple(transform2, p)

      puts "\nShearing(0, 0, 0, 1, 0, 0) - y moves in proportion to z"
      puts "Result: #{result2} (y became #{p.y} + #{p.z} = #{result2.y})"
      puts ""
    end

    def self.demo_chaining
      puts "\n5. Chaining Transformations"
      puts "-" * 40

      p = Rayz::Point.new(x: 1, y: 0, z: 1)
      puts "Starting point: #{p}"

      # Apply transformations in sequence
      rotation = Rayz::Transformations.rotation_x(radians: Math::PI / 2)
      p2 = Rayz::Util.matrix_multiplied_by_tuple(rotation, p)
      puts "After rotation X (π/2): (#{p2.x.round(5)}, #{p2.y.round(5)}, #{p2.z.round(5)})"

      scaling = Rayz::Transformations.scaling(x: 5, y: 5, z: 5)
      p3 = Rayz::Util.matrix_multiplied_by_tuple(scaling, p2)
      puts "After scaling(5, 5, 5): (#{p3.x.round(5)}, #{p3.y.round(5)}, #{p3.z.round(5)})"

      translation = Rayz::Transformations.translation(x: 10, y: 5, z: 7)
      p4 = Rayz::Util.matrix_multiplied_by_tuple(translation, p3)
      puts "After translation(10, 5, 7): (#{p4.x.round(5)}, #{p4.y.round(5)}, #{p4.z.round(5)})"

      # Same result with chained matrix multiplication (applied in reverse order)
      chained = translation * scaling * rotation
      result = Rayz::Util.matrix_multiplied_by_tuple(chained, p)
      puts "\nChained transformation (T * S * R):"
      puts "Result: (#{result.x.round(5)}, #{result.y.round(5)}, #{result.z.round(5)})"
      puts "Results match: #{result == p4}"
      puts ""
    end

    def self.demo_analog_clock
      puts "\n6. Analog Clock Visualization"
      puts "-" * 40
      puts "Creating an analog clock face using transformations..."

      canvas = Rayz::Canvas.new(width: 500, height: 500)
      white = Rayz::Color.new(red: 1.0, green: 1.0, blue: 1.0)
      red = Rayz::Color.new(red: 1.0, green: 0.0, blue: 0.0)
      yellow = Rayz::Color.new(red: 1.0, green: 1.0, blue: 0.0)

      Rayz::Point.new(x: 0, y: 0, z: 0)
      radius = 180

      # Draw 12 hour markers
      12.times do |hour|
        # Start with a point at 12 o'clock (straight up on Z axis)
        twelve = Rayz::Point.new(x: 0, y: 0, z: radius)

        # Rotate around Y axis to position this hour
        # Y-axis rotation moves points in the XZ plane
        angle = hour * (Math::PI / 6.0) # 30 degrees per hour
        rotation = Rayz::Transformations.rotation_y(radians: angle)

        # Apply rotation
        position = Rayz::Util.matrix_multiplied_by_tuple(rotation, twelve)

        # Translate to canvas coordinates (center at 250, 250)
        canvas_x = 250 + position.x.round
        canvas_y = 250 + position.z.round

        # Use different colors for special hours
        color = case hour
        when 0 # 12 o'clock
          red
        when 3, 6, 9 # Quarter hours
          yellow
        else
          white
        end

        # Draw hour marker (larger cluster of pixels)
        size = (hour % 3 == 0) ? 4 : 3 # Larger markers for 12, 3, 6, 9
        (-size..size).each do |dx|
          (-size..size).each do |dy|
            px = canvas_x + dx
            py = canvas_y + dy
            # Draw circular markers
            if dx * dx + dy * dy <= size * size
              canvas.write_pixel(row: py, col: px, color: color) if px >= 0 && px < 500 && py >= 0 && py < 500
            end
          end
        end
      end

      # Draw clock hands using scaling and rotation
      # Hour hand (pointing to 3 o'clock - 90 degrees)
      hour_hand_length = 100
      hour_hand = Rayz::Point.new(x: 0, y: 0, z: hour_hand_length)
      hour_rotation = Rayz::Transformations.rotation_y(radians: Math::PI / 2) # 90 degrees
      hour_tip = Rayz::Util.matrix_multiplied_by_tuple(hour_rotation, hour_hand)

      # Draw hour hand as a line
      draw_line(canvas, 250, 250, 250 + hour_tip.x.round, 250 + hour_tip.z.round, red)

      # Minute hand (pointing to 12 o'clock)
      minute_hand_length = 150
      minute_hand = Rayz::Point.new(x: 0, y: 0, z: minute_hand_length)
      minute_tip = minute_hand # No rotation - pointing up

      # Draw minute hand as a line
      draw_line(canvas, 250, 250, 250 + minute_tip.x.round, 250 + minute_tip.z.round, white)

      file_name = "chapter4_clock.ppm"
      print "Writing analog clock to #{file_name}..."
      File.write(file_name, canvas.to_ppm)
      puts " Done!"
      puts "An analog clock showing 3:00 has been created using transformations."
      puts "The clock demonstrates rotation and scaling transformations."
      puts "\n" + ("=" * 60) + "\n"
    end

    # Helper method to draw a line using Bresenham's algorithm
    def self.draw_line(canvas, x0, y0, x1, y1, color)
      dx = (x1 - x0).abs
      dy = (y1 - y0).abs
      sx = (x0 < x1) ? 1 : -1
      sy = (y0 < y1) ? 1 : -1
      err = dx - dy

      loop do
        canvas.write_pixel(row: y0, col: x0, color: color) if x0 >= 0 && x0 < canvas.width && y0 >= 0 && y0 < canvas.height

        break if x0 == x1 && y0 == y1

        e2 = 2 * err
        if e2 > -dy
          err -= dy
          x0 += sx
        end
        if e2 < dx
          err += dx
          y0 += sy
        end
      end
    end
  end
end
