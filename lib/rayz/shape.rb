require "matrix"

module Rayz
  class Shape
    attr_accessor :transform, :material, :parent
    attr_accessor :saved_ray # For test_shape debugging

    def initialize
      @transform = Matrix.identity(4)
      @material = Material.new
      @parent = nil
    end

    def intersect(ray)
      # Transform the ray by the inverse of the shape's transformation
      local_ray = ray.transform(@transform.inverse)
      @saved_ray = local_ray # For test_shape debugging
      local_intersect(local_ray)
    end

    def normal_at(world_point)
      # Transform world point to object space
      local_point = world_to_object(world_point)

      # Get the local normal
      local_normal = local_normal_at(local_point)

      # Transform normal to world space
      normal_to_world(local_normal)
    end

    def world_to_object(point)
      object_point_matrix = @transform.inverse * point.to_matrix
      Point.new(
        x: object_point_matrix[0, 0],
        y: object_point_matrix[1, 0],
        z: object_point_matrix[2, 0]
      )
    end

    def normal_to_world(normal)
      world_normal_matrix = @transform.inverse.transpose * normal.to_matrix
      world_normal = Vector.new(
        x: world_normal_matrix[0, 0],
        y: world_normal_matrix[1, 0],
        z: world_normal_matrix[2, 0]
      )
      world_normal.normalize
    end

    # Subclasses must implement these methods
    def local_intersect(local_ray)
      raise NotImplementedError, "Subclasses must implement local_intersect"
    end

    def local_normal_at(local_point)
      raise NotImplementedError, "Subclasses must implement local_normal_at"
    end

    def ==(other)
      return false unless other.class == self.class
      @transform == other.transform && @material == other.material
    end

    # Check if this shape includes another shape
    # Base implementation: a shape includes another if they are the same object
    def includes?(shape)
      self == shape
    end
  end
end
