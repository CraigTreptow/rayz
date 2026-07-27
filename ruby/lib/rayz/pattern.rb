require "matrix"

module Rayz
  class Pattern
    attr_reader :transform, :transform_inverse
    attr_accessor :a, :b

    def initialize(a:, b:)
      @a = a
      @b = b
      self.transform = Matrix.identity(4)
    end

    def transform=(matrix)
      @transform = matrix
      @transform_inverse = matrix.inverse
    end

    # Get the color at a point in pattern space
    def pattern_at(point)
      raise NotImplementedError, "Subclasses must implement pattern_at"
    end

    # Get the color at a point on a shape
    def pattern_at_shape(shape, world_point)
      # Transform the world point to object space (using the shape's cached inverse)
      object_point_matrix = shape.transform_inverse * world_point.to_matrix
      object_point = Point.new(
        x: object_point_matrix[0, 0],
        y: object_point_matrix[1, 0],
        z: object_point_matrix[2, 0]
      )

      # Transform the object point to pattern space (using this pattern's cached inverse)
      pattern_point_matrix = @transform_inverse * object_point.to_matrix
      pattern_point = Point.new(
        x: pattern_point_matrix[0, 0],
        y: pattern_point_matrix[1, 0],
        z: pattern_point_matrix[2, 0]
      )

      # Get the color at that point in pattern space
      pattern_at(pattern_point)
    end
  end
end
