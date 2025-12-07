# 4D Tuple - the base class for Points and Vectors
# Port of Ruby's lib/rayz/tuple.rb

require "./util"

module Rayz
  class Tuple
    getter x : Float64
    getter y : Float64
    getter z : Float64
    getter w : Float64

    def initialize(@x : Float64, @y : Float64, @z : Float64, @w : Float64)
    end

    # Allow integer or other numeric initialization
    def self.new(x : Number, y : Number, z : Number, w : Number)
      new(x.to_f, y.to_f, z.to_f, w.to_f)
    end

    def to_s(io : IO)
      io << "Class: #{self.class.name} X: #{@x} Y: #{@y} Z: #{@z} W: #{@w}"
    end

    # Scalar multiplication
    def *(scalar : Number) : Tuple
      Tuple.new(
        @x * scalar,
        @y * scalar,
        @z * scalar,
        @w * scalar
      )
    end

    # Scalar division
    def /(scalar : Number) : Tuple
      Tuple.new(
        @x / scalar,
        @y / scalar,
        @z / scalar,
        @w / scalar
      )
    end

    # Tuple addition
    def +(other : Tuple) : Tuple
      Tuple.new(
        @x + other.x,
        @y + other.y,
        @z + other.z,
        @w + other.w
      )
    end

    # Tuple subtraction
    def -(other : Tuple) : Tuple
      Tuple.new(
        @x - other.x,
        @y - other.y,
        @z - other.z,
        @w - other.w
      )
    end

    # Negation
    def negate : Tuple
      Tuple.new(-@x, -@y, -@z, -@w)
    end

    # Unary minus operator
    def - : Tuple
      negate
    end

    # Dot product
    def dot(other : Tuple) : Float64
      @x * other.x +
        @y * other.y +
        @z * other.z +
        @w * other.w
    end

    # Magnitude (length) of the tuple
    def magnitude : Float64
      Math.sqrt(@x**2 + @y**2 + @z**2 + @w**2)
    end

    # Normalize to unit length
    def normalize : Tuple
      mag = magnitude
      Tuple.new(@x / mag, @y / mag, @z / mag, @w / mag)
    end

    # Reflect tuple around a normal
    def reflect(normal : Tuple) : Tuple
      self - normal * 2 * dot(normal)
    end

    # Equality with floating-point tolerance
    def ==(other : Tuple) : Bool
      Util.equals?(@x, other.x) &&
        Util.equals?(@y, other.y) &&
        Util.equals?(@z, other.z) &&
        Util.equals?(@w, other.w)
    end

    # Check if this is a point (w == 1.0)
    def point? : Bool
      Util.equals?(@w, 1.0)
    end

    # Check if this is a vector (w == 0.0)
    def vector? : Bool
      Util.equals?(@w, 0.0)
    end
  end
end
