module Rayz
  module Lib
    class Point < Tuple
      def initialize(x:, y:, z:)
        @x = x
        @y = y
        @z = z
        @w = 1.0
      end
    end
  end
end
