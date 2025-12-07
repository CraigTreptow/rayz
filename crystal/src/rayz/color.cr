# Color - RGB color representation
# Port of Ruby's lib/rayz/color.rb

require "./util"

module Rayz
  class Color
    getter red : Float64
    getter green : Float64
    getter blue : Float64

    def initialize(@red : Float64, @green : Float64, @blue : Float64)
    end

    # Allow integer or other numeric initialization
    def self.new(red : Number, green : Number, blue : Number)
      new(red.to_f, green.to_f, blue.to_f)
    end

    # Color addition
    def +(other : Color) : Color
      Color.new(
        @red + other.red,
        @green + other.green,
        @blue + other.blue
      )
    end

    # Color subtraction
    def -(other : Color) : Color
      Color.new(
        @red - other.red,
        @green - other.green,
        @blue - other.blue
      )
    end

    # Scalar multiplication
    def *(scalar : Number) : Color
      Color.new(
        @red * scalar,
        @green * scalar,
        @blue * scalar
      )
    end

    # Hadamard product (color * color)
    def *(other : Color) : Color
      Color.new(
        @red * other.red,
        @green * other.green,
        @blue * other.blue
      )
    end

    def to_s(io : IO)
      io << "Red: #{@red} Green: #{@green} Blue: #{@blue}"
    end

    # Equality with floating-point tolerance
    def ==(other : Color) : Bool
      Util.equals?(@red, other.red) &&
        Util.equals?(@green, other.green) &&
        Util.equals?(@blue, other.blue)
    end
  end
end
