module Rayz
  class RingPattern < Pattern
    def pattern_at(point : Point) : Color
      Math.sqrt(point.x**2 + point.z**2).floor.to_i.even? ? @a : @b
    end
  end
end
