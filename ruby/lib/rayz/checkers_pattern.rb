require_relative "pattern"

module Rayz
  class CheckersPattern < Pattern
    def pattern_at(point)
      # 3D checkerboard pattern
      sum = point.x.floor + point.y.floor + point.z.floor
      sum.even? ? @a : @b
    end
  end
end
