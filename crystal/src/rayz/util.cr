# Utility functions for the Rayz ray tracer
# Port of Ruby's lib/rayz/util.rb

module Rayz
  module Util
    # Increased epsilon to handle floating-point accumulation errors in complex ray tracing
    EPSILON = 0.00003

    # Floating-point equality comparison with tolerance
    def self.equals?(x : Float64, y : Float64) : Bool
      (x - y).abs < EPSILON
    end

    # Allow comparison with integers
    def self.equals?(x : Number, y : Number) : Bool
      (x.to_f - y.to_f).abs < EPSILON
    end
  end
end
