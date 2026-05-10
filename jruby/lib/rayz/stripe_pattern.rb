require_relative "pattern"

module Rayz
  class StripePattern < Pattern
    def pattern_at(point)
      # Stripes alternate based on x coordinate
      # floor(x) % 2 == 0 ? a : b
      point.x.floor.even? ? @a : @b
    end
  end
end
