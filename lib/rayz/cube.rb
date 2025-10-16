require "matrix"
require_relative "shape"

module Rayz
  class Cube < Shape
    def local_intersect(local_ray)
      xtmin, xtmax = check_axis(local_ray.origin.x, local_ray.direction.x)
      ytmin, ytmax = check_axis(local_ray.origin.y, local_ray.direction.y)
      ztmin, ztmax = check_axis(local_ray.origin.z, local_ray.direction.z)

      tmin = [xtmin, ytmin, ztmin].max
      tmax = [xtmax, ytmax, ztmax].min

      return [] if tmin > tmax

      [
        Intersection.new(t: tmin, object: self),
        Intersection.new(t: tmax, object: self)
      ]
    end

    def local_normal_at(local_point, hit = nil)
      maxc = [local_point.x.abs, local_point.y.abs, local_point.z.abs].max

      if maxc == local_point.x.abs
        Vector.new(x: local_point.x, y: 0, z: 0)
      elsif maxc == local_point.y.abs
        Vector.new(x: 0, y: local_point.y, z: 0)
      else
        Vector.new(x: 0, y: 0, z: local_point.z)
      end
    end

    def bounds
      # Unit cube extends from -1 to 1 in all dimensions
      Bounds.new(
        min: Point.new(x: -1, y: -1, z: -1),
        max: Point.new(x: 1, y: 1, z: 1)
      )
    end

    private

    def check_axis(origin, direction)
      tmin_numerator = -1 - origin
      tmax_numerator = 1 - origin

      if direction.abs >= Util::EPSILON
        tmin = tmin_numerator / direction
        tmax = tmax_numerator / direction
      else
        tmin = tmin_numerator * Float::INFINITY
        tmax = tmax_numerator * Float::INFINITY
      end

      if tmin > tmax
        [tmax, tmin]
      else
        [tmin, tmax]
      end
    end
  end
end
