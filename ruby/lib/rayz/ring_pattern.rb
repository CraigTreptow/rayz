require_relative "pattern"

module Rayz
  class RingPattern < Pattern
    def pattern_at(point)
      # Concentric rings based on distance from origin in XZ plane
      distance = Math.sqrt(point.x**2 + point.z**2)
      distance.floor.even? ? @a : @b
    end
  end
end
