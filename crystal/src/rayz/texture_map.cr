module Rayz
  class PPMImage
    getter width : Int32
    getter height : Int32

    def initialize(width : Int32, height : Int32)
      @width = width
      @height = height
      @pixels = Array(Array(Color)).new(height) { Array.new(width, Color.new(0.0, 0.0, 0.0)) }
    end

    def pixel_at(x : Int32, y : Int32) : Color
      return Color.new(0.0, 0.0, 0.0) if x < 0 || x >= @width || y < 0 || y >= @height
      @pixels[y][x]
    end

    def set_pixel(x : Int32, y : Int32, color : Color)
      return unless x >= 0 && x < @width && y >= 0 && y < @height
      @pixels[y][x] = color
    end

    def self.load_ppm(filename : String) : PPMImage
      lines = File.read(filename).lines.map(&.strip).reject { |l| l.empty? || l.starts_with?("#") }
      format = lines.shift
      raise "Unsupported PPM format: #{format}" unless format == "P3"

      wh = lines.shift.split
      width = wh[0].to_i
      height = wh[1].to_i
      max_color = lines.shift.to_i

      image = new(width, height)
      values = lines.join(" ").split.map(&.to_i)

      i = 0
      values.each_slice(3) do |rgb|
        x = i % width
        y = i / width
        image.set_pixel(x, y, Color.new(rgb[0] / max_color.to_f, rgb[1] / max_color.to_f, rgb[2] / max_color.to_f))
        i += 1
      end

      image
    end
  end

  class TextureMap < Pattern
    getter image : PPMImage
    getter uv_map : Proc(Point, ::Tuple(Float64, Float64))

    def initialize(image : PPMImage, uv_map : Proc(Point, ::Tuple(Float64, Float64)))
      super(Color.new(0.0, 0.0, 0.0), Color.new(0.0, 0.0, 0.0))
      @image = image
      @uv_map = uv_map
    end

    def pattern_at(point : Point) : Color
      u, v = @uv_map.call(point)
      x = (u * (@image.width - 1)).round.to_i
      y = ((1.0 - v) * (@image.height - 1)).round.to_i
      @image.pixel_at(x, y)
    end

    def self.planar_map : Proc(Point, ::Tuple(Float64, Float64))
      ->(point : Point) { {point.x % 1.0, point.z % 1.0} }
    end

    def self.cylindrical_map : Proc(Point, ::Tuple(Float64, Float64))
      ->(point : Point) {
        theta = Math.atan2(point.x, point.z)
        u = (theta + Math::PI) / (2.0 * Math::PI)
        v = point.y % 1.0
        {u, v}
      }
    end

    def self.spherical_map : Proc(Point, ::Tuple(Float64, Float64))
      ->(point : Point) {
        theta = Math.atan2(point.x, point.z)
        radius = Vector.new(point.x, point.y, point.z).magnitude
        phi = Math.acos((point.y / radius).clamp(-1.0, 1.0))
        u = 1.0 - (theta + Math::PI) / (2.0 * Math::PI)
        v = 1.0 - phi / Math::PI
        {u, v}
      }
    end
  end
end
