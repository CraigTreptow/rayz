require "matrix"

module Rayz
  class Sphere
    attr_accessor :transform

    def initialize
      @transform = Matrix.identity(4)
    end

    def intersect(ray)
      # Transform the ray by the inverse of the sphere's transformation
      ray2 = ray.transform(@transform.inverse)

      # Vector from sphere center to ray origin
      sphere_to_ray = ray2.origin - Point.new(x: 0, y: 0, z: 0)

      a = ray2.direction.dot(ray2.direction)
      b = 2 * ray2.direction.dot(sphere_to_ray)
      c = sphere_to_ray.dot(sphere_to_ray) - 1

      discriminant = b * b - 4 * a * c

      return [] if discriminant < 0

      t1 = (-b - Math.sqrt(discriminant)) / (2 * a)
      t2 = (-b + Math.sqrt(discriminant)) / (2 * a)

      [Intersection.new(t1, self), Intersection.new(t2, self)]
    end
  end
end
