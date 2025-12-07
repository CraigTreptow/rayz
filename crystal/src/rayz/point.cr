# Point - represents a position in 3D space (w=1.0)
# Port of Ruby's lib/rayz/point.rb

require "./tuple"

module Rayz
  class Point < Tuple
    def initialize(x : Float64, y : Float64, z : Float64)
      super(x, y, z, 1.0)
    end

    # Allow integer or other numeric initialization
    def self.new(x : Number, y : Number, z : Number)
      new(x.to_f, y.to_f, z.to_f)
    end
  end
end
