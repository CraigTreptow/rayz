require_relative "../rayz/point"
require_relative "../rayz/vector"
require_relative "../rayz/color"
require_relative "../rayz/canvas"
require_relative "../rayz/util"
require "matrix"

module Rayz
  class Chapter3
    def self.run
      puts "\n=== Chapter 3: Matrices ==="
      puts "Demonstrating matrix operations and transformations\n\n"

      # Demo 1: Basic matrix operations
      demo_basic_operations

      # Demo 2: Matrix inversion
      demo_matrix_inversion

      # Demo 3: Visual demonstration - draw a clock face using rotation matrices
      demo_clock_face
    end

    def self.demo_basic_operations
      puts "1. Basic Matrix Operations"
      puts "-" * 40

      # Create a simple transformation matrix
      m = Matrix[[1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 8, 7, 6],
        [5, 4, 3, 2]]

      puts "Original Matrix M:"
      print_matrix(m)

      # Transpose
      puts "\nTranspose of M:"
      print_matrix(m.transpose)

      # Determinant
      puts "\nDeterminant of M: #{m.determinant.round(2)}"

      # Identity matrix
      identity = Matrix.identity(4)
      puts "\nM * Identity = M (verification):"
      result = m * identity
      puts "Result equals M: #{result == m}"
      puts ""
    end

    def self.demo_matrix_inversion
      puts "\n2. Matrix Inversion"
      puts "-" * 40

      # Create an invertible matrix
      m = Matrix[[3, -9, 7, 3],
        [3, -8, 2, -9],
        [-4, 4, 4, 1],
        [-6, 5, -1, 1]]

      puts "Matrix A:"
      print_matrix(m)

      puts "\nDeterminant: #{m.determinant.round(2)}"
      puts "Is invertible: #{m.determinant != 0}"

      inverse = m.inverse
      puts "\nInverse of A:"
      print_matrix(inverse, precision: 5)

      # Verify: A * inverse(A) = Identity
      product = m * inverse
      puts "\nVerification: A * inverse(A) = Identity"
      print_matrix(product, precision: 5)
      puts ""
    end

    def self.demo_clock_face
      puts "\n3. Clock Face Visualization"
      puts "-" * 40
      puts "Drawing a clock using rotation matrices..."

      canvas = Rayz::Canvas.new(width: 400, height: 400)
      white = Rayz::Color.new(red: 1.0, green: 1.0, blue: 1.0)

      # Center of canvas
      center_x = 200
      center_y = 200
      radius = 150

      # Draw 12 hour marks
      12.times do |hour|
        # Rotation angle in radians
        angle = hour * Math::PI / 6.0 # 30 degrees per hour

        # Create a point at 12 o'clock position (straight up)
        twelve_oclock = Rayz::Point.new(x: 0, y: 0, z: radius)

        # Rotation matrix around Y axis (rotates in XZ plane)
        # We'll rotate around the origin, then translate to center
        cos_a = Math.cos(angle)
        sin_a = Math.sin(angle)

        rotation = Matrix[
          [cos_a, 0, sin_a, 0],
          [0, 1, 0, 0],
          [-sin_a, 0, cos_a, 0],
          [0, 0, 0, 1]
        ]

        # Apply rotation to the point
        point_vector = twelve_oclock.to_matrix
        rotated = rotation * point_vector

        # Extract x and z coordinates (we're rotating in the XZ plane, viewing from above)
        x = rotated[0, 0].round
        z = rotated[2, 0].round

        # Translate to canvas center
        canvas_x = center_x + x
        canvas_y = center_y + z

        # Draw a small cluster of pixels for each hour mark
        (-2..2).each do |dx|
          (-2..2).each do |dy|
            px = canvas_x + dx
            py = canvas_y + dy
            canvas.write_pixel(row: py, col: px, color: white) if px >= 0 && px < 400 && py >= 0 && py < 400
          end
        end
      end

      file_name = "chapter3_clock.ppm"
      print "Writing clock face to #{file_name}..."
      File.write(file_name, canvas.to_ppm)
      puts " Done!"
      puts "A clock face with 12 marks has been drawn using rotation matrices."
      puts ""
    end

    def self.print_matrix(matrix, precision: 2)
      matrix.row_vectors.each do |row|
        values = row.to_a.map { |v| sprintf("%#{precision + 3}.#{precision}f", v) }
        puts "  [#{values.join("  ")}]"
      end
    end
  end
end
