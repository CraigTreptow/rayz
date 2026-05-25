module Rayz
  class CheckersPattern < Pattern
    def pattern_at(point : Point) : Color
      (point.x.floor.to_i + point.y.floor.to_i + point.z.floor.to_i).even? ? @a : @b
    end
  end
end
