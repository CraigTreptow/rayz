module Rayz
  class Bounds
    attr_accessor :min, :max

    def initialize(min: Point.new(x: Float::INFINITY, y: Float::INFINITY, z: Float::INFINITY),
      max: Point.new(x: -Float::INFINITY, y: -Float::INFINITY, z: -Float::INFINITY))
      @min = min
      @max = max
    end

    # Create bounds that contain both self and other
    def merge(other)
      Bounds.new(
        min: Point.new(
          x: [@min.x, other.min.x].min,
          y: [@min.y, other.min.y].min,
          z: [@min.z, other.min.z].min
        ),
        max: Point.new(
          x: [@max.x, other.max.x].max,
          y: [@max.y, other.max.y].max,
          z: [@max.z, other.max.z].max
        )
      )
    end

    # Transform bounds by a matrix
    # We need to transform all 8 corners and then find the AABB that contains them
    def transform(matrix)
      # Generate all 8 corners of the bounding box
      corners = [
        Point.new(x: @min.x, y: @min.y, z: @min.z),
        Point.new(x: @min.x, y: @min.y, z: @max.z),
        Point.new(x: @min.x, y: @max.y, z: @min.z),
        Point.new(x: @min.x, y: @max.y, z: @max.z),
        Point.new(x: @max.x, y: @min.y, z: @min.z),
        Point.new(x: @max.x, y: @min.y, z: @max.z),
        Point.new(x: @max.x, y: @max.y, z: @min.z),
        Point.new(x: @max.x, y: @max.y, z: @max.z)
      ]

      # Transform all corners (convert to matrix and back to point)
      transformed_corners = corners.map do |corner|
        result_matrix = matrix * corner.to_matrix
        Point.new(
          x: result_matrix[0, 0],
          y: result_matrix[1, 0],
          z: result_matrix[2, 0]
        )
      end

      # Find the new min and max from transformed corners
      min_x = transformed_corners.map(&:x).min
      min_y = transformed_corners.map(&:y).min
      min_z = transformed_corners.map(&:z).min
      max_x = transformed_corners.map(&:x).max
      max_y = transformed_corners.map(&:y).max
      max_z = transformed_corners.map(&:z).max

      Bounds.new(
        min: Point.new(x: min_x, y: min_y, z: min_z),
        max: Point.new(x: max_x, y: max_y, z: max_z)
      )
    end

    # Test if a ray intersects this bounding box
    # Uses the same algorithm as Cube but with arbitrary min/max values
    def intersects?(ray)
      xtmin, xtmax = check_axis(ray.origin.x, ray.direction.x, @min.x, @max.x)
      ytmin, ytmax = check_axis(ray.origin.y, ray.direction.y, @min.y, @max.y)
      ztmin, ztmax = check_axis(ray.origin.z, ray.direction.z, @min.z, @max.z)

      tmin = [xtmin, ytmin, ztmin].max
      tmax = [xtmax, ytmax, ztmax].min

      tmin <= tmax
    end

    # Check if bounds contain a point
    def contains_point?(point)
      point.x.between?(@min.x, @max.x) &&
        point.y.between?(@min.y, @max.y) &&
        point.z.between?(@min.z, @max.z)
    end

    # Check if bounds contain another bounds
    def contains_bounds?(other)
      contains_point?(other.min) && contains_point?(other.max)
    end

    private

    # Helper method for ray-box intersection (similar to Cube's check_axis)
    def check_axis(origin, direction, min_val, max_val)
      tmin_numerator = min_val - origin
      tmax_numerator = max_val - origin

      if direction.abs >= Util::EPSILON
        tmin = tmin_numerator / direction
        tmax = tmax_numerator / direction
      else
        tmin = tmin_numerator * Float::INFINITY
        tmax = tmax_numerator * Float::INFINITY
      end

      tmin, tmax = tmax, tmin if tmin > tmax

      [tmin, tmax]
    end
  end
end
