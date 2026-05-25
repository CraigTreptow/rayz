module Rayz
  class GradientPattern < Pattern
    def pattern_at(point : Point) : Color
      distance = @b - @a
      fraction = point.x - point.x.floor
      @a + distance * fraction
    end
  end
end
