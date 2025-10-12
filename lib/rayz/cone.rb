require_relative "shape"
require_relative "intersection"
require_relative "vector"
require_relative "util"

module Rayz
  class Cone < Shape
    attr_accessor :minimum, :maximum, :closed

    def initialize
      super
      @minimum = -Float::INFINITY
      @maximum = Float::INFINITY
      @closed = false
    end

    def local_intersect(local_ray)
      a = local_ray.direction.x**2 - local_ray.direction.y**2 + local_ray.direction.z**2

      b = 2 * local_ray.origin.x * local_ray.direction.x -
        2 * local_ray.origin.y * local_ray.direction.y +
        2 * local_ray.origin.z * local_ray.direction.z

      c = local_ray.origin.x**2 - local_ray.origin.y**2 + local_ray.origin.z**2

      xs = []

      # Ray parallel to one of the cone's halves
      if a.abs < Util::EPSILON
        if b.abs >= Util::EPSILON
          t = -c / (2 * b)
          xs << Intersection.new(t: t, object: self)
        end
      else
        disc = b**2 - 4 * a * c

        # Ray does not intersect the cone
        if disc >= 0
          t0 = (-b - Math.sqrt(disc)) / (2 * a)
          t1 = (-b + Math.sqrt(disc)) / (2 * a)

          t0, t1 = t1, t0 if t0 > t1

          y0 = local_ray.origin.y + t0 * local_ray.direction.y
          if @minimum < y0 && y0 < @maximum
            xs << Intersection.new(t: t0, object: self)
          end

          y1 = local_ray.origin.y + t1 * local_ray.direction.y
          if @minimum < y1 && y1 < @maximum
            xs << Intersection.new(t: t1, object: self)
          end
        end
      end

      # Check for intersections with caps
      intersect_caps(local_ray, xs)

      xs
    end

    def local_normal_at(local_point)
      # Compute the square of the distance from the y axis
      dist = local_point.x**2 + local_point.z**2

      if dist < 1 && local_point.y >= @maximum - Util::EPSILON
        Vector.new(x: 0, y: 1, z: 0)
      elsif dist < 1 && local_point.y <= @minimum + Util::EPSILON
        Vector.new(x: 0, y: -1, z: 0)
      else
        y = Math.sqrt(local_point.x**2 + local_point.z**2)
        y = -y if local_point.y > 0
        Vector.new(x: local_point.x, y: y, z: local_point.z)
      end
    end

    private

    # Checks to see if the intersection at `t` is within a radius
    # from the y axis that corresponds to the cone's radius at that y value
    def check_cap(ray, t, y)
      x = ray.origin.x + t * ray.direction.x
      z = ray.origin.z + t * ray.direction.z

      (x**2 + z**2) <= y.abs
    end

    def intersect_caps(ray, xs)
      # Caps only matter if the cone is closed, and might possibly be
      # intersected by the ray
      return unless @closed
      return if ray.direction.y.abs < Util::EPSILON

      # Check for an intersection with the lower end cap by intersecting
      # the ray with the plane at y=cone.minimum
      t = (@minimum - ray.origin.y) / ray.direction.y
      if check_cap(ray, t, @minimum)
        xs << Intersection.new(t: t, object: self)
      end

      # Check for an intersection with the upper end cap by intersecting
      # the ray with the plane at y=cone.maximum
      t = (@maximum - ray.origin.y) / ray.direction.y
      if check_cap(ray, t, @maximum)
        xs << Intersection.new(t: t, object: self)
      end
    end
  end
end
