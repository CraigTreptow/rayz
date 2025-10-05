require_relative "shape"

module Rayz
  # Test shape for debugging shape transformations
  class TestShape < Shape
    def local_intersect(local_ray)
      # Test shape doesn't calculate real intersections
      # Just stores the ray for inspection
      []
    end

    def local_normal_at(local_point)
      # Test shape returns the local point as a vector for testing
      Vector.new(x: local_point.x, y: local_point.y, z: local_point.z)
    end
  end
end
