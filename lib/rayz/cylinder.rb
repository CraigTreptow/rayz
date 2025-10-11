require_relative "shape"
require_relative "intersection"
require_relative "vector"
require_relative "util"

module Rayz
  class Cylinder < Shape
    attr_accessor :minimum, :maximum, :closed

    def initialize
      super
      @minimum = -Float::INFINITY
      @maximum = Float::INFINITY
      @closed = false
    end

    def local_intersect(local_ray)
      a = local_ray.direction.x**2 + local_ray.direction.z**2

      xs = []

      # Check for intersections with cylinder walls
      if a.abs >= Util::EPSILON
        b = 2 * local_ray.origin.x * local_ray.direction.x +
          2 * local_ray.origin.z * local_ray.direction.z
        c = local_ray.origin.x**2 + local_ray.origin.z**2 - 1

        disc = b**2 - 4 * a * c

        # Ray does not intersect the cylinder
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
        Vector.new(x: local_point.x, y: 0, z: local_point.z)
      end
    end

    private

    # Checks to see if the intersection at `t` is within a radius
    # of 1 (the radius of cylinders) from the y axis
    def check_cap(ray, t)
      x = ray.origin.x + t * ray.direction.x
      z = ray.origin.z + t * ray.direction.z

      (x**2 + z**2) <= 1
    end

    def intersect_caps(ray, xs)
      # Caps only matter if the cylinder is closed, and might possibly be
      # intersected by the ray
      return unless @closed
      return if ray.direction.y.abs < Util::EPSILON

      # Check for an intersection with the lower end cap by intersecting
      # the ray with the plane at y=cyl.minimum
      t = (@minimum - ray.origin.y) / ray.direction.y
      if check_cap(ray, t)
        xs << Intersection.new(t: t, object: self)
      end

      # Check for an intersection with the upper end cap by intersecting
      # the ray with the plane at y=cyl.maximum
      t = (@maximum - ray.origin.y) / ray.direction.y
      if check_cap(ray, t)
        xs << Intersection.new(t: t, object: self)
      end
    end
  end
end
