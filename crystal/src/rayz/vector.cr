module Rayz
  class Vector < Tuple
    def initialize(x : Float64 | Int32, y : Float64 | Int32, z : Float64 | Int32)
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
      @w = 0.0
    end

    def cross(other : Vector) : Vector
      Vector.new(
        @y * other.z - @z * other.y,
        @z * other.x - @x * other.z,
        @x * other.y - @y * other.x
      )
    end

    def normalize : Vector
      mag = magnitude
      Vector.new(@x / mag, @y / mag, @z / mag)
    end

    def reflect(normal : Tuple) : Vector
      result = super(normal)
      Vector.new(result.x, result.y, result.z)
    end
  end
end
