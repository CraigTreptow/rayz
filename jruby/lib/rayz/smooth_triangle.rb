require_relative "triangle"
require_relative "intersection"

module Rayz
  class SmoothTriangle < Triangle
    attr_reader :n1, :n2, :n3

    def initialize(p1:, p2:, p3:, n1:, n2:, n3:)
      super(p1: p1, p2: p2, p3: p3)
      @n1 = n1
      @n2 = n2
      @n3 = n3
    end

    def local_intersect(local_ray)
      # Möller-Trumbore algorithm for ray-triangle intersection
      # Convert direction to Vector for cross product
      dir = Vector.new(x: local_ray.direction.x, y: local_ray.direction.y, z: local_ray.direction.z)
      dir_cross_e2 = dir.cross(@e2)
      det = @e1.dot(dir_cross_e2)

      # If determinant is near zero, ray lies in plane of triangle
      return [] if det.abs < Util::EPSILON

      f = 1.0 / det
      p1_to_origin_tuple = local_ray.origin - @p1
      p1_to_origin = Vector.new(x: p1_to_origin_tuple.x, y: p1_to_origin_tuple.y, z: p1_to_origin_tuple.z)
      u = f * p1_to_origin.dot(dir_cross_e2)

      # Test u parameter (first barycentric coordinate)
      return [] if u < 0 || u > 1

      origin_cross_e1 = p1_to_origin.cross(@e1)
      v = f * dir.dot(origin_cross_e1)

      # Test v parameter (second barycentric coordinate)
      return [] if v < 0 || (u + v) > 1

      # Compute t to find intersection point
      t = f * @e2.dot(origin_cross_e1)

      # Store u and v in the intersection for normal interpolation
      [Intersection.new(t: t, object: self, u: u, v: v)]
    end

    def local_normal_at(local_point, hit = nil)
      # If we have a hit with u/v coordinates, interpolate the normal
      if hit&.u && hit.v
        # Barycentric interpolation: n = n2*u + n3*v + n1*(1-u-v)
        @n2 * hit.u + @n3 * hit.v + @n1 * (1 - hit.u - hit.v)
      else
        # Fallback to the precomputed flat normal
        @normal
      end
    end
  end
end
