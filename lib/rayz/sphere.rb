require "matrix"
require_relative "shape"

module Rayz
  class Sphere < Shape
    def local_intersect(local_ray)
      # Vector from sphere center to ray origin
      sphere_to_ray = local_ray.origin - Point.new(x: 0, y: 0, z: 0)

      a = local_ray.direction.dot(local_ray.direction)
      b = 2 * local_ray.direction.dot(sphere_to_ray)
      c = sphere_to_ray.dot(sphere_to_ray) - 1

      discriminant = b * b - 4 * a * c

      return [] if discriminant < 0

      t1 = (-b - Math.sqrt(discriminant)) / (2 * a)
      t2 = (-b + Math.sqrt(discriminant)) / (2 * a)

      [Intersection.new(t: t1, object: self), Intersection.new(t: t2, object: self)]
    end

    def local_normal_at(local_point, hit = nil)
      # For a unit sphere centered at origin, the normal is just the point vector
      local_point - Point.new(x: 0, y: 0, z: 0)
    end
  end

  def self.glass_sphere
    sphere = Sphere.new
    sphere.material.transparency = 1.0
    sphere.material.refractive_index = 1.5
    sphere
  end
end
