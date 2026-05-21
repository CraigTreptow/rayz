module Rayz
  class Color
    getter red : Float64
    getter green : Float64
    getter blue : Float64

    def initialize(red : Float64 | Int32, green : Float64 | Int32, blue : Float64 | Int32)
      @red = red.to_f
      @green = green.to_f
      @blue = blue.to_f
    end

    def +(other : Color) : Color
      Color.new(@red + other.red, @green + other.green, @blue + other.blue)
    end

    def -(other : Color) : Color
      Color.new(@red - other.red, @green - other.green, @blue - other.blue)
    end

    def *(scalar : Float64 | Int32) : Color
      s = scalar.to_f
      Color.new(@red * s, @green * s, @blue * s)
    end

    def *(other : Color) : Color
      Color.new(@red * other.red, @green * other.green, @blue * other.blue)
    end

    def ==(other : Color) : Bool
      Util.approx_eq?(@red, other.red) &&
        Util.approx_eq?(@green, other.green) &&
        Util.approx_eq?(@blue, other.blue)
    end

    def to_s(io : IO) : Nil
      io << "Red: #{@red} Green: #{@green} Blue: #{@blue}"
    end
  end
end
