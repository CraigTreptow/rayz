require "matrix"
require_relative "shape"

module Rayz
  class Plane < Shape
    EPSILON = 1e-5

    def local_intersect(local_ray)
      # If the ray is parallel to the plane (y component of direction is ~0)
      # then there are no intersections
      return [] if local_ray.direction.y.abs < EPSILON

      # Calculate where the ray intersects the plane (y=0)
      t = -local_ray.origin.y / local_ray.direction.y
      [Intersection.new(t: t, object: self)]
    end

    def local_normal_at(local_point)
      # The normal of a plane is constant everywhere - always pointing up
      Vector.new(x: 0, y: 1, z: 0)
    end
  end
end
