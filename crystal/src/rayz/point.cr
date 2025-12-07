# Point - represents a position in 3D space (w=1.0)
# Port of Ruby's lib/rayz/point.rb

require "./tuple"

module Rayz
  class Point < Tuple
    def initialize(x : Number, y : Number, z : Number)
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
      @w = 1.0
    end
  end
end
