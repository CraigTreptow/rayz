require_relative "pattern"

module Rayz
  class GradientPattern < Pattern
    def pattern_at(point)
      # Linear interpolation between a and b based on x coordinate
      distance = @b - @a
      fraction = point.x - point.x.floor
      @a + distance * fraction
    end
  end
end
