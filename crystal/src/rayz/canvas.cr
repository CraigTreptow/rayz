# Canvas - 2D pixel grid with PPM export
# Port of Ruby's lib/rayz/canvas.rb

require "./color"

module Rayz
  class Canvas
    getter width : Int32
    getter height : Int32
    getter pixels : Array(Array(Color))

    MAX_COLORS = 255

    def initialize(@width : Int32, @height : Int32)
      black = Color.new(0.0, 0.0, 0.0)
      @pixels = Array.new(@height) { Array.new(@width, black) }
      @mutex = Mutex.new
    end

    # Write a pixel at the given row and column
    def write_pixel(row : Int32, col : Int32, color : Color) : Nil
      raise "write_pixel: Row out of bounds: #{row}" if row > @height - 1 || row < 0
      raise "write_pixel: Col out of bounds: #{col}" if col > @width - 1 || col < 0

      @mutex.synchronize do
        @pixels[row][col] = color
      end
    end

    # Read a pixel at the given row and column
    def pixel_at(row : Int32, col : Int32) : Color
      raise "pixel_at: Row out of bounds: #{row}" if row > @height - 1 || row < 0
      raise "pixel_at: Col out of bounds: #{col}" if col > @width - 1 || col < 0

      @pixels[row][col]
    end

    # Convert canvas to string representation
    def to_s(io : IO)
      io << "Height: #{@height}, Columns: #{@width}\n\n"

      (@height - 1).downto(0) do |r|
        (0...@width).each do |c|
          io << "[R:#{r} C:#{c}] - #{@pixels[r][c]} "
        end
        io << "\n"
      end
    end

    # Generate PPM body (pixel data)
    private def ppm_body : String
      output = Array(String).new(@height)
      total_values = MAX_COLORS + 1

      # Process rows in reverse order (PPM origin is top-left, we use bottom-left)
      (@height - 1).downto(0) do |r|
        row_data = String.build do |str|
          (0...@width).each do |c|
            pixel = @pixels[r][c]

            # Scale and clamp RGB values to 0-255
            clamped_red = (pixel.red * total_values).round.to_i.clamp(0, MAX_COLORS)
            clamped_green = (pixel.green * total_values).round.to_i.clamp(0, MAX_COLORS)
            clamped_blue = (pixel.blue * total_values).round.to_i.clamp(0, MAX_COLORS)

            str << "#{clamped_blue} #{clamped_green} #{clamped_red} "
          end
        end

        output[@height - 1 - r] = row_data.rstrip + "\n"
      end

      output.join
    end

    # Generate PPM header
    private def ppm_header : String
      "P3\n#{@width} #{@height}\n#{MAX_COLORS}\n"
    end

    # Generate PPM footer
    private def ppm_footer : String
      "\n"
    end

    # Convert canvas to PPM format
    def to_ppm : String
      ppm_header + ppm_body + ppm_footer
    end
  end
end
