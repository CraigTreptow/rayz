module Rayz
  class Tuple
    attr_reader :x, :y, :z, :w

    def initialize(x:, y:, z:, w:)
      @x = x
      @y = y
      @z = z
      @w = w
    end

    def to_s
      "Class: #{self.class.name} X: #{@x} Y: #{@y} Z: #{@z} W: #{@w}"
    end

    def *(other)
      Tuple.new(x: @x * other, y: @y * other, z: @z * other, w: @w * other)
    end

    def /(other)
      Tuple.new(x: @x / other, y: @y / other, z: @z / other, w: @w / other)
    end

    def +(other)
      Tuple.new(x: @x + other.x, y: @y + other.y, z: @z + other.z, w: @w + other.w)
    end

    def -(other)
      Tuple.new(x: @x - other.x, y: @y - other.y, z: @z - other.z, w: @w - other.w)
    end

    def negate
      Tuple.new(x: -@x, y: -@y, z: -@z, w: -@w)
    end

    def -@
      negate
    end

    def dot(other)
      @x * other.x +
        @y * other.y +
        @z * other.z +
        @w * other.w
    end

    def magnitude
      Math.sqrt(@x**2 + @y**2 + @z**2 + @w**2)
    end

    def normalize
      mag = magnitude
      Tuple.new(x: @x / mag, y: @y / mag, z: @z / mag, w: @w / mag)
    end

    def reflect(normal)
      self - normal * 2 * dot(normal)
    end

    # rubocop:disable Style/YodaCondition
    def ==(other)
      Rayz::Util.==(@x, other.x) &&
        Rayz::Util.==(@y, other.y) &&
        Rayz::Util.==(@z, other.z) &&
        Rayz::Util.==(@w, other.w)
    end

    def point?
      Rayz::Util.==(@w, 1.0)
    end

    def vector?
      Rayz::Util.==(@w, 0.0)
    end
    # rubocop:enable Style/YodaCondition

    def to_matrix
      vals = [@x, @y, @z, @w]
      Matrix.build(4, 1) { |row, col| vals[row] }
    end
  end
end
