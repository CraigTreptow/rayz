require "matrix"
require "etc"

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

      start_time = Time.now
      cpu_count = Etc.nprocessors
      puts "Rendering with #{cpu_count} CPU cores (Thread-based parallelism):"
      puts "Progress (each dot = 10 rows):"

      # Thread-safe progress counter
      progress_mutex = Mutex.new
      completed_rows = 0

      # Distribute rows among threads
      rows = (0...@vsize).to_a
      threads = []

      cpu_count.times do |thread_id|
        threads << Thread.new do
          # Each thread processes every Nth row (round-robin distribution)
          rows.each_with_index do |y, idx|
            next unless idx % cpu_count == thread_id

            # Render entire row
            (0...@hsize).each do |x|
              color = render_pixel(x, y, world)
              # Canvas.write_pixel already has mutex protection
              image.write_pixel(row: @vsize - 1 - y, col: x, color: color)
            end

            # Update progress (thread-safe)
            progress_mutex.synchronize do
              completed_rows += 1
              print "." if completed_rows % 10 == 0
            end
          end
        end
      end

      # Wait for all threads to complete
      threads.each(&:join)

      end_time = Time.now
      total_time = end_time - start_time
      time_per_row = total_time / @vsize

      puts "\nDone!"
      puts "Rendering took #{total_time.round(2)} seconds (#{cpu_count} threads)"
      puts "Time per row: #{(time_per_row * 1000).round(2)} ms"

      image
    end

    def render_ractor(world)
      image = Canvas.new(width: @hsize, height: @vsize)
      cpu_count = Etc.nprocessors
      start_time = Time.now

      puts "Rendering with #{cpu_count} CPU cores (Ractor-based parallelism):"
      puts "Progress (each dot = completed chunk):"

      # Deep-freeze the scene graph so all Ractors share it without Marshal copying
      shareable_world = Ractor.make_shareable(world)

      # Copy camera rendering state into a shareable hash (avoids freezing self)
      cam = Ractor.make_shareable({
        hsize: @hsize,
        vsize: @vsize,
        pixel_size: @pixel_size,
        half_width: @half_width,
        half_height: @half_height,
        transform_inverse: @transform_inverse,
        samples_per_pixel: @samples_per_pixel,
        aperture_size: @aperture_size,
        focal_distance: @focal_distance,
        motion_blur: @motion_blur
      })

      chunk_size = [(@vsize.to_f / cpu_count).ceil, 1].max

      ractors = (0...@vsize).step(chunk_size).map do |y_start|
        y_end = [y_start + chunk_size, @vsize].min

        Ractor.new(y_start, y_end, shareable_world, cam) do |ys, ye, w, c|
          inv = c[:transform_inverse]
          width = c[:hsize]
          ps = c[:pixel_size]
          hw = c[:half_width]
          hh = c[:half_height]
          fd = c[:focal_distance]

          # Precompute camera origin (constant when aperture_size == 0)
          om = inv * Rayz::Point.new(x: 0.0, y: 0.0, z: 0.0).to_matrix
          cam_origin = Rayz::Point.new(x: om[0, 0], y: om[1, 0], z: om[2, 0])

          chunk = []
          (ys...ye).each do |y|
            (0...width).each do |x|
              r, g, b = if c[:samples_per_pixel] == 1 && c[:aperture_size] == 0.0 && !c[:motion_blur]
                xoffset = (x + 0.5) * ps
                yoffset = (y + 0.5) * ps
                pm = inv * Rayz::Point.new(x: hw - xoffset, y: hh - yoffset, z: -fd).to_matrix
                pixel = Rayz::Point.new(x: pm[0, 0], y: pm[1, 0], z: pm[2, 0])
                direction = (pixel - cam_origin).normalize
                ray = Rayz::Ray.new(origin: cam_origin, direction: direction, time: 0.0)
                col = w.color_at(ray)
                [col.red, col.green, col.blue]
              else
                total_r = total_g = total_b = 0.0
                c[:samples_per_pixel].times do
                  xo = (x + rand) * ps
                  yo = (y + rand) * ps
                  ax = (c[:aperture_size] > 0) ? (rand * 2 - 1) * c[:aperture_size] : 0.0
                  ay = (c[:aperture_size] > 0) ? (rand * 2 - 1) * c[:aperture_size] : 0.0
                  t = c[:motion_blur] ? rand : 0.0
                  pm = inv * Rayz::Point.new(x: hw - xo, y: hh - yo, z: -fd).to_matrix
                  pixel = Rayz::Point.new(x: pm[0, 0], y: pm[1, 0], z: pm[2, 0])
                  om2 = inv * Rayz::Point.new(x: ax, y: ay, z: 0.0).to_matrix
                  orig = Rayz::Point.new(x: om2[0, 0], y: om2[1, 0], z: om2[2, 0])
                  dir = (pixel - orig).normalize
                  ray = Rayz::Ray.new(origin: orig, direction: dir, time: t)
                  col = w.color_at(ray)
                  total_r += col.red
                  total_g += col.green
                  total_b += col.blue
                end
                div = c[:samples_per_pixel].to_f
                [total_r / div, total_g / div, total_b / div]
              end
              chunk << [x, y, r, g, b]
            end
          end
          chunk
        end
      end

      ractors.each do |ractor|
        ractor.value.each do |x, y, r, g, b|
          image.write_pixel(row: @vsize - 1 - y, col: x,
            color: Rayz::Color.new(red: r, green: g, blue: b))
        end
        print "."
      end

      total_time = Time.now - start_time
      puts "\nDone!"
      puts "Rendering took #{total_time.round(2)} seconds (#{cpu_count} Ractors)"
      puts "Time per row: #{(total_time / @vsize * 1000).round(2)} ms"

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
