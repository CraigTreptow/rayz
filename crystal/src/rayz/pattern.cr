module Rayz
  abstract class Pattern
    property a : Color
    property b : Color
    getter transform : Matrix

    def initialize(a : Color, b : Color)
      @a = a
      @b = b
      @transform = Matrix.identity
      @transform_inverse = Matrix.identity
    end

    def transform=(m : Matrix)
      @transform = m
      @transform_inverse = m.inverse
    end

    abstract def pattern_at(point : Point) : Color

    def pattern_at_shape(object_transform_inverse : Matrix, world_point : Point) : Color
      obj_t = object_transform_inverse * world_point
      object_point = Point.new(obj_t.x, obj_t.y, obj_t.z)
      pat_t = @transform_inverse * object_point
      pattern_point = Point.new(pat_t.x, pat_t.y, pat_t.z)
      pattern_at(pattern_point)
    end
  end
end
