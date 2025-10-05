require_relative "pattern"

module Rayz
  # Test pattern that returns a color based on the point coordinates
  # Used for debugging and testing pattern transformations
  class TestPattern < Pattern
    def initialize
      # Test pattern doesn't need colors
      @transform = Matrix.identity(4)
    end

    def pattern_at(point)
      # Return a color with RGB values equal to the point's XYZ coordinates
      Color.new(red: point.x, green: point.y, blue: point.z)
    end
  end
end
