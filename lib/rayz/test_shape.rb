require_relative "shape"
require_relative "bounds"

module Rayz
  # Test shape for debugging shape transformations
  class TestShape < Shape
    attr_accessor :saved_ray

    def local_intersect(local_ray)
      # Test shape stores the ray for inspection (used for bounding box optimization tests)
      @saved_ray = local_ray
      []
    end

    def local_normal_at(local_point, hit = nil)
      # Test shape returns the local point as a vector for testing
      Vector.new(x: local_point.x, y: local_point.y, z: local_point.z)
    end

    def bounds
      # Test shape uses same bounds as a unit sphere
      Bounds.new(
        min: Point.new(x: -1, y: -1, z: -1),
        max: Point.new(x: 1, y: 1, z: 1)
      )
    end
  end
end
