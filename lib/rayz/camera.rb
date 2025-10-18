require "matrix"

module Rayz
  class Camera
    attr_accessor :hsize, :vsize, :field_of_view, :transform, :samples_per_pixel, :aperture_size, :focal_distance, :motion_blur
    attr_reader :pixel_size, :half_width, :half_height

    def initialize(hsize:, vsize:, field_of_view:, samples_per_pixel: 1, aperture_size: 0.0, focal_distance: 1.0, motion_blur: false)
      @hsize = hsize
      @vsize = vsize
      @field_of_view = field_of_view
      @transform = Matrix.identity(4)
      @samples_per_pixel = samples_per_pixel  # For anti-aliasing (supersampling)
      @aperture_size = aperture_size  # For focal blur (depth of field)
      @focal_distance = focal_distance  # Distance to focal plane
      @motion_blur = motion_blur  # Enable motion blur (rays get random time values)

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

    def ray_for_pixel(px, py, pixel_offset_x: 0.5, pixel_offset_y: 0.5, aperture_offset_x: 0.0, aperture_offset_y: 0.0, time: 0.0)
      # Offset from the edge of the canvas to the pixel's position
      # pixel_offset defaults to 0.5 for center, can vary for anti-aliasing
      xoffset = (px + pixel_offset_x) * @pixel_size
      yoffset = (py + pixel_offset_y) * @pixel_size

      # Untransformed coordinates of the pixel in world space
      # (camera looks toward -z, so +x is to the left)
      world_x = @half_width - xoffset
      world_y = @half_height - yoffset

      # Using the camera matrix, transform the canvas point and the origin,
      # and then compute the ray's direction vector
      inverse = @transform.inverse

      # For focal blur, the canvas should be at the focal distance, not at z=-1
      canvas_z = -@focal_distance
      pixel_matrix = inverse * Point.new(x: world_x, y: world_y, z: canvas_z).to_matrix
      pixel = Point.new(x: pixel_matrix[0, 0], y: pixel_matrix[1, 0], z: pixel_matrix[2, 0])

      # For focal blur, rays originate from different points on the aperture
      # aperture_offset_x and aperture_offset_y are in range [-1, 1]
      aperture_x = aperture_offset_x * @aperture_size
      aperture_y = aperture_offset_y * @aperture_size

      origin_matrix = inverse * Point.new(x: aperture_x, y: aperture_y, z: 0).to_matrix
      origin = Point.new(x: origin_matrix[0, 0], y: origin_matrix[1, 0], z: origin_matrix[2, 0])

      direction = (pixel - origin).normalize

      Ray.new(origin: origin, direction: direction, time: time)
    end

    def render(world)
      image = Canvas.new(width: @hsize, height: @vsize)

      start_time = Time.now
      puts "Progress (each dot = 10 rows):"
      (0...@vsize).each do |y|
        print "." if y % 10 == 0

        (0...@hsize).each do |x|
          color = render_pixel(x, y, world)
          # Canvas has origin at bottom-left, so invert y coordinate
          image.write_pixel(row: @vsize - 1 - y, col: x, color: color)
        end
      end
      end_time = Time.now

      total_time = end_time - start_time
      time_per_row = total_time / @vsize

      puts "\nDone!"
      puts "Rendering took #{total_time.round(2)} seconds"
      puts "Time per row: #{(time_per_row * 1000).round(2)} ms"

      image
    end

    private

    def render_pixel(px, py, world)
      # For single sample without special effects, use original behavior
      if @samples_per_pixel == 1 && @aperture_size == 0.0 && !@motion_blur
        ray = ray_for_pixel(px, py)
        return world.color_at(ray)
      end

      # Multiple samples for anti-aliasing, focal blur, and/or motion blur
      colors = []
      @samples_per_pixel.times do
        # Random offset within pixel for anti-aliasing
        pixel_offset_x = rand
        pixel_offset_y = rand

        # Random offset within aperture for focal blur
        aperture_offset_x = (@aperture_size > 0) ? (rand * 2 - 1) : 0.0
        aperture_offset_y = (@aperture_size > 0) ? (rand * 2 - 1) : 0.0

        # Random time value for motion blur (between 0.0 and 1.0)
        time = @motion_blur ? rand : 0.0

        ray = ray_for_pixel(px, py,
          pixel_offset_x: pixel_offset_x,
          pixel_offset_y: pixel_offset_y,
          aperture_offset_x: aperture_offset_x,
          aperture_offset_y: aperture_offset_y,
          time: time)

        colors << world.color_at(ray)
      end

      # Average all sampled colors
      avg_red = colors.map(&:red).sum / colors.size.to_f
      avg_green = colors.map(&:green).sum / colors.size.to_f
      avg_blue = colors.map(&:blue).sum / colors.size.to_f

      Color.new(red: avg_red, green: avg_green, blue: avg_blue)
    end
  end
end
