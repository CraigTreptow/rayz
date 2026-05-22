module Rayz
  class Canvas
    MAX_COLOR = 255

    getter width : Int32
    getter height : Int32
    getter pixels : Array(Array(Color))

    def initialize(width : Int32, height : Int32)
      @width = width
      @height = height
      black = Color.new(0.0, 0.0, 0.0)
      @pixels = Array.new(height) { Array.new(width, black) }
    end

    def write_pixel(col : Int32, row : Int32, color : Color) : Nil
      raise "write_pixel: col #{col} out of bounds" unless col.in?(0...@width)
      raise "write_pixel: row #{row} out of bounds" unless row.in?(0...@height)

      @pixels[row][col] = color
    end

    def pixel_at(col : Int32, row : Int32) : Color
      raise "pixel_at: col #{col} out of bounds" unless col.in?(0...@width)
      raise "pixel_at: row #{row} out of bounds" unless row.in?(0...@height)

      @pixels[row][col]
    end

    def to_ppm : String
      String.build do |io|
        io << ppm_header
        io << ppm_body
        io << "\n"
      end
    end

    private def ppm_header : String
      "P3\n#{@width} #{@height}\n#{MAX_COLOR}\n"
    end

    private def ppm_body : String
      String.build do |io|
        (@height - 1).downto(0) do |row|
          line = (@width - 1).downto(0).map do |col|
            pixel = @pixels[row][col]
            r = scale_channel(pixel.red)
            g = scale_channel(pixel.green)
            b = scale_channel(pixel.blue)
            "#{r} #{g} #{b}"
          end.to_a.join(" ")
          io << line << "\n"
        end
      end
    end

    private def scale_channel(value : Float64) : Int32
      (value * (MAX_COLOR + 1)).round.to_i.clamp(0, MAX_COLOR)
    end
  end
end
