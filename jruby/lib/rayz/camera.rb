require "matrix"
require "etc"

$stdout.sync = true

module Rayz
  class Camera
    attr_accessor :hsize, :vsize, :field_of_view, :samples_per_pixel, :aperture_size, :focal_distance, :motion_blur
    attr_reader :pixel_size, :half_width, :half_height, :transform

    def initialize(hsize:, vsize:, field_of_view:, samples_per_pixel: 1, aperture_size: 0.0, focal_distance: 1.0, motion_blur: false)
      @hsize = hsize
      @vsize = vsize
      @field_of_view = field_of_view
      @samples_per_pixel = samples_per_pixel
      @aperture_size = aperture_size
      @focal_distance = focal_distance
      @motion_blur = motion_blur
      self.transform = Matrix.identity(4)
      calculate_pixel_size
    end

    def transform=(matrix)
      @transform = matrix
      @transform_inverse = matrix.inverse
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

      inverse = @transform_inverse

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

    def render(world, parallel: true)
      case parallel
      when :ractor then render_ractor(world)
      when true then render_parallel(world)
      else render_sequential(world)
      end
    end

    def render_sequential(world)
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

    def render_parallel(world)
      image = Canvas.new(width: @hsize, height: @vsize)
      pixels = image.pixels

      start_time = Time.now
      cpu_count = Etc.nprocessors
      puts "Rendering with #{cpu_count} CPU cores (Thread-based parallelism):"
      puts "Progress (each dot = 10 rows):"

      progress_mutex = Mutex.new
      completed_rows = 0

      rows = (0...@vsize).to_a
      threads = cpu_count.times.map do |thread_id|
        Thread.new do
          # Round-robin row distribution: each thread owns non-overlapping rows,
          # so direct array writes are safe without per-pixel mutex acquisition.
          rows.each_with_index do |y, idx|
            next unless idx % cpu_count == thread_id

            canvas_row = @vsize - 1 - y
            row_pixels = pixels[canvas_row]

            (0...@hsize).each do |x|
              row_pixels[x] = render_pixel(x, y, world)
            end

            progress_mutex.synchronize do
              completed_rows += 1
              print "." if completed_rows % 10 == 0
            end
          end
        end
      end

      threads.each(&:join)

      end_time = Time.now
      total_time = end_time - start_time
      time_per_row = total_time / @vsize

      puts "\nDone!"
      puts "Rendering took #{total_time.round(2)} seconds (#{cpu_count} threads)"
      puts "Time per row: #{(time_per_row * 1000).round(2)} ms"

      image
    end

    # JRuby has real OS threads (no GIL), so render_parallel already gives
    # true CPU parallelism. Ractor is MRI-only; alias to render_parallel.
    alias render_ractor render_parallel

    private

    def render_pixel(px, py, world)
      # For single sample without special effects, use original behavior
      if @samples_per_pixel == 1 && @aperture_size == 0.0 && !@motion_blur
        ray = ray_for_pixel(px, py)
        return world.color_at(ray)
      end

      # Multiple samples for anti-aliasing, focal blur, and/or motion blur
      # Accumulate color components directly (no array allocation)
      total_red = 0.0
      total_green = 0.0
      total_blue = 0.0

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

        color = world.color_at(ray)
        total_red += color.red
        total_green += color.green
        total_blue += color.blue
      end

      # Average all sampled colors
      divisor = @samples_per_pixel.to_f
      Color.new(red: total_red / divisor, green: total_green / divisor, blue: total_blue / divisor)
    end
  end
end
