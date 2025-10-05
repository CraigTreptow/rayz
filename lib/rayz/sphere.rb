require "matrix"

module Rayz
  class Sphere
    attr_accessor :transform, :material

    def initialize
      @transform = Matrix.identity(4)
      @material = Material.new
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

    def normal_at(world_point)
      # Transform world point to object space
      object_point = @transform.inverse * world_point.to_matrix
      object_point = Point.new(
        x: object_point[0, 0],
        y: object_point[1, 0],
        z: object_point[2, 0]
      )

      # Normal at object space (for unit sphere, normal = point - origin)
      object_normal = object_point - Point.new(x: 0, y: 0, z: 0)

      # Transform normal to world space
      world_normal = @transform.inverse.transpose * object_normal.to_matrix
      world_normal_vector = Vector.new(
        x: world_normal[0, 0],
        y: world_normal[1, 0],
        z: world_normal[2, 0]
      )

      # Normalize the result
      world_normal_vector.normalize
    end
  end
end
