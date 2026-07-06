module Rayz
  class Canvas
    getter width : Int32
    getter height : Int32

    MAX_COLOR_VALUE = 255

    @pixels : Array(Array(Color))

    def initialize(width : Int32, height : Int32)
      @width = width
      @height = height
      @pixels = Array.new(height) { Array.new(width) { Color.new(0, 0, 0) } }
    end

    def write_pixel(col : Int32, row : Int32, color : Color) : Nil
      raise "write_pixel: Col out of bounds: #{col}" if col < 0 || col >= @width
      raise "write_pixel: Row out of bounds: #{row}" if row < 0 || row >= @height
      @pixels[row][col] = color
    end

    def pixel_at(col : Int32, row : Int32) : Color
      raise "pixel_at: Col out of bounds: #{col}" if col < 0 || col >= @width
      raise "pixel_at: Row out of bounds: #{row}" if row < 0 || row >= @height
      @pixels[row][col]
    end

    def to_ppm : String
      String.build do |str|
        str << "P3\n#{@width} #{@height}\n#{MAX_COLOR_VALUE}\n"
        (@height - 1).downto(0) do |row|
          first = true
          (0...@width).each do |col|
            str << ' ' unless first
            first = false
            pixel = @pixels[row][col]
            str << scale(pixel.red) << ' ' << scale(pixel.green) << ' ' << scale(pixel.blue)
          end
          str << '\n'
        end
        str << "\n"
      end
    end

    private def scale(channel : Float64) : Int32
      (channel * 256.0).round.to_i.clamp(0, MAX_COLOR_VALUE)
    end
  end
end
