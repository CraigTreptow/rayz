module Rayz
  class StripePattern < Pattern
    def pattern_at(point : Point) : Color
      point.x.floor.to_i.even? ? @a : @b
    end
  end
end
