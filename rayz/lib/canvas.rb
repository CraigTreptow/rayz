module Rayz
  module Lib
    class Canvas
      attr_reader :height, :width, :pixels
      MAX_COLORS = 255

      def initialize(width:, height:)
        @width = width
        @height = height
        black = Color.new(red: 0.0, green: 0.0, blue: 0.0)
        @pixels = Array.new(height) { Array.new(width, black) }
      end

      def to_ppm
        ppm_header + ppm_body + ppm_footer
      end

      def write_pixel(row:, col:, color:)
        raise "write_pixel: Row out of bounds: #{row}" if row > @height - 1 || row < 0
        raise "write_pixel: Col out of bounds: #{col}" if col > @width - 1 || col < 0

        @pixels[row][col] = color
      end

      def pixel_at(row:, col:)
        raise "pixel_at: Row out of bounds: #{row}" if row > @height - 1 || row < 0
        raise "pixel_at: Col out of bounds: #{col}" if col > @width - 1 || col < 0

        @pixels[row][col]
      end

      def to_s
        output = "Height: #{@height}, Columns: #{@width}\n\n"

        (0..@height - 1).to_a.reverse_each do |r|
          (0..@width - 1).to_a.each do |c|
            output << "[R:#{r} C:#{c}] - #{@pixels[r][c]} "
          end
          output << "\n"
        end
        output
      end

      private

      def ppm_header
        <<~HEREDOC
          P3
          #{@width} #{@height}
          #{MAX_COLORS}
        HEREDOC
      end

      def ppm_body
        output = [] # : Array[String]
        total_values = (MAX_COLORS + 1)

        (0..@height - 1).to_a.reverse_each do |r|
          chunk = [] # : Array[String]
          (0..@width - 1).each do |c|
            scaled_red = (@pixels[r][c].red * total_values).round
            clamped_red = scaled_red.clamp(0, MAX_COLORS)

            scaled_green = (@pixels[r][c].green * total_values).round
            clamped_green = scaled_green.clamp(0, 255)

            scaled_blue = (@pixels[r][c].blue * total_values).round
            clamped_blue = scaled_blue.clamp(0, 255)

            chunk << "#{clamped_red} #{clamped_green} #{clamped_blue} "
          end
          output << chunk.reverse.join.rstrip + "\n"
        end
        output.join
      end

      def ppm_footer
        "\n"
      end
    end
  end
end
