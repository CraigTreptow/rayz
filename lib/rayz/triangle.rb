require_relative "shape"
require_relative "intersection"
require_relative "vector"
require_relative "util"

module Rayz
  class Triangle < Shape
    attr_reader :p1, :p2, :p3, :e1, :e2, :normal

    def initialize(p1:, p2:, p3:)
      super()
      @p1 = p1
      @p2 = p2
      @p3 = p3

      # Precompute edge vectors (convert to Vector explicitly)
      diff1 = p2 - p1
      diff2 = p3 - p1
      @e1 = Vector.new(x: diff1.x, y: diff1.y, z: diff1.z)
      @e2 = Vector.new(x: diff2.x, y: diff2.y, z: diff2.z)

      # Precompute normal (same everywhere on triangle)
      @normal = @e2.cross(@e1).normalize
    end

    def local_intersect(local_ray)
      # Möller-Trumbore algorithm for ray-triangle intersection
      dir_cross_e2 = local_ray.direction.cross(@e2)
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
      v = f * local_ray.direction.dot(origin_cross_e1)

      # Test v parameter (second barycentric coordinate)
      return [] if v < 0 || (u + v) > 1

      # Compute t to find intersection point
      t = f * @e2.dot(origin_cross_e1)

      [Intersection.new(t: t, object: self)]
    end

    def local_normal_at(local_point)
      # Triangle normal is constant across entire surface
      @normal
    end
  end
end
