module Rayz
  class Point < Tuple
    def initialize(x : Float64 | Int32, y : Float64 | Int32, z : Float64 | Int32)
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
      @w = 1.0
    end
  end
end
