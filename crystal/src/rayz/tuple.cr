module Rayz
  class Tuple
    getter x : Float64
    getter y : Float64
    getter z : Float64
    getter w : Float64

    def initialize(x : Float64 | Int32, y : Float64 | Int32, z : Float64 | Int32, w : Float64 | Int32)
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
      @w = w.to_f
    end

    def *(scalar : Float64 | Int32) : Tuple
      s = scalar.to_f
      Tuple.new(@x * s, @y * s, @z * s, @w * s)
    end

    def /(scalar : Float64 | Int32) : Tuple
      s = scalar.to_f
      Tuple.new(@x / s, @y / s, @z / s, @w / s)
    end

    def +(other : Tuple) : Tuple
      Tuple.new(@x + other.x, @y + other.y, @z + other.z, @w + other.w)
    end

    def -(other : Tuple) : Tuple
      Tuple.new(@x - other.x, @y - other.y, @z - other.z, @w - other.w)
    end

    def - : Tuple
      Tuple.new(-@x, -@y, -@z, -@w)
    end

    def dot(other : Tuple) : Float64
      @x * other.x + @y * other.y + @z * other.z + @w * other.w
    end

    def magnitude : Float64
      Math.sqrt(@x ** 2 + @y ** 2 + @z ** 2 + @w ** 2)
    end

    def normalize : Tuple
      mag = magnitude
      Tuple.new(@x / mag, @y / mag, @z / mag, @w / mag)
    end

    def reflect(normal : Tuple) : Tuple
      self - normal * 2.0 * dot(normal)
    end

    def ==(other : Tuple) : Bool
      Util.approx_eq?(@x, other.x) &&
        Util.approx_eq?(@y, other.y) &&
        Util.approx_eq?(@z, other.z) &&
        Util.approx_eq?(@w, other.w)
    end

    def point? : Bool
      Util.approx_eq?(@w, 1.0)
    end

    def vector? : Bool
      Util.approx_eq?(@w, 0.0)
    end

    def to_s(io : IO) : Nil
      io << "Class: #{self.class.name} X: #{@x} Y: #{@y} Z: #{@z} W: #{@w}"
    end
  end
end
