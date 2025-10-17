module Rayz
  # Simple PPM image loader for texture mapping
  class PPMImage
    attr_reader :width, :height, :pixels

    def initialize(width, height)
      @width = width
      @height = height
      @pixels = Array.new(height) { Array.new(width) }
    end

    # Get color at pixel (x, y)
    def pixel_at(x, y)
      return Color.new(red: 0, green: 0, blue: 0) if x < 0 || x >= @width || y < 0 || y >= @height
      @pixels[y][x]
    end

    # Set color at pixel (x, y)
    def set_pixel(x, y, color)
      @pixels[y][x] = color if x >= 0 && x < @width && y >= 0 && y < @height
    end

    # Load from PPM file (simple P3 format)
    def self.load_ppm(filename)
      lines = File.readlines(filename).map(&:strip).reject { |l| l.empty? || l.start_with?("#") }
      format = lines.shift

      raise "Unsupported PPM format: #{format}" unless format == "P3"

      width, height = lines.shift.split.map(&:to_i)
      max_color = lines.shift.to_i

      image = new(width, height)
      values = lines.join(" ").split.map(&:to_i)

      values.each_slice(3).with_index do |rgb, index|
        x = index % width
        y = index / width
        r = rgb[0] / max_color.to_f
        g = rgb[1] / max_color.to_f
        b = rgb[2] / max_color.to_f
        image.set_pixel(x, y, Color.new(red: r, green: g, blue: b))
      end

      image
    end
  end

  # Texture mapping pattern
  class TextureMap < Pattern
    attr_reader :image, :uv_map

    def initialize(image, uv_map)
      super()
      @image = image
      @uv_map = uv_map  # A proc that converts (point) -> [u, v] in range [0, 1]
    end

    def pattern_at(point)
      # Get UV coordinates from the mapping function
      u, v = @uv_map.call(point)

      # Convert UV to pixel coordinates
      # V is inverted because image coordinates start at top-left
      x = (u * (@image.width - 1)).round
      y = ((1.0 - v) * (@image.height - 1)).round

      @image.pixel_at(x, y)
    end

    # Planar mapping: maps (x, y) directly to (u, v)
    def self.planar_map
      ->(point) {
        u = point.x % 1.0
        v = point.z % 1.0
        [u, v]
      }
    end

    # Cylindrical mapping: wraps around Y axis
    def self.cylindrical_map
      ->(point) {
        # Compute angle around Y axis
        theta = Math.atan2(point.x, point.z)
        # Normalize to [0, 1]
        u = (theta + Math::PI) / (2 * Math::PI)
        # Y maps directly to v (assume unit cylinder 0 to 1)
        v = point.y % 1.0
        [u, v]
      }
    end

    # Spherical mapping: maps sphere surface to UV
    def self.spherical_map
      ->(point) {
        # Convert to spherical coordinates
        theta = Math.atan2(point.x, point.z)
        # Vector from center to point
        vec = Vector.new(x: point.x, y: point.y, z: point.z)
        radius = vec.magnitude
        phi = Math.acos(point.y / radius)

        # Map to UV coordinates
        u = 1.0 - (theta + Math::PI) / (2 * Math::PI)
        v = 1.0 - phi / Math::PI
        [u, v]
      }
    end
  end
end
