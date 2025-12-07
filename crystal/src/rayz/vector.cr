# Vector - represents a direction/displacement in 3D space (w=0.0)
# Port of Ruby's lib/rayz/vector.rb

require "./tuple"

module Rayz
  class Vector < Tuple
    def initialize(x : Float64, y : Float64, z : Float64)
      super(x, y, z, 0.0)
    end

    # Allow integer or other numeric initialization
    def self.new(x : Number, y : Number, z : Number)
      new(x.to_f, y.to_f, z.to_f)
    end

    # Override dot product with proper return type
    def dot(other : Tuple) : Float64
      @x * other.x +
        @y * other.y +
        @z * other.z +
        @w * other.w
    end

    # Cross product (only for vectors)
    def cross(other : Vector) : Vector
      Vector.new(
        @y * other.z - @z * other.y,
        @z * other.x - @x * other.z,
        @x * other.y - @y * other.x
      )
    end

    # Override reflect to return a Vector
    def reflect(normal : Vector) : Vector
      result = self - normal * 2 * dot(normal)
      Vector.new(result.x, result.y, result.z)
    end

    # Override normalize to return a Vector
    def normalize : Vector
      mag = magnitude
      Vector.new(@x / mag, @y / mag, @z / mag)
    end
  end
end
