module Rayz
  module Lib
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

      def magnitude
        Math.sqrt(@x**2 + @y**2 + @z**2 + @w**2)
      end

      def normalize
        mag = magnitude
        Tuple.new(x: @x / mag, y: @y / mag, z: @z / mag, w: @w / mag)
      end

      # rubocop:disable Style/YodaCondition
      # rubocop:disable Lint/Void
      def ==(other)
        Util.==(@x, other.x)
        Util.==(@y, other.y)
        Util.==(@z, other.z)
        Util.==(@w, other.w)
      end
      # rubocop:enable Lint/Void

      def point?
        Util.==(@w, 1.0)
      end

      def vector?
        Util.==(@w, 0.0)
      end
      # rubocop:enable Style/YodaCondition

      def to_matrix
        vals = [@x, @y, @z, @w]
        Matrix.build(4, 1) {|row, col| vals[row] }
        # Matrix[[@x, @y, @z, @w]]
      end
    end
  end
end
