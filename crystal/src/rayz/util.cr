module Rayz
  module Util
    EPSILON = 0.00003_f64

    def self.approx_eq?(x : Float64, y : Float64) : Bool
      (x - y).abs < EPSILON
    end
  end
end
