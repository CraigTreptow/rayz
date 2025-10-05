require "matrix"

module Rayz
  class Camera
    attr_accessor :hsize, :vsize, :field_of_view, :transform
    attr_reader :pixel_size, :half_width, :half_height

    def initialize(hsize, vsize, field_of_view)
      @hsize = hsize
      @vsize = vsize
      @field_of_view = field_of_view
      @transform = Matrix.identity(4)

      calculate_pixel_size
    end

    def calculate_pixel_size
      half_view = Math.tan(@field_of_view / 2.0)
      aspect = @hsize.to_f / @vsize.to_f

      if aspect >= 1
        @half_width = half_view
        @half_height = half_view / aspect
      else
        @half_width = half_view * aspect
        @half_height = half_view
      end

      @pixel_size = (@half_width * 2) / @hsize
    end

    def ray_for_pixel(px, py)
      # Offset from the edge of the canvas to the pixel's center
      xoffset = (px + 0.5) * @pixel_size
      yoffset = (py + 0.5) * @pixel_size

      # Untransformed coordinates of the pixel in world space
      # (camera looks toward -z, so +x is to the left)
      world_x = @half_width - xoffset
      world_y = @half_height - yoffset

      # Using the camera matrix, transform the canvas point and the origin,
      # and then compute the ray's direction vector
      # (canvas is at z=-1)
      inverse = @transform.inverse
      pixel_matrix = inverse * Point.new(x: world_x, y: world_y, z: -1).to_matrix
      pixel = Point.new(x: pixel_matrix[0, 0], y: pixel_matrix[1, 0], z: pixel_matrix[2, 0])

      origin_matrix = inverse * Point.new(x: 0, y: 0, z: 0).to_matrix
      origin = Point.new(x: origin_matrix[0, 0], y: origin_matrix[1, 0], z: origin_matrix[2, 0])

      direction = (pixel - origin).normalize

      Ray.new(origin, direction)
    end

    def render(world)
      image = Canvas.new(width: @hsize, height: @vsize)

      (0...@vsize).each do |y|
        (0...@hsize).each do |x|
          ray = ray_for_pixel(x, y)
          color = world.color_at(ray)
          image.write_pixel(row: y, col: x, color: color)
        end
      end

      image
    end
  end
end
