require "matrix"

module Rayz
  class Shape
    attr_accessor :material, :parent, :motion_transform
    attr_accessor :saved_ray # For test_shape debugging
    attr_reader :transform

    def initialize
      @transform = Matrix.identity(4)
      @transform_inverse = Matrix.identity(4)
      @transform_inverse_transpose = Matrix.identity(4)
      @material = Material.new
      @parent = nil
      @motion_transform = nil # Optional: proc that takes time and returns a transform
    end

    def transform=(matrix)
      @transform = matrix
      @transform_inverse = matrix.inverse
      @transform_inverse_transpose = matrix.inverse.transpose
    end

    def intersect(ray, time = 0.0)
      # Get the effective transform inverse (cached for static scenes)
      effective_transform_inverse = if @motion_transform
        # Motion blur requires dynamic inverse calculation
        (@motion_transform.call(time) * @transform).inverse
      else
        # Use cached inverse for static scenes
        @transform_inverse
      end

      # Transform the ray by the inverse of the shape's transformation
      local_ray = ray.transform(effective_transform_inverse)
      @saved_ray = local_ray # For test_shape debugging
      local_intersect(local_ray)
    end

    def normal_at(world_point, hit = nil)
      # Transform world point to object space
      local_point = world_to_object(world_point)

      # Get the local normal
      local_normal = local_normal_at(local_point, hit)

      # Apply normal perturbation if defined
      if @material.normal_perturbation
        perturbation = @material.normal_perturbation.call(local_point)
        local_normal = (local_normal + perturbation).normalize
      end

      # Transform normal to world space
      normal_to_world(local_normal)
    end

    def world_to_object(point)
      # Convert point to object space by traversing parent hierarchy
      point = @parent.world_to_object(point) if @parent

      # Apply this object's inverse transformation (using cached value)
      object_point_matrix = @transform_inverse * point.to_matrix
      Point.new(
        x: object_point_matrix[0, 0],
        y: object_point_matrix[1, 0],
        z: object_point_matrix[2, 0]
      )
    end

    def normal_to_world(normal)
      # Apply this object's inverse transpose transformation (using cached value)
      world_normal_matrix = @transform_inverse_transpose * normal.to_matrix
      world_normal = Vector.new(
        x: world_normal_matrix[0, 0],
        y: world_normal_matrix[1, 0],
        z: world_normal_matrix[2, 0]
      )

      # Normalize the vector
      world_normal = world_normal.normalize

      # Continue transforming through parent hierarchy
      world_normal = @parent.normal_to_world(world_normal) if @parent

      world_normal
    end

    # Subclasses must implement these methods
    def local_intersect(local_ray)
      raise NotImplementedError, "Subclasses must implement local_intersect"
    end

    def local_normal_at(local_point, hit = nil)
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

    # Return the bounding box for this shape in object space (untransformed)
    # Subclasses must implement this method
    def bounds
      raise NotImplementedError, "Subclasses must implement bounds"
    end
  end
end
