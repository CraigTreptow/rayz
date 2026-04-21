require_relative "../rayz/tuple"

module Rayz
  class Point < Rayz::Tuple
    def initialize(x:, y:, z:)
      @x = x
      @y = y
      @z = z
      @w = 1.0
    end
  end
end
