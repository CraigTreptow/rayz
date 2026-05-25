module Rayz
  class TestPattern < Pattern
    def initialize
      @a = Color.new(0.0, 0.0, 0.0)
      @b = Color.new(0.0, 0.0, 0.0)
      @transform = Matrix.identity
      @transform_inverse = Matrix.identity
    end

    def pattern_at(point : Point) : Color
      Color.new(point.x, point.y, point.z)
    end
  end
end
