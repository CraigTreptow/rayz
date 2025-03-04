require_relative "../rayz/tuple"

module Rayz
  class Vector < Tuple
    def initialize(x:, y:, z:)
      @x = x
      @y = y
      @z = z
      @w = 0
    end

    def dot(other)
      @x * other.x +
        @y * other.y +
        @z * other.z +
        @w * other.w
    end

    def cross(other)
      Vector.new(x: @y * other.z - @z * other.y,
        y: @z * other.x - @x * other.z,
        z: @x * other.y - @y * other.x)
    end
  end
end
